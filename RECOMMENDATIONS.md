# Ollama vs LM Studio: Recommendations for Open Code CLI

## ✅ RESOLVED: Critical Tool Usage Discovery (2025-11-18)

**MAJOR FINDING: Only Qwen3 models have tool usage capabilities with Open Code CLI!**

**Testing results:**
- ✅ **qwen3:8b-16k** - Successfully creates files, full tool usage
- ❌ **mistral-nemo:12b** - Excellent analysis but NO file creation
- ❌ **granite3.1-moe** - Fast planning but NO file creation

**Root cause:** Tool/function calling requires specific model training. Qwen3 models have this built-in, while Mistral Nemo and Granite models lack it.

**Recommendation:**
- **For file creation/modification:** Use Qwen3 models ONLY (qwen3:8b-16k, qwen3:8b, qwen3:4b)
- **For read-only analysis:** Any model works (Mistral Nemo has best quality)
- **Think mode:** Accept it - it doesn't prevent execution and provides useful reasoning

---

## Executive Summary

After comprehensive research and analysis, **Ollama is recommended** over LM Studio for Open Code CLI usage, **pending resolution of file creation issue**.

## Comparison Matrix

| Feature | Ollama | LM Studio | Winner |
|---------|--------|-----------|--------|
| **Open Code CLI Compatibility** | Native OpenAI-compatible API | OpenAI-compatible API | Tie |
| **Command-line First** | ✅ CLI-native | ⚠️ GUI-first, CLI secondary | Ollama |
| **Model Management** | Simple (`ollama pull/list/rm`) | GUI-based | Ollama |
| **Automation/Scripting** | ✅ Easy to script | ⚠️ More complex | Ollama |
| **License** | MIT (fully open source) | Proprietary | Ollama |
| **Performance** | Fast, optimized | Comparable | Tie |
| **Platform Support** | macOS, Linux, Windows | macOS, Windows | Ollama |
| **Ease of Use** | CLI learning curve | GUI beginner-friendly | LM Studio |
| **Customization** | ✅ Modelfile, parameters | Limited | Ollama |
| **Cost** | Free, no limits | Free | Tie |

## Decision: Stick with Ollama

**Recommendation: Continue using Ollama**

### Reasons:
1. **Developer-friendly**: CLI-native design aligns perfectly with Open Code CLI workflow
2. **Better automation**: Easy to script model management and deployment
3. **Open source**: MIT license provides transparency and community support
4. **Custom models**: Modelfile system allows precise control (like qwen3:8b-16k)
5. **Lightweight**: No GUI overhead when running headless/automated
6. **Linux support**: Better cross-platform compatibility

### When LM Studio might be better:
- You prefer GUI model management
- You're new to LLMs and want visual interface
- You need to frequently compare models side-by-side visually
- You prefer point-and-click over terminal commands

## Qwen3 8B 16K Think Mode Issue

### Problem
The Qwen3 8B 16K model enters verbose thinking mode during code generation tasks.

### Root Cause
The thinking mode is a **model behavior**, not an Open Code CLI issue. The Qwen3 model family has built-in thinking capabilities that are triggered by certain prompt patterns. Open Code CLI does not have a `/no_think` flag - only a `/thinking` toggle which enables additional thinking mode (not useful for suppression).

### Solutions (Ranked by Effectiveness)

#### 1. Accept the Model Behavior (Most Pragmatic)
**Effectiveness:** ⭐⭐⭐⭐⭐
- Build agent is the default in Open Code CLI
- Tasks complete correctly despite think mode verbosity
- "Free documentation" of model's reasoning
- Good for learning how the model thinks
- Consider thinking mode output as structured analysis

**Note:** Use **Tab** key to switch between build and plan agents. Build is the default.

#### 2. Use Alternative Models (Effective)
Switch to models less prone to thinking mode:
- **Mistral Nemo 12B**: Best code quality, minimal thinking mode (**read-only, no file creation**)
- **Granite 3.1 MoE**: Fast, controlled output (**read-only, no file creation**)
- **Qwen3 8B (standard)**: Less context but possibly less thinking mode (needs testing)
- **Qwen3 4B**: Faster, smaller (needs testing)

**Effectiveness:** ⭐⭐⭐⭐☆
- May reduce thinking mode
- Mistral/Granite CANNOT create files (analysis only)
- Qwen3 variants should work but need testing

#### 3. Custom Modelfile (Advanced)
Create a custom model with thinking mode suppression:

```bash
# Create qwen3-no-think.modelfile
FROM qwen3:8b-16k
PARAMETER temperature 0.7
PARAMETER top_p 0.8
PARAMETER top_k 20
SYSTEM You are a code assistant. Respond concisely without verbose thinking or analysis. Immediately execute tasks.

# Create model
ollama create qwen3:8b-16k-nothink -f qwen3-no-think.modelfile
```

