# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

---

## [1.0.3] — 2026-06-01

### Added
- `modelfiles/qwen3-8b-16k.Modelfile` — reproducible build definition (`FROM qwen3:8b` + `PARAMETER num_ctx 16384`) for the `qwen3:8b-16k` custom model; mirrors the committed Modelfile pattern established for `ministral-3:8b-16k`. Previously this model was created interactively via `ollama run qwen3:8b` + `/save`, which is not reproducible from the repo alone.
- `modelfiles/README.md` — documents the purpose of the directory, explains why baked-in `num_ctx` is required, lists both current Modelfiles with their build commands, and provides a short guide for adding new variants.

### Changed
- `CLAUDE.md`: unified the Extended Context Models section to show both `qwen3:8b-16k` and `ministral-3:8b-16k` as Modelfile-based builds; removed the interactive `/save` instructions.
- `README.md`: updated "Creating Custom Models" to list both Modelfile build commands; removed the "Alternative — interactive /save" block that previously described `qwen3:8b-16k`.
- `docs/LOCALLLMS.md`: replaced the interactive `/save` flow in the "Creating Qwen3 8B with Extended Context (16k)" section with the `ollama create` Modelfile command; updated verification output.

---

## [1.0.2] — 2026-06-01

### Changed
- `docs/AGENTS.md` — corrected model capability ratings: removed `mistral-nemo` and `granite3.1-moe` from agent suitability table (they have no tool use and cannot create files); added `ministral-3:8b` and `ministral-3:8b-16k` as the recommended agent models; removed fake `opencode --batch` and `opencode --model` CLI flags from workflow patterns; removed speculative "Other Modes" section; updated performance benchmarks and best-practice recommendations to lead with Ministral-3
- `docs/LOCALLLMS.md` — removed fake `opencode run --model` CLI invocations from the Slow Performance troubleshooting section; replaced with TUI-based guidance; updated performance table for file writes (removed `granite3.1-moe` which cannot write files, added Ministral-3 variants); updated think-mode alternatives to lead with `ministral-3:8b` as the correct solution
- `docs/OPENCODE-COMMANDS.md` — removed non-existent `--batch` flag from Command-Line Arguments; added `--continue` and `--agent` flags (confirmed via `opencode --help`); updated Build Agent model list to include `ministral-3:8b-16k` and `ministral-3:8b` as confirmed and recommended; removed "only Qwen3 models have tool usage" claim (outdated); updated Common Workflows, Tips, and Troubleshooting sections to reflect current model landscape
- `examples/refactoring.md` — replaced all `mistral-nemo` model recommendations with `ministral-3:8b-16k` or `qwen3:8b`; mistral-nemo cannot write files so all refactoring tasks would have silently failed
- `examples/batch-processing.md` — replaced `mistral-nemo` in all file-writing script templates (JSDoc generation, test generation, class component conversion, WordPress block customization) with `qwen3:8b`; updated Tips and performance table to lead with `ministral-3:8b` as the recommended fast option
- `examples/multi-file-analysis.md` — fixed typo in model name (`mistral-nemo:12b-instruct-2407-q4_K_M-instruct-2407-q4_K_M`); replaced alternative model recommendation with `ministral-3:8b-16k` (confirmed tool use)

---

## [1.0.1] — 2026-06-01

### Added
- `docs/README.md` — comprehensive documentation index with overview table, getting started guide, quick reference for models and commands, detailed documentation structure, common workflows, search tips, and pro tips

### Changed
- `.vibe/prompts/vibe.md` — added requirement to always create a new branch for commits (never commit directly to main); clarified that atomic commits can be per logical group or single file depending on change size; reinforced atomic commit rule in NO Mistral Vibe Attribution section

---

## [1.0.0] — 2026-06-01

### Added
- `docs/AGENTS.md`: new "How OpenCode Works: The Agentic Loop" section — explains that OpenCode (and Claude Code) are agentic frameworks that wrap a model with tool definitions and an execution layer; the model emits structured tool calls, the framework executes them; contrasts with raw `ollama run` which has no execution layer
- `.vibe/config.toml` and `.vibe/prompts/vibe.md` — Vibe CLI configuration committed to the repo (mirrors the pattern of tracking `.claude/`); `vibe.md` provides Vibe-specific repo guidance equivalent to `CLAUDE.md`

