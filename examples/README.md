# Examples Directory

This directory contains practical examples and workflows for using Open Code CLI with local Ollama models.

## Available Examples

### [Code Review](code-review.md)
Example prompts and workflows for code review tasks:
- Quick code review
- Multi-file review
- Security review
- Performance review
- Accessibility review
- Interactive review sessions

**Best models:** `mistral-nemo:12b-instruct-2407-q4_K_M`, `qwen3:8b`, `qwen3:8b-16k`

### [Refactoring](refactoring.md)
Example prompts and workflows for refactoring tasks:
- Simple refactoring (extract function, rename, simplify)
- TypeScript migration
- React refactoring (components, hooks, props)
- Code organization
- Remove code duplication
- Modernize code (ES6+, async/await)
- Performance refactoring
- Design patterns

**Best models:** `mistral-nemo:12b-instruct-2407-q4_K_M`, `qwen3:8b`

### [Multi-File Analysis](multi-file-analysis.md)
Example prompts and workflows for analyzing multiple related files:
- Feature analysis (3-5 related files)
- Component relationships
- Architecture review
- Configuration analysis
- Cross-file consistency
- Data flow analysis
- Dependencies analysis
- WordPress theme analysis

**Best model:** `qwen3:8b-16k` (extended context)

### [Batch Processing](batch-processing.md)
Scripts and workflows for processing multiple files in batch mode:
- Documentation generation
- Test generation
- Code modernization
- Consistency enforcement
- Migration tasks
- Internationalization
- Parallel processing
- Template-based generation

**Best models:** `qwen3:4b` (fast), `qwen3:8b` (balanced), `mistral-nemo:12b-instruct-2407-q4_K_M` (complex)

## Quick Reference: Which Example to Use?

| Task | Example File | Best Model |
|------|--------------|------------|
| Review single file for bugs | [code-review.md](code-review.md) | `mistral-nemo:12b-instruct-2407-q4_K_M` |
| Review multiple related files | [code-review.md](code-review.md) | `qwen3:8b-16k` |
| Refactor single component | [refactoring.md](refactoring.md) | `qwen3:8b` |
| Migrate JS to TypeScript | [refactoring.md](refactoring.md) | `mistral-nemo:12b-instruct-2407-q4_K_M` |
| Analyze authentication flow (3-5 files) | [multi-file-analysis.md](multi-file-analysis.md) | `qwen3:8b-16k` |
| Understand component relationships | [multi-file-analysis.md](multi-file-analysis.md) | `qwen3:8b-16k` |
| Generate tests for 10 files | [batch-processing.md](batch-processing.md) | `mistral-nemo:12b-instruct-2407-q4_K_M` |
| Add JSDoc to many files | [batch-processing.md](batch-processing.md) | `qwen3:8b` |
| Quick formatting fixes | [batch-processing.md](batch-processing.md) | `qwen3:4b` |

## Model Selection Guide

### `qwen3:4b` (2.5 GB)
**Best for:**
- Quick, simple tasks
- Batch processing (fastest)
- Formatting and style fixes
- Simple renaming operations

**Performance:** 5-15s per task

### `qwen3:8b` (5.2 GB)
**Best for:**
- General development tasks
- Single file refactoring
- Code reviews
- Documentation generation
- Balanced speed/quality

**Performance:** 15-30s per task

### `qwen3:8b-16k` (5.2 GB)
**Best for:**
- Multi-file analysis (3-5 files)
- Feature analysis across files
- Architecture review
- Cross-file consistency checks
- Component relationship analysis

**Context:** 16k tokens (~12,000 words, 3-5 medium files)
**Performance:** 45-90s per task

### `mistral-nemo:12b-instruct-2407-q4_K_M` (7.5 GB)
**Best for:**
- Complex code generation
- TypeScript migration
- Detailed refactoring
- Security analysis
- Test generation
- Best instruction following

**Performance:** 25-60s per task

### `granite3.1-moe:latest` (2.0 GB)
**Best for:**
- Quick tasks with variety
- Efficient MoE architecture
- Resource-constrained environments

**Performance:** 6-18s per task

## Usage Patterns

### Interactive Development
```bash
cd your-project
opencode

# Then follow prompts in the examples
```

### One-off Commands
```bash
# Use examples as templates
opencode run "Review src/App.tsx for bugs and improvements" --model ollama/mistral-nemo:12b-instruct-2407-q4_K_M
```

### Batch Scripts
```bash
# Copy batch processing examples
cp examples/batch-processing.md my-batch-script.sh
chmod +x my-batch-script.sh
./my-batch-script.sh
```

## Tips for Using Examples

1. **Customize prompts:**
   - Replace file paths with your actual files
   - Adjust requirements to match your project
   - Add project-specific constraints

2. **Start simple:**
   - Try examples with single files first
   - Gradually increase complexity
   - Test on non-critical code

3. **Iterate:**
   - Use examples as starting points
   - Refine based on results
   - Build your own prompt library

4. **Combine examples:**
   - Use code review + refactoring together
   - Analyze then batch process
   - Review then document

5. **Track what works:**
   - Save successful prompts
   - Note which models work best for your use cases
   - Create project-specific example files

## Performance Expectations

### Single File Operations
| Task | Model | Time |
|------|-------|------|
| Quick review | `qwen3:8b` | 15-30s |
| Detailed review | `mistral-nemo:12b-instruct-2407-q4_K_M` | 25-45s |
| Simple refactor | `qwen3:8b` | 20-40s |
| Complex refactor | `mistral-nemo:12b-instruct-2407-q4_K_M` | 30-60s |

### Multi-File Operations
| Task | Files | Model | Time |
|------|-------|-------|------|
| Feature analysis | 3-5 | `qwen3:8b-16k` | 45-90s |
| Architecture review | 4-6 | `qwen3:8b-16k` | 60-120s |

### Batch Operations
| Task | Files | Model | Time |
|------|-------|-------|------|
| Add types | 10 | `qwen3:8b` | 2.5-3.5 min |
| Generate tests | 10 | `mistral-nemo:12b-instruct-2407-q4_K_M` | 6.5-10 min |
| Format code | 10 | `qwen3:4b` | 1.5-2 min |

## Local vs Cloud

**Use local models (examples in this directory) when:**
- Working offline
- Processing sensitive code
- Running batch operations overnight
- Learning and experimenting
- Privacy is a requirement

**Use cloud models (Claude Code) when:**
- Real-time interactive development
- Very large codebases (10+ files at once)
- Time-sensitive tasks
- Complex cross-codebase analysis
- Speed > cost

## Contributing Examples

Have a useful workflow? Please contribute!

1. Follow the existing format
2. Include:
   - Clear description
   - Best model recommendation
   - Example commands
   - Expected performance
   - Tips and gotchas
3. Submit a pull request

## Additional Resources

- [Main Documentation](../docs/LOCALLLMS.md)
- [Open Code Documentation](https://opencode.ai/docs)
- [Ollama Model Library](https://ollama.ai/library)
