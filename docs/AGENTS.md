# Open Code CLI Agents Guide

## How OpenCode Works: The Agentic Loop

OpenCode (and tools like Claude Code) are **agentic frameworks** — they wrap a language model with tools and an execution layer. Understanding this explains why OpenCode can write files when `ollama run` cannot.

```
You → OpenCode → Model (with tool definitions in context)
                    ↓
              Model outputs a tool call (e.g., write_file)
                    ↓
              OpenCode executes it on your filesystem
                    ↓
              Result fed back to model
                    ↓
              Model continues / calls next tool
```

The model never directly touches your filesystem — it emits structured tool calls and OpenCode executes them. This is why:

- **`ollama run`** is a raw chat interface: no tools are defined, no execution layer exists
- **`opencode`** is an agentic loop: tools are defined in the system prompt, and OpenCode executes whatever the model requests

The same pattern applies to Claude Code (Anthropic's models), Cursor, and other AI coding tools. What differs is the model, the available tools, and how reliably the model produces valid tool calls. Local models like `ministral-3:8b` support tool calling but are less consistent than cloud models trained specifically for it — which is why tool-use confirmation testing matters (see [`scripts/tool-call-test.sh`](../scripts/tool-call-test.sh)).

## What are Agents in Open Code CLI?

Open Code CLI supports **agent mode**, which allows the LLM to autonomously plan and execute multi-step tasks. Agents can:
- Break down complex tasks into smaller steps
- Execute commands and tools iteratively
- Self-correct based on feedback
- Maintain context across multiple operations

**Important:** Only models with confirmed tool use support can act as agents. Read-only models (mistral-nemo, granite3.1-moe, qwen3.5 family) can analyze and plan but cannot create or modify files.

## Agent Modes

Open Code CLI has two primary agents that you can switch between using the **Tab** key:

### 1. Build Agent (Default)
Optimized for construction tasks and code generation.

```bash
opencode
# Build agent is active by default
> Create a REST API with authentication
```

**Switch to build agent:** Press **Tab** key

**Best for:**
- Creating new projects from scratch
- Generating boilerplate code
- File creation and modification
- Rapid prototyping
- Tasks requiring action over analysis

### 2. Plan Agent
Focuses on analysis, planning, and understanding.

```bash
opencode
# Press Tab to switch to plan agent
> How should I refactor this authentication system?
```

**Switch to plan agent:** Press **Tab** key

**Best for:**
- Complex architectural decisions
- Code review and analysis
- Understanding large codebases
- Planning multi-step implementations
- Exploring codebase structure

**Note:** The `/mode` command does not exist. Use **Tab** to switch between build and plan agents.

## Agent Capabilities by Model

Only models with confirmed tool use are listed here. For read-only models, see [LOCALLLMS.md](./LOCALLLMS.md).

### ministral-3:8b-16k (6.0 GB, 16k context) — Recommended
**Agent suitability:** ⭐⭐⭐⭐⭐ Excellent
- Fastest warm inference (~4s) with no think-mode overhead
- 16k context enables multi-file planning and execution
- Consistent, reliable tool calls
- Best overall choice for agentic workflows

**Example tasks:**
```bash
> Analyze the authentication system across multiple files and refactor it
> Create a complete REST API with error handling and tests
> Review and update all TypeScript types across the project
```

### ministral-3:8b (6.0 GB, 4k context)
**Agent suitability:** ⭐⭐⭐⭐☆ Good
- Same speed and reliability as the 16k variant (~4s warm)
- No think-mode overhead
- Limited to single-file or small-scope tasks due to 4k context

**Example tasks:**
```bash
> Add error handling to routes/auth.py
> Create a utility function for date formatting
> Fix the validation bug in models/user.py
```

### qwen3:8b-16k (5.2 GB, 16k context)
**Agent suitability:** ⭐⭐⭐⭐☆ Good
- Extended context enables multi-file analysis and planning
- Enters verbose thinking mode (adds latency, ~26s+)
- Reliable tool use; strong reasoning

**Example tasks:**
```bash
> Analyze the entire authentication system and suggest improvements
> Refactor the API layer to use async/await throughout
> Review all error handling and add comprehensive logging
```

### qwen3:8b (5.2 GB, 8k context)
**Agent suitability:** ⭐⭐⭐☆☆ Moderate
- Handles 2-3 step tasks reliably
- Verbose thinking mode adds overhead (~26s)
- Suitable for standard single-module workflows

**Example tasks:**
```bash
> Create a Flask app with user authentication
> Refactor this module to use dependency injection
> Write tests for the UserService class
```

### qwen3:4b (2.5 GB, 4k context)
**Agent suitability:** ⭐⭐☆☆☆ Limited
- Can handle simple single-step tasks
- Struggles with complex multi-step planning
- Use for quick, straightforward operations

**Example tasks:**
```bash
> Create a simple Python function to calculate factorial
> Add error handling to this code snippet
> Format this JSON file
```

## Agent Workflow Patterns

### Pattern 1: Autonomous Task Execution
Let the agent break down and execute complex tasks independently.

```bash
opencode
# Build agent is default, or press Tab to ensure build mode
> Create a complete REST API for a todo application with:
> - Express.js backend
> - PostgreSQL database
> - JWT authentication
> - Full CRUD operations
> - Input validation
> - Error handling
> - Unit tests
```

**Best models:** ministral-3:8b-16k, qwen3:8b-16k

### Pattern 2: Iterative Refinement
Work with the agent to progressively improve code quality.

```bash
opencode
> Create a user authentication system
# Agent creates basic implementation

> Add password strength validation
# Agent enhances the implementation

> Add rate limiting for login attempts
# Agent adds security features

> Write comprehensive tests
# Agent completes with test coverage
```

**Best models:** ministral-3:8b-16k, ministral-3:8b, qwen3:8b

### Pattern 3: Analysis-Then-Action
Use plan agent first, then switch to build agent to execute.

```bash
opencode
# Press Tab to switch to plan agent
> Analyze my database schema and suggest optimizations

# Review the suggested plan

# Press Tab to switch to build agent
> Implement the suggested index optimizations from the analysis
```

**Best models:** qwen3:8b-16k or ministral-3:8b-16k (both phases)

### Pattern 4: Batch Operations
Run multiple tasks in sequence within one session.

```bash
opencode
> Create models/user.py with User model
# Wait for completion, then:
> Create routes/auth.py with authentication routes
# Wait for completion, then:
> Create tests/test_auth.py with auth tests
```

**Best models:** ministral-3:8b (fast turnaround per task), qwen3:8b

## Controlling Agent Behavior

### Think Mode Behavior

**Observation:** Qwen3 models enter verbose thinking mode during code generation tasks. Ministral-3 models do not.

**Understanding:**
- This is model behavior, not an Open Code CLI issue
- Build mode is already the **default** mode in Open Code CLI
- Tasks complete correctly despite verbosity

**Best approach:**
- Use `ministral-3:8b` or `ministral-3:8b-16k` to avoid think-mode overhead entirely
- If using Qwen3, accept the think mode — it completes correctly and provides insight into reasoning

### Temperature and Sampling

Control via Ollama Modelfile:

```modelfile
FROM ministral-3:8b
PARAMETER temperature 0.7
PARAMETER top_p 0.8
PARAMETER top_k 20
```

**For agent tasks:**
- **Lower temperature (0.3-0.5):** More deterministic, better for code generation
- **Higher temperature (0.7-0.9):** More creative, better for brainstorming

### Context Window Management

**4k context (ministral-3:8b, qwen3:4b):**
- Keep tasks focused on single files
- Avoid multi-file analysis
- Break complex tasks into smaller chunks

**8k context (qwen3:8b):**
- Can handle 1-2 medium files simultaneously
- Suitable for most single-module development tasks

**16k context (ministral-3:8b-16k, qwen3:8b-16k):**
- Can analyze 3-5 medium files
- Suitable for cross-module refactoring
- Better for architecture analysis

## Performance Benchmarks

Based on real-world usage on M1 16GB:

| Task Type | ministral-3:8b | ministral-3:8b-16k | qwen3:4b | qwen3:8b | qwen3:8b-16k |
|-----------|---------------|-------------------|----------|----------|--------------|
| Simple file creation | 4-8s | 4-10s | 5-15s | 15-30s | 45-90s |
| Code review (1 file) | 8-15s | 8-20s | 10-25s | 20-45s | 60-120s |
| Multi-file analysis | N/A | 15-40s | N/A | 40-90s | 90-180s |
| Complex refactoring | N/A | 20-60s | N/A | 60-120s | 120-240s |
| Test generation | 8-20s | 10-25s | 15-30s | 30-60s | 60-120s |

**Notes:**
- Qwen3 times include think-mode overhead; Ministral-3 has none
- Claude API (cloud) is typically 3-10x faster for equivalent tasks
- Performance varies based on hardware (Apple Silicon M-series is optimal)

## Best Practices

### 1. Choose the Right Model for the Task
- **Quick edits / daily driver:** ministral-3:8b (~4s warm, no think-mode tax)
- **Multi-file agentic work:** ministral-3:8b-16k
- **Standard development:** qwen3:8b
- **Multi-file analysis:** qwen3:8b-16k

### 2. Provide Clear Context
```bash
# Bad
> Fix the bug

# Good
> Fix the authentication bug in routes/auth.py where users can login without password verification
```

### 3. Break Down Complex Tasks
```bash
# Instead of one massive prompt
> Create a complete e-commerce application

# Break it down
> Create the product model with fields: id, name, price, description
# Then in next prompt
> Create the shopping cart functionality that uses the Product model
```

### 4. Use Agent Switching Strategically
```bash
# Press Tab to switch to plan agent
> How should I refactor this authentication system?
# Review the plan
# Press Tab to switch to build agent
> Implement the refactoring plan from above
```

### 5. Validate Agent Output
Always review generated code for:
- Security vulnerabilities (SQL injection, XSS, etc.)
- Logic errors and edge cases
- Performance implications
- Compliance with project standards

## Troubleshooting Agent Issues

### Agent Gets Stuck in Thinking Mode
**Symptoms:** Verbose analysis, slow response, excessive planning

**Understanding:**
- Build agent is already the default
- Thinking mode is a Qwen3 model behavior, not a mode setting
- Tasks complete successfully despite verbosity

**Best approach:**
- Switch to `ministral-3:8b` or `ministral-3:8b-16k` — no think-mode overhead
- Or accept Qwen3 think-mode as part of using those models

### Agent Loses Context
**Symptoms:** Forgets previous steps, contradicts earlier decisions

**Solutions:**
1. Use models with larger context windows (ministral-3:8b-16k, qwen3:8b-16k)
2. Break tasks into smaller, independent chunks
3. Explicitly reference earlier steps in prompts
4. Press Tab to switch to plan agent to establish a clear plan before execution

### Agent Produces Low-Quality Code
**Symptoms:** Bugs, security issues, poor practices

**Solutions:**
1. Provide more specific requirements
2. Ask agent to add tests and validation
3. Switch to a larger model (qwen3:8b-16k, ministral-3:8b-16k)

### Agent is Too Slow
**Symptoms:** Long wait times, frustration with iteration speed

**Solutions:**
1. Switch to `ministral-3:8b` — fastest warm inference, no think-mode overhead
2. Break tasks into smaller pieces
3. Use standard context when extended context isn't needed
4. Consider switching to cloud models (Claude API) for time-sensitive work

### Agent Hallucinates or Creates Invalid Code
**Symptoms:** References non-existent libraries, invalid syntax

**Solutions:**
1. Use lower temperature (via Modelfile)
2. Provide explicit examples of desired output
3. Validate all generated code before committing

## When to Use Cloud Models vs Local Agents

### Use Local Models (Ollama + Open Code)
- Working offline
- Processing sensitive/proprietary code
- Running batch operations overnight
- Privacy requirements mandate local processing
- Learning/experimenting without API costs
- Tasks where speed is not critical

### Use Cloud Models (Claude API + Open Code)
- Real-time interactive development
- Complex multi-file operations requiring fast iteration
- Time-sensitive tasks
- Working with very large codebases (200k+ context)
- When you need the absolute best code quality
- When speed is more important than cost

## Resources

- [Open Code CLI Documentation](https://opencode.ai/docs)
- [Ollama Model Library](https://ollama.com/library)
- [Qwen3 Documentation](https://qwen.readthedocs.io/)