### Changed
- `TROUBLESHOOTING-OPENCODE.md` → `docs/TROUBLESHOOTING.md`: moved into `docs/` for consistency with other documentation; all cross-references updated in `README.md` and `CLAUDE.md`
- `create-pr.sh` → `scripts/create-pr.sh`: moved into `scripts/` alongside `tool-call-test.sh`; removed from `.gitignore` (the file contains no secrets) so it is now tracked
- `CLAUDE.md`: documentation structure section updated to reference `docs/TROUBLESHOOTING.md` and note the agentic loop content in `docs/AGENTS.md`
- `README.md`: troubleshooting section now links to `docs/TROUBLESHOOTING.md`

---

## [0.5.2] — 2026-05-31

### Added
- `docs/LOCALLLMS.md`: new "Setting Context with Open Code (why we bake num_ctx)" section — explains that Open Code's OpenAI-compatible (`/v1`) endpoint ignores `num_ctx`, so it can't be set via `opencode.json`; documents the Modelfile vs `OLLAMA_CONTEXT_LENGTH` env-var trade-off and why this repo bakes context per-model. References upstream feature request [opencode#3250](https://github.com/anomalyco/opencode/issues/3250)

### Changed
- `docs/LOCALLLMS.md`: Table of Contents now lists the "Creating Ministral 3 8B with Extended Context (16k)" subsection (previously missing) and the new context section

---

## [0.5.1] — 2026-05-31

### Changed
- `README.md`: Performance Tips and the performance table now recommend `ministral-3:8b-16k` (not the base model) for Open Code, matching the Available Models table; "Creating Custom Models" now leads with the reproducible Modelfile build and keeps the interactive `/save` flow as an alternative
- `RECOMMENDATIONS.md`: added a 2026-05-31 update banner noting the "Only Qwen3 has tool usage" conclusion is outdated (Ministral 3 8B also has tool calling and is faster); the 2025-11-18 content is retained as a historical record

---

## [0.5.0] — 2026-05-31

### Added
- `ministral-3:8b-16k` — custom 16k-context variant of `ministral-3:8b`, built from a committed Modelfile (`modelfiles/ministral-3-8b-16k.Modelfile`); added to `opencode.json` as the recommended model for Open Code
- `modelfiles/ministral-3-8b-16k.Modelfile` — reproducible build definition (`FROM ministral-3:8b` + `PARAMETER num_ctx 16384`)

### Changed
- `opencode.json`: `ministral-3:8b-16k` is now the recommended entry; base `ministral-3:8b` relabeled "default context"
- `docs/LOCALLLMS.md`: added the 16k variant to the Available Models table and a "Creating Ministral 3 8B with Extended Context (16k)" section
- `README.md`: models table and Quick Start updated to build/use the 16k variant
- `CLAUDE.md`: model lists and Extended Context Models section document the new variant

### Notes
- Open Code uses Ollama's OpenAI-compatible endpoint, which does not pass `num_ctx`. Without a baked-in variant, `ministral-3:8b` runs at Ollama's small default (~4k) inside Open Code — too small for agentic tool loops. The 16k variant fixes this, mirroring the existing `qwen3:8b-16k` pattern
- 16k chosen as the safe sweet spot on M1 16GB (~8GB footprint); the base model natively supports up to 256k but that would swap on 16GB
- `ministral-3:8b-16k` re-tested 2026-05-31: tool use confirmed (✅ PASS)

---

## [0.4.0] — 2026-05-31

### Added
- `ministral-3:8b` entry in `opencode.json` — **confirmed tool use, recommended daily driver**
- `deepseek-coder-v2:16b` entry in `opencode.json` — read-only (no tool support), kept as a tested record
- `scripts/tool-call-test.sh` — reproducible tool-calling smoke test that sends a `write`-tool request to Ollama's OpenAI-compatible endpoint (the same API Open Code uses) and checks for a valid `tool_calls` response

### Changed
- `README.md`: corrected the "only Qwen3 can use tools" claim — now leads with `ministral-3:8b` as the recommended tool-capable model; updated the Available Models table, Quick Start pull step, Performance Tips, and performance expectations
- `docs/LOCALLLMS.md`: added `ministral-3:8b` and `deepseek-coder-v2:16b` to the Available Models table; reworked Model Selection Guidelines and performance benchmarks around the new results; documented the testing method
- `test-opencode.md`: added tool-call results for `ministral-3:8b`, `deepseek-coder-v2:16b`, and a `qwen3:8b` baseline; updated the comparison matrix

### Test Results
- `ministral-3:8b` — tested 2026-05-31 on M1 16GB: **tool use confirmed**, emits valid `write` tool_call in ~7s cold / **~4s warm**; no think-mode overhead (~6× faster than `qwen3:8b` on the same task)
- `deepseek-coder-v2:16b` — tested 2026-05-31 on M1 16GB: **no tool use support**; Ollama returns `does not support tools`. Fits RAM (8.9 GB, MoE) and is fast, but it is a code-completion/FIM model with no tool calling
- `qwen3:8b` — tested 2026-05-31 on M1 16GB: **tool use confirmed** (~26s, think-mode overhead)

### Notes
- Ministral 3 8B directly addresses the "only Qwen3 8B 16K works" limitation — it is newer than Qwen3, passes tool calling, and is substantially faster
- Capability ≠ size: DeepSeek-Coder-V2-Lite fits and is fast yet lacks tool calling entirely, confirming that a model must be trained/templated for tools to work in Open Code
- `gemma4:e4b`, `granite3.1-moe`, and `mistral-nemo` were removed from local Ollama storage during this session (non-performing); their `opencode.json` entries remain as historical records

---

## [0.3.0] — 2026-05-31

### Changed
- `opencode.json`: updated display names for `phi4:latest` and `gemma4:e4b` from "untested" to "read-only"
- `CLAUDE.md`: moved `gemma4:e4b` from untested to read-only confirmed; no untested models remain
- `docs/LOCALLLMS.md`: updated model table and guidelines to reflect all models now tested

### Test Results
- `phi4:latest` — tested 2026-05-31 on M1 16GB: **no tool use support**, Open Code CLI explicitly reports "does not support tools"
- `gemma4:e4b` — tested 2026-05-31 on M1 16GB: **no tool use support**, attempts tool call but sends malformed call; file not created (~60s)

### Notes
- All models in `opencode.json` are now tested — no untested entries remain
- Only `qwen3:8b-16k`, `qwen3:8b`, and `qwen3:4b` have confirmed tool use support
- `gemma4:e4b` differs from other failing models — it attempts tool calls but with a format incompatible with Open Code CLI

---

## [0.2.0] — 2026-05-31

### Added
- Tool use column to the Available Models table in `docs/LOCALLLMS.md` — clarifies which models can create/modify files vs. read-only
- `gemma4:e4b`, `phi4:latest`, `qwen3.5:4b` entries in `opencode.json` — pulled but untested, tool use status unknown
- `qwen3.5:9b` entry in `opencode.json` — pulled and tested; kept in config as historical record

### Changed
- `opencode.json`: added Qwen3.5, Gemma 4, and Phi-4 model entries; marked Mistral Nemo and Granite as read-only in display names
- `docs/LOCALLLMS.md`: updated Model Selection Guidelines with M1 16GB-specific recommendations, performance benchmarks, and tool use guidance
- `CLAUDE.md`: updated model list and recommendations to reflect 2026 model landscape

### Test Results
- `qwen3.5:9b` — tested 2026-05-31 on M1 16GB: **no tool use support**, outputs bash instead of using write tool; 13+ min for analysis tasks — not recommended
- `qwen3.5:4b` — tested 2026-05-31 on M1 16GB: **no tool use support**, outputs bash instead of using write tool; entire Qwen3.5 family confirmed read-only in Open Code CLI

### Notes
- Mistral Nemo 12B and Granite 3.1 MoE remain in the config but are designated read-only — they cannot create or modify files in Open Code CLI
- Models above 12B are not recommended for M1 16GB (will cause heavy swap or fail to load)
- The entire Qwen3.5 family (9b, 4b) lacks tool use support in Open Code CLI — Qwen3 (8b-16k, 8b, 4b) remains the only confirmed working series
- `gemma4:e4b` and `phi4:latest` are in config but untested — validation pending

---

## [0.1.0] — 2025-11-01

### Added
- Initial repository setup with Open Code CLI configuration for Ollama
- `opencode.json` with Qwen3 8B, Qwen3 8B-16k, Qwen3 4B, Mistral Nemo 12B, Granite 3.1 MoE
- `docs/LOCALLLMS.md` — local LLM setup and troubleshooting guide
- `docs/AGENTS.md` — agent workflow patterns for Open Code CLI
- `docs/OPENCODE-COMMANDS.md` — complete slash command reference
- `examples/` — code review, refactoring, multi-file analysis, and batch processing workflows
- `test-opencode.md` — validation and benchmark test suite
- Custom model creation pattern: `qwen3:8b-16k` with 16k context via `ollama run` + `/save`
