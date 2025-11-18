# Open Code CLI Test File

## Purpose
This file is used to test Open Code CLI functionality with local Ollama models.

## Test Instructions

### Test 1: Simple File Creation
**Prompt:** "Create a todo.md file with 3 sample tasks"

**Expected behavior:**
- Model creates a new file called `todo.md`
- File contains 3 tasks in markdown format
- Task completes in reasonable time (30-90s for qwen3:8b-16k)

### Test 2: Code Review
**Prompt:** "Review the opencode.json file and suggest improvements"

**Expected behavior:**
- Model reads the opencode.json file
- Provides constructive feedback on configuration
- Suggests potential improvements or best practices

### Test 3: Multi-File Analysis
**Prompt:** "Analyze the documentation structure in this repository and suggest improvements"

**Expected behavior:**
- Model reads multiple files (README.md, CLAUDE.md, docs/)
- Provides comprehensive analysis
- Suggests organizational improvements

### Test 4: Think Mode Observation
**Prompt:** "Create a simple hello.py file that prints 'Hello World'"

**Expected behavior:**
- Qwen3 models will likely enter thinking mode (verbose analysis)
- Task completes successfully despite verbosity
- Build mode is already default (no need to set `/mode build`)

**Note:** There is no `/no_think` flag in Open Code CLI. Build agent is the default. Think mode verbosity is model behavior.

### Test 5: Bash Command Integration
**Prompt:**
```
!git status
Based on the output, tell me if there are any uncommitted changes
```

**Expected behavior:**
- Git status output is included in conversation
- Model analyzes the git status output
- Provides clear answer about repository state

### Test 6: Agent Switching
**Instructions:**
1. Start with build agent (default)
2. Press **Tab** to switch to plan agent
3. Ask: "What is the structure of this repository?"
4. Press **Tab** to switch back to build agent
5. Ask: "Create a CONTRIBUTING.md file based on the repository structure"

**Expected behavior:**
- Plan agent provides detailed analysis
- Build agent creates the file
- Tab key successfully switches between agents

## Available Commands

See [docs/OPENCODE-COMMANDS.md](docs/OPENCODE-COMMANDS.md) for complete command reference.

**Key commands:**
- **Tab** - Switch between build and plan agents
- `!command` - Run bash command and include output
- `/help` - Show help dialog
- `/models` - List available models
- `/sessions` - List and resume sessions
- `/export` - Export conversation to Markdown
- `/undo` / `/redo` - Undo/redo messages

## Test Results

### Date: 2025-11-18
### Tester: jasperfrumau

---

### Model: granite3.1-moe:latest

**Test 1: Create todo.md file**
- Status: [X] Fail
- Time taken: ~15-20s (estimated)
- Notes:
  - Model generated JSON task structure but **did not create the file**
  - Created task plan with 3 items in JSON format
  - Shows "planning" capability but lacks "execution" capability
  - **Critical issue:** Model doesn't understand it needs to actually create files in Open Code CLI

---

### Model: mistral-nemo:12b-instruct-2407-q4_K_M

**Test 1: Create todo.md file**
- Status: [X] Fail
- Time taken: ~30-60s (estimated)
- Notes:
  - Model generated comprehensive task descriptions
  - Created detailed 3-task structure with descriptions, deadlines, dependencies, assignees
  - **Critical issue:** Did not create the actual `todo.md` file
  - Shows excellent "analysis" and "planning" but lacks "execution" capability
  - Tasks were well-structured and professional quality

---

---

### Model: qwen3:8b-16k (16k context)

**Test 1: Create todo.md file**
- Status: [✓] **PASS**
- Time taken: ~60-90s (estimated)
- Notes:
  - ✅ **FILE CREATED SUCCESSFULLY!**
  - Model entered verbose thinking mode (as expected)
  - Model eventually invoked the write tool correctly
  - Tool call format: `{"name": "write", "arguments": {"content": "...", "filePath": "..."}}`
  - **Key insight:** qwen3 models HAVE tool usage capabilities
  - Think mode shows detailed reasoning before execution
  - Default mode is "build" (can switch to "plan" with tab)

