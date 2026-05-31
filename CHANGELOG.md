# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- `qwen3.5:9b` — now the recommended model for M1 16GB; 32k context, tool use support, best quality/speed ratio
- `gemma4:e4b` — high-efficiency alternative with 32k context and tool use support
- `phi4` — strong reasoning and coding model with 16k context and tool use support
- `qwen3.5:4b` — fast general-purpose model with 32k context and tool use support
- Tool use column to the Available Models table in `docs/LOCALLLMS.md` — clarifies which models can create/modify files vs. read-only

### Changed
- `opencode.json`: added Qwen3.5, Gemma 4, and Phi-4 model entries; marked Mistral Nemo and Granite as read-only in display names
- `docs/LOCALLLMS.md`: updated Model Selection Guidelines with M1 16GB-specific recommendations, performance benchmarks, and tool use guidance
- `CLAUDE.md`: updated model list and recommendations to reflect 2026 model landscape

### Notes
- Mistral Nemo 12B and Granite 3.1 MoE remain in the config but are designated read-only — they cannot create or modify files in Open Code CLI
- Models above 12B are not recommended for M1 16GB (will cause heavy swap or fail to load)

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
