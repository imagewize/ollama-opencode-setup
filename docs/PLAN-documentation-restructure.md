# Documentation Restructure Plan

**Branch**: `docs/restructure`  
**Created**: 2026-07-01  
**Status**: Draft  

## Objectives

1. **Clarify context window defaults**: Document that Ollama uses 4K default context on M1 16GB and M4 24GB systems, and only 32GB+ RAM systems get larger defaults
2. **Split large documentation**: Break `docs/LOCALLLMS.md` (~850 lines) into focused, maintainable files
3. **Improve navigation**: Create logical information hierarchy with clear cross-references

---

## Problem Statements

### Issue 1: Missing Context Window Default Clarification

The Ollama documentation at https://docs.ollama.com/context-length#context-length states:
- Default context window is **4K** for systems with ≤24GB RAM (M1 16GB, M4 24GB)
- Larger defaults (8K, 16K+) only apply to systems with **32GB+ RAM**

**Current gap**: This repository's documentation does not explicitly state this, which could lead users to assume their M4 24GB system has a larger default context than it actually does.

**Impact**: Users may experience truncated context or OOM errors because they assume larger context is available by default.

### Issue 2: Monolithic LOCALLLMS.md

`docs/LOCALLLMS.md` is currently ~850 lines covering:
- Open Code configuration
- Custom model creation
- MLX runtime details
- Ollama commands reference
- Model selection guidelines
- Troubleshooting
- Context window explanations

**Problems**:
- Hard to navigate and maintain
- Mixes conceptual info with reference material
- Difficult to update individual sections
- Violates single-responsibility principle for docs

---

## Proposed Structure

### New Documentation Files

```
docs/
├── LOCALLLMS/                    # NEW: Split directory
│   ├── index.md                 # Overview and navigation
│   ├── configuration.md         # Open Code + Ollama setup
│   ├── custom-models.md         # Modelfiles and variants
│   ├── context-windows.md       # Context window explained (NEW - addresses Issue 1)
│   ├── mlx-runtime.md          # Mac-specific MLX details
│   ├── model-selection.md       # Guidelines and benchmarks
│   ├── commands.md              # Ollama commands reference
│   └── troubleshooting.md       # Common issues and solutions
│
├── LOCALLLMS.md                 # KEEP: Legacy redirect or remove
├── PROJECT-SETUP.md             # Existing
├── OPENCODE-COMMANDS.md         # Existing
├── TROUBLESHOOTING.md           # Existing
└── AGENTS.md                    # Existing
```

### File Content Mapping

| Current Section | New File | Notes |
|----------------|----------|-------|
| Open Code Configuration | `LOCALLLMS/configuration.md` | Current configuration details |
| Custom Model Creation | `LOCALLLMS/custom-models.md` | Modelfile examples, creation commands |
| Setting Context with Open Code | `LOCALLLMS/context-windows.md` | **NEW: Explicit 4K default clarification** |
| Context Window Reality Check | `LOCALLLMS/context-windows.md` | Move and expand with RAM-based defaults |
| MLX Runtime | `LOCALLLMS/mlx-runtime.md` | M4-specific details |
| Ollama Commands Reference | `LOCALLLMS/commands.md` | Command examples |
| Model Selection Guidelines | `LOCALLLMS/model-selection.md` | Benchmarks, recommendations |
| Troubleshooting | `LOCALLLMS/troubleshooting.md` | Split from main file |

---

## Context Window Documentation Changes

### Required Additions to `LOCALLLMS/context-windows.md`

**New section to add**:

```markdown
## Ollama Default Context Windows by System RAM

Ollama automatically sets the default context window based on available system RAM:

| System RAM | Default Context | Affected Systems |
|------------|----------------|------------------|
| ≤ 24GB | **4,096 tokens** | MacBook Pro M1 (16GB), Mac Mini M4 (24GB) |
| 32GB | 8,192 tokens | MacBook Pro M1 Max (32GB) |
| 48GB | 16,384 tokens | MacBook Pro M1 Max (48GB), M1 Ultra |
| 64GB+ | 32,768 tokens | Mac Studio, Mac Pro |

**Important**: This default applies to the base model as pulled from Ollama's registry.
The OpenAI-compatible endpoint (`/v1/chat/completions`) used by Open Code does NOT
respect per-request context parameters. To use extended context, you MUST create
custom variants with `num_ctx` baked in via Modelfiles.

### Why This Matters

Without explicit context configuration:
- Your M4 24GB Mac Mini runs ALL models at 4K context by default
- System prompts + tool definitions can consume 50-75% of this window
- This leaves insufficient space for meaningful agentic workflows
- Hence the need for custom 16K/32K variants in this repository

### Checking Your Default

```bash
# Show the baked num_ctx for a model
ollama show <model-name> --modelfile | grep num_ctx

# Without a custom variant, this shows the RAM-based default
# For most Apple Silicon Macs ≤24GB: PARAMETER num_ctx 4096
```
```

**Also update**:
- `LOCALLLMS/custom-models.md` - Reference the default context explanation
- `LOCALLLMS/model-selection.md` - Note which models have custom context baked in

---

## Implementation Steps

### Phase 1: Create New Structure (This PR)