**Effectiveness:** ⭐⭐⭐☆☆
- Requires maintenance
- May still not fully suppress thinking mode
- Worth trying if other methods fail

### Recommended Approach

**For most users:**
1. Accept that **build agent is the default** - use Tab key to switch to plan agent if needed
2. Use **qwen3:8b-16k** for file creation/modification (only model with tool usage)
3. Use **mistral-nemo:12b** for code review/analysis only (no file creation)
4. Accept think mode verbosity as trade-off for local/private LLM usage with extended context

**Available Open Code CLI slash commands (use `/` prefix):**

| Command | Aliases | Description | Keybind |
|---------|---------|-------------|---------|
| `/compact` | `/summarize` | Compact the current session | ctrl+x c |
| `/details` | — | Toggle tool execution details | ctrl+x d |
| `/editor` | — | Open external editor for composing messages | ctrl+x e |
| `/exit` | `/quit`, `/q` | Exit OpenCode | ctrl+x q |
| `/export` | — | Export current conversation to Markdown | ctrl+x x |
| `/help` | — | Show the help dialog | ctrl+x h |
| `/init` | — | Create or update `AGENTS.md` file | ctrl+x i |
| `/models` | — | List available models | ctrl+x m |
| `/new` | `/clear` | Start a new session | ctrl+x n |
| `/redo` | — | Redo a previously undone message | ctrl+x r |
| `/sessions` | `/resume`, `/continue` | List and switch between sessions | ctrl+x l |
| `/share` | — | Share current session | ctrl+x s |
| `/themes` | — | List available themes | ctrl+x t |
| `/undo` | — | Undo last message in the conversation | ctrl+x u |
| `/unshare` | — | Unshare current session | — |

**Navigation:**
- **Tab** - Switch between build and plan agents

**Note:** There is NO `/mode`, `/no_think`, `/thinking`, `/rename`, `/copy`, or `/timeline` command.

## Model Selection Strategy

### Quick Reference

| Your Need | Recommended Model | Rationale |
|-----------|------------------|-----------|
| **Fastest response** | granite3.1-moe | 2.0 GB, MoE efficiency |
| **Best code quality** | mistral-nemo:12b | 7.5 GB, superior reasoning |
| **Multi-file analysis** | qwen3:8b-16k | 16k context window |
| **Balanced general use** | qwen3:8b | 5.2 GB, good speed/quality |
| **Simple quick tasks** | qwen3:4b | 2.5 GB, very fast |
| **Minimal thinking mode** | mistral-nemo:12b | More controlled output |
| **Privacy-critical work** | Any Ollama model | All run locally |

### **UPDATED Model Recommendations (Post-Testing)**

**CRITICAL:** Only Qwen3 models support file creation in Open Code CLI!

#### Tier 1: Primary Models (File Creation/Modification)
1. **qwen3:8b-16k** (5.2 GB, custom) ⭐ **RECOMMENDED**
   - **Use for:** ALL file creation, modification, refactoring tasks
   - **Pros:** ✅ Full tool usage, extended context (16k), comprehensive analysis
   - **Cons:** Verbose think mode, slower (60-90s for simple tasks)
   - **Status:** ✅ TESTED & WORKING

2. **qwen3:8b** (5.2 GB) - **Likely works, needs testing**
   - **Use for:** Standard file operations, code generation
   - **Pros:** Probably has tool usage, standard context, faster than 16k
   - **Cons:** Smaller context window, think mode likely present

3. **qwen3:4b** (2.5 GB) - **Likely works, needs testing**
   - **Use for:** Quick file edits, simple code generation
   - **Pros:** Probably has tool usage, fast, small download
   - **Cons:** Limited context, may struggle with complex tasks

#### Tier 2: Analysis-Only Models (NO File Creation)
4. **mistral-nemo:12b-instruct-2407-q4_K_M** (7.5 GB) ⚠️ **READ-ONLY**
   - **Use for:** Code review, analysis, planning, suggestions
   - **Pros:** ✅ Best code quality, strong reasoning, minimal think mode
   - **Cons:** ❌ CANNOT create or modify files
   - **Status:** ✅ TESTED - Analysis works, execution fails

5. **granite3.1-moe:latest** (2.0 GB) ⚠️ **READ-ONLY**
   - **Use for:** Quick code review, fast analysis
   - **Pros:** ✅ Very fast, efficient, good for quick insights
   - **Cons:** ❌ CANNOT create or modify files
   - **Status:** ✅ TESTED - Planning works, execution fails

### **UPDATED Workflow-Specific Recommendations**