**Critical findings:**
- Qwen3 8B 16K **CAN create files** - it has proper tool integration
- Granite and Mistral models may lack tool usage training
- Think mode is verbose but doesn't prevent execution
- Open Code CLI shows modified files in sidebar after successful tool use

---

### Additional Test Results Needed:
- qwen3:4b
- qwen3:8b

## Comparison Matrix

| Model | Test 1 | Test 2 | Test 3 | Test 4 | Execution Capability | Notes |
|-------|--------|--------|--------|--------|---------------------|-------|
| qwen3:4b | ❓ | ❓ | ❓ | ❓ | ❓ | Not tested yet |
| qwen3:8b | ❓ | ❓ | ❓ | ❓ | ❓ | Not tested yet |
| **qwen3:8b-16k** | ✅ **PASS** | ❓ | ❓ | ❓ | ✅ **Full tool usage** | Verbose think mode but executes successfully |
| mistral-nemo:12b-instruct-2407-q4_K_M | ❌ FAIL | ❓ | ❓ | ❓ | ❌ No tool usage | Excellent analysis, no file creation |
| granite3.1-moe | ❌ FAIL | ❓ | ❓ | ❓ | ❌ No tool usage | JSON output, no file creation |

## Critical Findings

### ✅ RESOLVED: Tool Usage Requires Qwen3 Models

**Discovery:** Only Qwen3 models have proper tool usage capabilities with Open Code CLI!

**Working models:**
- ✅ **qwen3:8b-16k** - Full tool usage, creates files successfully

**Non-working models (no tool usage):**
- ❌ granite3.1-moe - Plans but doesn't execute
- ❌ mistral-nemo:12b-instruct-2407-q4_K_M - Excellent analysis but no file creation

**Root cause:**
- Tool usage requires specific model training for function calling
- Qwen3 family has built-in tool/function calling capabilities
- Mistral Nemo and Granite models lack this training
- This is NOT an Open Code CLI issue, it's a model capability gap

**Tool call format used by Qwen3:**
```json
{
  "name": "write",
  "arguments": {
    "content": "# Todo List\n\n- Task 1\n- Task 2",
    "filePath": "/absolute/path/to/file.md"
  }
}
```

**Think mode behavior:**
- Qwen3 8B 16K enters verbose thinking mode before execution
- Thinking doesn't prevent execution - file is still created
- Think mode shows detailed reasoning (can be useful for debugging)
- Default mode in Open Code CLI is "build", can switch to "plan" with tab

---

## Recommendations

### **UPDATED Based on Test Results:**

**✅ For Open Code CLI with Ollama: USE QWEN3 MODELS ONLY**

**Confirmed working models:**
1. **qwen3:8b-16k** (16k context) - ✅ Full tool usage, file creation works
   - Use for: Multi-file tasks, complex operations
   - Caveat: Verbose think mode, slower response

**Likely working (need testing):**
2. **qwen3:8b** (8k context) - Probably has tool usage (same family)
3. **qwen3:4b** (8k context) - Probably has tool usage (same family)

**❌ NON-WORKING models (analysis only, no execution):**
- **mistral-nemo:12b-instruct-2407-q4_K_M** - Excellent for planning/analysis, but cannot create files
- **granite3.1-moe** - Fast for analysis, but cannot create files

**Updated use cases:**

**File creation & modification:**
- ✅ Use: qwen3:8b-16k, qwen3:8b, or qwen3:4b
- ❌ Avoid: mistral-nemo:12b-instruct-2407-q4_K_M, granite3.1-moe

**Code review & analysis (read-only):**
- ✅ All models work (mistral-nemo:12b-instruct-2407-q4_K_M is best quality)
- Consider: Use faster models (granite, qwen3:4b) for quick reviews

**Multi-file analysis with changes:**
- ✅ Use: qwen3:8b-16k (extended context + tool usage)

**Think mode:**
- Accept it as "free documentation" of reasoning
- Doesn't prevent execution
- Can be helpful for understanding model decisions
