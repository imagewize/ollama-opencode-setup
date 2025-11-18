# Open Code CLI Agents Guide

## What are Agents in Open Code CLI?

Open Code CLI supports **agent mode**, which allows the LLM to autonomously plan and execute multi-step tasks. Agents can:
- Break down complex tasks into smaller steps
- Execute commands and tools iteratively
- Self-correct based on feedback
- Maintain context across multiple operations

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

### Other Modes (If Applicable)
Some Open Code CLI versions may have additional specialized modes:

**Review-focused analysis:**
- Security audits
- Code quality assessment
- Bug detection
- Best practices validation

## Agent Capabilities by Model

### qwen3:4b (2.5 GB)
**Agent suitability:** ⭐⭐☆☆☆ Limited
- Can handle simple single-step tasks
- Struggles with complex multi-step planning
- Use for quick, straightforward operations
- Not recommended for autonomous agent workflows

**Example tasks:**
```bash
> Create a simple Python function to calculate factorial
> Add error handling to this code snippet
> Format this JSON file
```

### qwen3:8b (5.2 GB)
**Agent suitability:** ⭐⭐⭐☆☆ Moderate
- Handles 2-3 step tasks reliably
- Can maintain context across related operations
- Suitable for standard development workflows
- May struggle with complex multi-file refactoring

**Example tasks:**
```bash
> Create a Flask app with user authentication
> Refactor this module to use dependency injection
> Write tests for the UserService class
```

### qwen3:8b-16k (5.2 GB, 16k context)
**Agent suitability:** ⭐⭐⭐⭐☆ Good
- Extended context enables better planning
- Can analyze multiple files simultaneously
- Suitable for complex multi-step tasks
- **Known issue:** May enter verbose thinking mode

**Example tasks:**
```bash
> Analyze the entire authentication system and suggest improvements
> Refactor the API layer to use async/await throughout
> Review all error handling and add comprehensive logging
```

### mistral-nemo:12b-instruct-2407-q4_K_M (7.5 GB)
**Agent suitability:** ⭐⭐⭐⭐⭐ Excellent
- Best code quality among local models
- Strong reasoning and planning capabilities
- Handles complex multi-step tasks well
- More deterministic, less prone to hallucination

**Example tasks:**
```bash
> Design and implement a microservices architecture
> Perform a comprehensive security audit
> Refactor this monolith into modular components
```

### granite3.1-moe:latest (2.0 GB)
**Agent suitability:** ⭐⭐⭐☆☆ Moderate
- Mixture of Experts architecture provides good efficiency
- Fast inference despite strong capabilities
- Good balance of speed and quality
- Best for iterative development workflows

**Example tasks:**
```bash
> Build a CRUD API with database integration
> Create unit tests for all service classes
> Add comprehensive error handling to the application
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

**Best models:** mistral-nemo:12b, qwen3:8b-16k

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

**Best models:** granite3.1-moe, qwen3:8b

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

**Best models:** qwen3:8b-16k (analysis), mistral-nemo:12b (implementation)

### Pattern 4: Batch Processing
Execute multiple related tasks in sequence.

```bash
opencode --batch tasks.txt
```

**tasks.txt:**
```
Create models/user.py with User model
Create routes/auth.py with authentication routes
Create tests/test_auth.py with auth tests
Update README.md with API documentation
```

**Best models:** qwen3:8b (for simple batches), mistral-nemo:12b (for complex batches)

## Controlling Agent Behavior

### Think Mode Behavior

**Observation:** Qwen3 models enter verbose thinking mode during code generation tasks.

**Understanding:**
- This is model behavior, not an Open Code CLI issue
- Build mode is already the **default** mode in Open Code CLI
- There is no `/no_think` flag (only `/thinking` toggle which enables more thinking)
- Tasks complete correctly despite verbosity

**Best Approach:**
- Accept the think mode as inherent to Qwen3 models with extended context
- The verbosity provides insight into model reasoning
- Consider it "free documentation" of the decision-making process
- Local models provide privacy benefits despite slower execution

**Alternative:** Use models with less thinking mode:
- Mistral Nemo 12B: Less verbose but **cannot create files** (analysis only)
- Granite 3.1 MoE: Controlled output but **cannot create files** (analysis only)
- Qwen3:8b or Qwen3:4b: May have less thinking (needs testing, should support file creation)

### Temperature and Sampling

While Open Code CLI may not expose these directly, you can control them via Ollama Modelfile:

```modelfile
FROM qwen3:8b
PARAMETER temperature 0.7
PARAMETER top_p 0.8
PARAMETER top_k 20
```

**For agent tasks:**
- **Lower temperature (0.3-0.5):** More deterministic, better for code generation
- **Higher temperature (0.7-0.9):** More creative, better for brainstorming
- **Recommended for non-thinking mode:** temp=0.7, top_p=0.8, top_k=20

### Context Window Management

**4k context (qwen3:4b):**
- Keep tasks focused on single files
- Avoid multi-file analysis
- Break complex tasks into smaller chunks

**8k context (qwen3:8b, mistral-nemo:12b):**
- Can handle 1-2 medium files simultaneously
- Suitable for most development tasks
- Good for refactoring single modules

**16k context (qwen3:8b-16k):**
- Can analyze 3-5 medium files
- Suitable for cross-module refactoring
- Better for architecture analysis
- Trades speed for comprehensive understanding

## Performance Benchmarks

Based on real-world usage with Open Code CLI:

| Task Type | qwen3:4b | qwen3:8b | qwen3:8b-16k | mistral-nemo:12b | granite3.1-moe |
|-----------|----------|----------|--------------|------------------|----------------|
| Simple file creation | 5-15s | 15-30s | 45-90s | 25-60s | 6-18s |
| Code review (1 file) | 10-25s | 20-45s | 60-120s | 40-90s | 15-35s |
| Multi-file analysis | N/A | 40-90s | 90-180s | 60-150s | 25-60s |
| Complex refactoring | N/A | 60-120s | 120-240s | 90-180s | 45-90s |
| Test generation | 15-30s | 30-60s | 60-120s | 45-90s | 20-45s |

**Notes:**
- Times include thinking mode overhead for Qwen3 models
- Claude API (cloud) is typically 3-10x faster for equivalent tasks
- Performance varies based on hardware (Apple Silicon M-series is optimal)

## Best Practices

### 1. Choose the Right Model for the Task
- **Quick edits:** qwen3:4b or granite3.1-moe
- **Standard development:** qwen3:8b or granite3.1-moe
- **Multi-file analysis:** qwen3:8b-16k
- **Best quality:** mistral-nemo:12b
- **Fast iteration:** granite3.1-moe

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

### 6. Leverage Batch Mode for Repetitive Tasks
```bash
# Create a tasks file
echo "Add type hints to models/user.py" > batch-tasks.txt
echo "Add type hints to models/product.py" >> batch-tasks.txt
echo "Add type hints to services/auth.py" >> batch-tasks.txt