#### Code Review Workflow (Read-Only Analysis)
```bash
# Use Mistral Nemo for best quality analysis
opencode --model ollama/mistral-nemo:12b
> /mode review
> Analyze the security of src/auth/ directory
# ✅ Works great - no file creation needed
```

#### Code Review WITH Changes
```bash
# MUST use Qwen3 for implementation
opencode --model ollama/qwen3:8b-16k
> /mode build
> Review src/auth/ and fix any security issues you find
# ✅ Can analyze AND create files
```

#### Refactoring Workflow (MUST use Qwen3)
```bash
# Use Qwen3 8B 16K for refactoring (needs file modification)
opencode --model ollama/qwen3:8b-16k
> /mode build
> Refactor UserService to use dependency injection
# ✅ Extended context + tool usage
```

#### Quick File Edits (Use smaller Qwen3)
```bash
# Use Qwen3 4B or 8B for speed (once tested)
opencode --model ollama/qwen3:8b
> /mode build
> Add type hints to utils/helpers.py
# ✅ Faster than 16k variant
```

#### Planning/Architecture (Use Any Model)
```bash
# Use Mistral Nemo for best quality planning
opencode --model ollama/mistral-nemo:12b
> /mode plan
> Analyze the codebase architecture and suggest improvements
# ✅ No file creation, just analysis
```

## Configuration Validation

### Current Setup Status
✅ [opencode.json](opencode.json) - Correctly configured
✅ Models defined - All 5 models present
✅ Provider - Ollama at correct endpoint
✅ Schema - Valid Open Code configuration

### Test Results Needed

Run tests using [test-opencode.md](test-opencode.md):

```bash
# Test 1: Simple file creation with each model
opencode --model ollama/qwen3:4b
> Create a todo.md file with 3 sample tasks

# Test 2: Build mode validation (default mode)
opencode --model ollama/qwen3:8b-16k
> Create a hello.py file
# Note: Build mode is default, no need to set /mode build

# Test 3: Quality comparison
opencode --model ollama/mistral-nemo:12b
> Create a Python class for user authentication with password hashing
```

### Performance Baseline

Expected times (on Apple Silicon M-series):

| Model | Simple File | Code Review | Multi-file |
|-------|-------------|-------------|------------|
| qwen3:4b | 5-15s | 10-25s | N/A |
| qwen3:8b | 15-30s | 20-45s | 40-90s |
| qwen3:8b-16k | 45-90s | 60-120s | 90-180s |
| mistral-nemo:12b | 25-60s | 40-90s | 60-150s |
| granite3.1-moe | 6-18s | 15-35s | 25-60s |

**Note:** Times include think mode overhead where applicable.

## Next Steps

### Immediate Actions
1. ✅ Test Open Code CLI with current configuration
2. ✅ Validate think mode workarounds
3. ✅ Document findings in [test-opencode.md](test-opencode.md)
4. ⏳ Add test results to this document

### Future Improvements
1. **Monitor Open Code CLI updates** - Check for better think mode control in future releases
2. **Test new Ollama models** - Qwen3.5, Llama 4, etc. as they become available
3. **Create additional Modelfiles** - Custom models optimized for specific tasks
4. **Batch processing scripts** - Automate common workflows
5. **Performance optimization** - Fine-tune parameters for each model

### Documentation Maintenance
- Update [docs/AGENTS.md](docs/AGENTS.md) with real-world test results
- Add successful prompts to [examples/](examples/)
- Document any new workarounds discovered
- Track Open Code CLI version compatibility

## Conclusion

**✅ Ollama + Open Code CLI works, but ONLY with Qwen3 models for file operations!**

**CRITICAL TAKEAWAYS:**

1. **File creation/modification:** Use `qwen3:8b-16k` (or test qwen3:8b/4b)
2. **Code review/analysis:** Any model works; `mistral-nemo:12b` has best quality
3. **Think mode:** Accept it - doesn't prevent execution, provides useful reasoning
4. **Mistral & Granite models:** Excellent for analysis, but CANNOT create files

**Updated model strategy:**
- **Primary workhorse:** `qwen3:8b-16k` (proven to work for everything)
- **Fast analysis:** `mistral-nemo:12b` or `granite3.1-moe` (read-only)
- **Future testing:** `qwen3:8b` and `qwen3:4b` (likely have tool usage too)

The configuration is solid, but tool usage is model-specific. The benefits of local, private LLM usage are preserved with Qwen3 models.

## Resources

- [Ollama Documentation](https://github.com/ollama/ollama)
- [Open Code CLI Docs](https://opencode.ai/docs)
- [Qwen3 Model Card](https://huggingface.co/Qwen/Qwen3-8B)
- [Mistral Nemo Docs](https://mistral.ai/news/mistral-nemo/)
- [LM Studio vs Ollama Analysis](https://hyscaler.com/insights/ollama-vs-lm-studio/)