1. ✅ Create branch `docs/restructure`
2. Create `docs/LOCALLLMS/` directory
3. Create `docs/LOCALLLMS/index.md` with overview and navigation
4. Create `docs/LOCALLLMS/context-windows.md` with explicit RAM-based defaults
5. Create remaining files by splitting `LOCALLLMS.md` content
6. Add deprecation notice to `docs/LOCALLLMS.md` (redirect to new structure)

### Phase 2: Update Cross-References

1. Update `README.md` to point to new structure
2. Update `docs/AGENTS.md` references to `LOCALLLMS.md` → `LOCALLLMS/model-selection.md`
3. Update `docs/PROJECT-SETUP.md` references
4. Update `docs/OPENCODE-COMMANDS.md` references
5. Update any examples that reference the old file

### Phase 3: Validation

1. Verify all external links still work
2. Verify `grep` finds all moved content
3. Check for broken internal links
4. Test documentation rendering (if applicable)

---

## File-by-File Breakdown

### `docs/LOCALLLMS/index.md` (NEW)

Purpose: Entry point for all local LLM documentation

Content outline:
- Overview of local LLM setup
- Quick navigation to all subtopics
- Prerequisites (Ollama installed, etc.)
- Link to project setup guide

### `docs/LOCALLLMS/configuration.md` (NEW)

Purpose: Open Code and Ollama configuration

Source sections from current `LOCALLLMS.md`:
- Open Code Configuration
- Current Configuration
- Available Models (all tables)
- Updating Configuration

Additional notes:
- Keep model tables intact
- Add note about context defaults pointing to context-windows.md

### `docs/LOCALLLMS/custom-models.md` (NEW)

Purpose: Creating custom variants with extended context

Source sections:
- Custom Model Creation (all creating sections)
- Benefits of Extended Context

Additional notes:
- Add explicit warning: "Base models from Ollama registry have 4K default on ≤24GB systems"
- Reference context-windows.md for the why

### `docs/LOCALLLMS/context-windows.md` (NEW)

Purpose: **Primary deliverable for Issue 1**

Content:
- New "Ollama Default Context Windows by System RAM" section (see above)
- Current "Context Window Reality Check" section (moved)
- Current "Setting Context with Open Code (why we bake num_ctx)" section (moved)
- Explain the OpenAI-compatible endpoint limitation
- Link to custom-models.md for the solution

### `docs/LOCALLLMS/mlx-runtime.md` (NEW)

Purpose: Mac-specific MLX runtime details

Source sections:
- MLX Runtime (Mac Mini M4 24GB+)
- Large Models on Mac Mini M4 Pro 24GB
- Raising the memory ceiling for dense MLX models
- Why Ollama's built-in MLX is enough
- Context and num_ctx on large models

### `docs/LOCALLLMS/model-selection.md` (NEW)

Purpose: Model selection guidelines and benchmarks

Source sections:
- Model Selection Guidelines
- Performance benchmarks table
- When to use local vs cloud models

### `docs/LOCALLLMS/commands.md` (NEW)

Purpose: Ollama commands reference

Source sections:
- Ollama Commands Reference
- All subsections (List Models, Run Model, Pull, Remove, Interactive)

### `docs/LOCALLLMS/troubleshooting.md` (NEW)

Purpose: Troubleshooting guide

Source sections:
- Troubleshooting
- All subsections (Ollama Not Running, Model Not Found, Out of Memory, etc.)

Note: Some troubleshooting content may belong in root `docs/TROUBLESHOOTING.md`. Review for duplication.

### `docs/LOCALLLMS.md` (MODIFIED)

Convert to a redirect/deprecation notice:

```markdown
# Local LLMs Documentation

> **Note**: This documentation has been restructured for better organization.
> Please see the new [Local LLMs section](./LOCALLLMS/index.md) for up-to-date information.

## Quick Links

- [Configuration](./LOCALLLMS/configuration.md)
- [Context Windows](./LOCALLLMS/context-windows.md) ← **NEW: RAM-based defaults explained**
- [Custom Models](./LOCALLLMS/custom-models.md)
- [Model Selection](./LOCALLLMS/model-selection.md)
- [Commands Reference](./LOCALLLMS/commands.md)
- [Troubleshooting](./LOCALLLMS/troubleshooting.md)
```

---

## Success Criteria

- [ ] `docs/LOCALLLMS/` directory exists with all 7 new files
- [ ] `docs/LOCALLLMS.md` contains deprecation notice
- [ ] `docs/LOCALLLMS/context-windows.md` explicitly documents 4K default for ≤24GB RAM
- [ ] All content from original `LOCALLLMS.md` is preserved (no information loss)
- [ ] No broken internal links
- [ ] All cross-references updated
- [ ] Branch `docs/restructure` contains all changes

---

## Out of Scope

- Creating new Modelfiles (unless needed for context window testing)
- Updating `opencode.json` (unless adding context-related configuration)
- Changing model recommendations
- Updating benchmark data

---

## Next Steps

After this plan is approved:

1. Create the `docs/LOCALLLMS/` directory
2. Create each new file with content from the mapping above
3. Add the context window clarification as the first section in `context-windows.md`
4. Update all cross-references in other documentation files
5. Test the new structure by verifying all information is accessible
6. Commit changes with message: `docs: restructure LOCALLLMS.md into focused sub-files, add context window RAM defaults`
