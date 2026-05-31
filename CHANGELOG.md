# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Test Results
- `phi4:latest` — tested 2026-05-31 on M1 16GB: **no tool use support**, Open Code CLI explicitly reports "does not support tools"

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
