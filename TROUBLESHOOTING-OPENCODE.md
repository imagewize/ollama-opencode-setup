# Open Code CLI Troubleshooting Guide

## Critical Issue: Models Not Creating Files

### Problem
Local Ollama models (granite3.1-moe, mistral-nemo:12b) understand tasks but **do not execute file creation commands**.

**Symptoms:**
- Model generates task descriptions/plans
- Model shows understanding of the request
- **No actual file is created**
- Terminal shows planning output but no action

**Confirmed failing models:**
- ✗ granite3.1-moe:latest
- ✗ mistral-nemo:12b-instruct-2407-q4_K_M

**Models to test:**
- ? qwen3:4b
- ? qwen3:8b
- ? qwen3:8b-16k

---

## Diagnostic Steps

### Step 1: Verify Open Code CLI Setup

```bash
# Check Open Code CLI version
opencode --version

# Verify Ollama is running
curl http://localhost:11434/v1/models

# Check available models
ollama list
```

### Step 2: Test with Different Prompts

Try these progressively more explicit prompts:

**Test A: Original prompt**
```bash
opencode
> Create a todo.md file with 3 sample tasks
```

**Test B: Explicit mode directive**
```bash
opencode
> /mode build
> Create a todo.md file with 3 sample tasks
```

**Test C: Tool-specific instruction**
```bash
opencode
> Use the write tool to create a file called todo.md with 3 tasks
```

**Test D: Simple file write**
```bash
opencode
> Write a file called hello.txt with the text "Hello World"
```

**Test E: Code generation (sometimes works better)**
```bash
opencode
> Create a hello.py file that prints "Hello World"
```

### Step 3: Check Open Code CLI Agent Configuration

Open Code CLI may require specific configuration for agent/tool usage. Check:

```bash
# Look for Open Code CLI config
cat ~/.opencode/config.json

# Check if there's a workspace-specific config
cat .opencode/config.json
```

### Step 4: Compare with Cloud Model (Claude)

To isolate whether this is an Ollama-specific issue:

```bash
# Test with Claude (if you have API key configured)
opencode --model claude-sonnet-4
> Create a todo.md file with 3 sample tasks
```

If Claude works but Ollama doesn't, this is a **local model tool usage** issue.

---

## Possible Solutions

### Solution 1: Use `/mode build` Explicitly

```bash
opencode
> /mode build
> Create a todo.md file with 3 sample tasks
```

**Rationale:** Build mode may activate tool usage capabilities in the model.

### Solution 2: More Explicit Prompts

Instead of:
```
Create a todo.md file with 3 sample tasks
```

Try:
```
TASK: Write a new file
FILENAME: todo.md
CONTENT: A markdown file with 3 sample tasks in a bullet list

Please execute this file write operation now.
```

### Solution 3: Check Open Code CLI System Prompts

Open Code CLI may need specific system prompts for local models. Look for:
- `.opencode/system-prompt.txt`
- `opencode.json` with `systemPrompt` field

The system prompt should instruct the model to use tools like:
```
You are a code assistant with access to file system tools.
When asked to create files, use the write tool.
When asked to read files, use the read tool.
Always execute requested actions, not just plan them.
```

### Solution 4: Test with Qwen3 Models

Qwen3 models may have better tool usage training:

```bash
# Test qwen3:8b
opencode --model ollama/qwen3:8b
> /mode build
> Create a todo.md file with 3 tasks

# Test qwen3:8b-16k
opencode --model ollama/qwen3:8b-16k
> /mode build
> Create a todo.md file with 3 tasks
```

### Solution 5: Check Open Code CLI Documentation

**Action items:**
1. Visit [Open Code CLI documentation](https://opencode.ai/docs)
2. Search for "tool usage", "agent configuration", or "local models"
3. Check if there are specific requirements for Ollama models
4. Look for example prompts that work with local models

### Solution 6: Custom Model with Tool-Focused System Prompt

Create a custom Ollama model optimized for Open Code CLI:

```bash
# Create modelfile: opencode-mistral.modelfile
cat > opencode-mistral.modelfile << 'EOF'
FROM mistral-nemo:12b-instruct-2407-q4_K_M

SYSTEM """
You are a code assistant with access to file system tools.

When the user asks you to create, modify, or read files:
1. Use the appropriate tool (write, edit, read)
2. Execute the action immediately
3. Do not just describe what should be done - DO IT

Always prefer action over planning.
Always use tools to manipulate files.
Never just describe file contents - create them.
"""

PARAMETER temperature 0.7
PARAMETER top_p 0.8
PARAMETER top_k 20
EOF

# Create the model
ollama create opencode-mistral -f opencode-mistral.modelfile

# Test it
opencode --model ollama/opencode-mistral
> Create a todo.md file with 3 sample tasks
```

---

## Investigation Questions

To debug this further, we need to understand:

1. **Does Open Code CLI support tool usage with Ollama models?**
   - Check Open Code CLI documentation
   - Check GitHub issues for similar reports
   - Search for "ollama tool usage" in Open Code CLI docs

2. **Are local models trained on tool usage?**
   - Mistral Nemo: May not have tool/function calling training
   - Granite 3.1: Unknown tool usage capabilities
   - Qwen3: Has some function calling abilities

3. **Does Open Code CLI require specific model capabilities?**
   - Function calling API support?
   - Tool usage training?
   - Specific prompt format?

4. **Is there a configuration we're missing?**
   - Check `opencode.json` schema documentation
   - Look for "tools", "functions", or "agents" configuration

---

## Temporary Workarounds

While investigating the root cause:

### Workaround 1: Manual File Creation

After getting the model's output:
```bash
# Model generates content but doesn't create file
# Manually create the file based on output
cat > todo.md << 'EOF'
[paste model's generated content here]
EOF
```

### Workaround 2: Use for Analysis Only

Use local models for:
- Code review (reading files)
- Analysis and suggestions
- Planning and architecture
- Documentation review

Use Claude (cloud) for:
- File creation
- Code generation
- Refactoring (requires file writes)
- Multi-file modifications

### Workaround 3: Pipe Model Output

```bash
# Get model to generate content
opencode --model ollama/mistral-nemo:12b << 'PROMPT'
Generate the content for a todo.md file with 3 tasks.
Output ONLY the file content, no explanations.
PROMPT

# Capture and write manually
# (this may require scripting)
```

---

## Next Steps for Diagnosis

1. **Test Qwen3 models** - They may have better tool usage
2. **Check Open Code CLI GitHub** - Look for issues about Ollama tool usage
3. **Review Open Code CLI docs** - Find tool usage configuration
4. **Try custom system prompts** - Via Modelfile or config
5. **Test with explicit tool commands** - "use write tool to..."
6. **Compare with Claude** - Confirm it's a local model issue

---

## Resources

- [Open Code CLI Documentation](https://opencode.ai/docs)
- [Ollama Function Calling](https://ollama.com/blog/tool-support)
- [Qwen3 Tool Usage](https://qwen.readthedocs.io/en/latest/framework/function_call.html)
- [Open Code GitHub Issues](https://github.com/opencodeai/opencode/issues)

---

## Update Log

**2025-11-18:**
- Identified file creation issue with granite3.1-moe and mistral-nemo:12b
- Both models plan but don't execute file writes
- Needs further investigation and testing with Qwen3 models