# Run in batch
opencode --batch batch-tasks.txt
```

## Troubleshooting Agent Issues

### Agent Gets Stuck in Thinking Mode
**Symptoms:** Verbose analysis, slow response, excessive planning

**Understanding:**
- Build agent is already the default
- Thinking mode is a Qwen3 model behavior, not a mode setting
- Tasks complete successfully despite verbosity

**Best approach:**
- Accept the thinking mode as part of Qwen3 models
- Consider it "free documentation" of reasoning
- Switch to Mistral Nemo or Granite for less verbosity (but no file creation)

### Agent Loses Context
**Symptoms:** Forgets previous steps, contradicts earlier decisions

**Solutions:**
1. Use models with larger context windows (qwen3:8b-16k)
2. Break tasks into smaller, independent chunks
3. Explicitly reference earlier steps in prompts
4. Press Tab to switch to plan agent to establish clear plan before execution

### Agent Produces Low-Quality Code
**Symptoms:** Bugs, security issues, poor practices

**Solutions:**
1. Switch to higher-quality model (mistral-nemo:12b)
2. Provide more specific requirements
3. Use `/mode review` after generation to check quality
4. Ask agent to add tests and validation

### Agent is Too Slow
**Symptoms:** Long wait times, frustration with iteration speed

**Solutions:**
1. Use smaller models (qwen3:4b, granite3.1-moe)
2. Break tasks into smaller pieces
3. Use standard context when extended context isn't needed
4. Consider switching to cloud models (Claude API) for time-sensitive work

### Agent Hallucinates or Creates Invalid Code
**Symptoms:** References non-existent libraries, invalid syntax

**Solutions:**
1. Use lower temperature (via Modelfile)
2. Provide explicit examples of desired output
3. Switch to Mistral Nemo (less prone to hallucination)
4. Validate all generated code before committing

## When to Use Cloud Models vs Local Agents

### Use Local Models (Ollama + Open Code)
✅ Working offline
✅ Processing sensitive/proprietary code
✅ Running batch operations overnight
✅ Privacy requirements mandate local processing
✅ Learning/experimenting without API costs
✅ Tasks where speed is not critical

### Use Cloud Models (Claude API + Open Code)
✅ Real-time interactive development
✅ Complex multi-file operations requiring fast iteration
✅ Time-sensitive tasks
✅ Working with very large codebases (200k+ context)
✅ When you need the absolute best code quality
✅ When speed is more important than cost

## Advanced Agent Techniques

### Chaining Agents Across Models
Use different models for different steps:

```bash
# Step 1: Plan with extended context
opencode --model qwen3:8b-16k
> Analyze the codebase and create a refactoring plan

# Step 2: Execute with quality model
opencode --model mistral-nemo:12b
> Implement the refactoring plan from plan.md

# Step 3: Review with fast model
opencode --model granite3.1-moe
> Run tests and verify the refactoring
```

### Using Agents for Documentation
```bash
opencode --model qwen3:8b-16k
# Press Tab to switch to plan agent for analysis
> Analyze all Python files in src/ and create comprehensive API documentation in docs/
```

### Using Agents for Code Migration
```bash
opencode --model qwen3:8b-16k
# Build agent is default - ready for file creation
> Migrate all JavaScript files to TypeScript, preserving functionality
```

**Note:** Mistral Nemo cannot create files - use Qwen3 for code migration tasks.

## Resources

- [Open Code CLI Documentation](https://opencode.ai/docs)
- [Ollama Model Library](https://ollama.com/library)
- [Qwen3 Documentation](https://qwen.readthedocs.io/)
- [Local LLM Performance Guide](https://github.com/ggerganov/llama.cpp)

## Contributing

If you discover new agent patterns or workarounds for known issues, please contribute to this documentation!
