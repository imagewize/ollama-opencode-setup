# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

---

## [1.4.1] — 2026-06-30

### Added
- `modelfiles/qwen3-coder-30b-32k.Modelfile` (new): 32k-context variant of `qwen3-coder` (30B MoE) for Open Code on Mac Mini M4 Pro 24GB. Needed because the base `qwen3-coder:30b` has no `num_ctx` baked in, so it runs at Ollama's 4k default inside Open Code despite the architecture's native 256k — effectively less context than `ministral-3:8b-32k`
- `opencode.json`: added `qwen3-coder:30b-32k` to the Ollama provider and relabeled the base `qwen3-coder:30b` to note it runs at 4k in Open Code

### Changed
- `CLAUDE.md`, `docs/LOCALLLMS.md`, `modelfiles/README.md`: the recommended no-GPU-tuning M4 24GB model is now `mistral-small3.2:24b-32k` (100% GPU at the default ceiling). `qwen3-coder:30b-32k` is reclassified as the coding-MoE option that **requires** raising `iogpu.wired_limit_mb` — corrects the prior claim that `qwen3-coder:30b` "fits within the 17.3 GiB ceiling"

### Test Results
- `qwen3-coder:30b-32k` — tested 2026-06-30 on Mac Mini M4 Pro 24GB. At the **default** GPU ceiling it spills to CPU at every context: 16k → 12% CPU (20 GB), 24k → 15% CPU (21 GB), 32k → 19% CPU (21 GB). After `sudo sysctl -w iogpu.wired_limit_mb=21504` + Ollama restart, the 32k variant runs **98% GPU** (2% CPU, 21 GB). The 18 GB of MoE weights crowd the ~17.3 GiB wired limit, so any KV cache spills without the raised limit. Tool use confirmed, ~34.5 tok/s warm.

---

## [1.4.0] — 2026-06-30

### Added
- `modelfiles/mistral-small3.2-24b-32k.Modelfile` (new): 32k-context variant of `mistral-small3.2` (24B) for Open Code on Mac Mini M4 Pro 24GB — loads 100% GPU at 19 GB, tool use confirmed
- `modelfiles/mistral-small3.2-24b-64k.Modelfile` (new): 64k variant, **marked not-recommended** — loads at 25 GB and spills 22% to CPU on a 24GB M4 even with `iogpu.wired_limit_mb=21504`
- `opencode.json`: added `mistral-small3.2:24b-32k` to the Ollama provider
- `docs/TROUBLESHOOTING.md`: new "A tool-capable model returns prose instead of calling the tool" section — documents that `mistral-small3.2` refuses with prose when a tool schema's path description says "absolute path," with the before/after diagnosis table
- `README.md`, `CLAUDE.md`, `docs/LOCALLLMS.md`, `modelfiles/README.md`: added `mistral-small3.2:24b-32k` to the M4 24GB tables/recommendations and the build command, plus the 64k CPU-spillover caveat

### Fixed
- `scripts/tool-call-test.sh`: changed the `write` tool's `filePath` description from `"Absolute path of the file to write"` to `"Path of the file to write"`. The word "absolute" caused `mistral-small3.2` to refuse the task as prose (false negative); the neutral wording is also more representative of how Open Code calls the write tool.

### Test Results
- `mistral-small3.2:24b-32k` — tested 2026-06-30 on Mac Mini M4 Pro 24GB: **✅ PASS** tool call, 100% GPU at 19 GB, 32k context. Earlier "FAIL — returned prose" verdict was a false negative from the test script's `"Absolute path"` schema wording, not a real tool-use limitation (warm model, 100% GPU during every failure — not cold-vs-warm).
- Root-cause isolation (warm, identical request, only `filePath` description changed): `"Absolute path of the file to write"` → 3/3 prose refusals; `"Path of the file to write"` → 3/3 ✅ tool calls.
- `mistral-small3.2:24b-64k` — loads at 25 GB with 22%/78% CPU/GPU split (wired limit 21504); tool call technically passes but at **0.1 tok/s (902 s)** — unusable. Use the 32k variant.

---

## [1.3.1] — 2026-06-28

### Changed
- `docs/LOCALLLMS.md`: updated "Large Models on Mac Mini M4 Pro 24GB" section — added memory ceiling explanation (17.3 GiB available vs 18.4 GiB required for dense 27B); updated recommended models tables with warm/cold throughput; documented that `qwen3.6:27b-mlx` loads once the GPU wired limit is raised
- `README.md`: added `qwen3.6:27b-mlx` to M4 24GB table — loads with raised `iogpu.wired_limit_mb`, ~9.3 tok/s warm
- `CLAUDE.md`: marked `qwen3.6:27b-mlx` as "fits only with raised GPU limit" and added warm throughput to the M4 24GB recommendations

### Added
- `docs/LOCALLLMS.md`: "Raising the memory ceiling for dense MLX models" — documents the `iogpu.wired_limit_mb` sysctl to lift the default ~17.3 GiB GPU ceiling on a 24GB M4 (e.g. `sudo sysctl -w iogpu.wired_limit_mb=21504`), including the gotcha that Ollama caches the available-memory figure at startup and must be restarted to pick up the new limit, plus caveats (non-persistent, OS headroom, KV-cache budget)

### Fixed
- `scripts/tool-call-test.sh`: error reporting — previously any non-success response (model not installed, GPU OOM, unreachable server) surfaced as the cryptic `RESULT: ⚠️  __ERR__:'choices'`. The script now inspects the HTTP status and the API `error` field, prints the real message, and adds actionable hints (`ollama pull <model>` for missing models; raise `iogpu.wired_limit_mb` for OOM). Transport failures now report the unreachable endpoint instead of a Python `KeyError`. Made the `curl` call `set -e`-safe so it reaches the handler instead of aborting silently.

### Test Results
- `qwen3-coder:30b` — tested 2026-06-28 on Mac Mini M4 Pro 24GB: **✅ PASS** tool call. **~34.5 tok/s warm** (~4.8 tok/s on the first cold load, which includes reading 18 GB into GPU memory). MoE (3.3B active) fits within the default 17.3 GiB ceiling; recommended default.
- `qwen3.6:27b-mlx` — at the **default** GPU limit: **OOM** (requires 18.4 GiB > 17.3 GiB available). After `sudo sysctl -w iogpu.wired_limit_mb=21504` **and an Ollama restart**: **✅ PASS**, **~9.3 tok/s warm** (~3.3 tok/s cold). The dense 27B loads but runs ~3.7× slower than the MoE.
- `qwen3.6:27b-mlx-16k` — same as above: OOM at default, **✅ PASS** after raising the wired limit + restart (~2.6 tok/s cold).
- Note on measurement: `scripts/tool-call-test.sh` divides completion tokens by total wall-clock time, so a cold run's rate is dominated by model-load time, not generation. Warm (model-resident) rates above reflect actual throughput.
- Key finding: the 17.3 GiB ceiling is macOS's default GPU wired-memory limit (`iogpu.wired_limit_mb`), not a hard Ollama cap. Raising it lets dense 27B MLX models load on a 24GB M4 — but the MoE `qwen3-coder:30b` remains far faster (~34 vs ~9 tok/s) and needs no tuning.

### Context
- Qwen 3.6 27B (released April 2026) scores 77.2% on SWE-bench Verified and was the best available MLX coding candidate on Ollama. No `qwen3-coder` MLX variant exists.
- Ollama reserves OS headroom leaving ~17.3 GiB available on a 24GB M4. Dense 27B MLX models at Q5/Q6 precision sit at 18–20 GiB and cannot load. MoE models like `qwen3-coder:30b` bypass this because only active parameters (3.3B) are loaded at inference time.
- `qwen3.6:27b-mlx` runs on MLX — but so does `qwen3-coder:30b` (Ollama uses MLX for all Apple Silicon inference). The constraint is quantization size, not the inference framework.

---

## [1.3.0] — 2026-06-28

### Changed
- `opencode.json`: removed `mlx` provider block (separate `mlx_lm.server` on port 8080); added `qwen3-coder:30b`, `qwen3.5:27b-mlx`, and `qwen3.5:latest` to the Ollama provider
- `docs/LOCALLLMS.md`: replaced "MLX Runtime (Mac Mini M4 24GB+)" section with "Large Models on Mac Mini M4 Pro 24GB" — documents Ollama-native approach using built-in MLX engine; no separate server needed. Reorganized available models table by hardware (M1 16GB / M4 24GB / read-only)
- `README.md`: replaced MLX models section (via `mlx_lm.server`) with Ollama-native large model table for M4 24GB
- `CLAUDE.md`: updated Mac Mini M4 24GB recommendations to `qwen3-coder:30b` (recommended) and `qwen3.5:27b-mlx`; removed `mlx_lm.server` reference

### Removed
- Separate MLX server setup (`mlx_lm.server` on port 8080, `~/mlx-env` venv, HuggingFace model cache for `Jackrong/MLX-Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled-v2-4bit`)

### Context
- Ollama's built-in MLX engine now handles Apple Silicon natively with Metal-backed acceleration — the separate `mlx_lm.server` approach is superseded. Models tagged `-mlx` on Ollama use this engine automatically.
- `qwen3-coder:30b`: coding-optimized MoE (30B total / 3.3B active), 19 GB, 256k context, tool use pending test (awaiting macOS Tahoe update on Mac Mini M4 24GB)
- `qwen3.5:27b-mlx`: 20 GB, 256k context, served via Ollama's built-in MLX engine, pending test

---

## [1.2.2] — 2026-06-28

### Changed
- `scripts/tool-call-test.sh`: added tokens-per-second reporting — extracts `usage.completion_tokens` from the response and divides by elapsed seconds; prints `n/a` gracefully when the endpoint omits `usage`

### Test Results
- `Jackrong/MLX-Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled-v2-4bit` — tested 2026-06-28 on Mac Mini M4 Pro 24GB: **9.9 tok/s** (89 completion tokens, 9s, tool use ✅ PASS)

---

## [1.2.1] — 2026-06-28

### Changed
- `docs/LOCALLLMS.md`: updated MLX model table — tool use status changed from TBD to ✅ Yes for `Jackrong/MLX-Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled-v2-4bit`
- `README.md`: updated MLX model table — tool use status changed from TBD to ✅
- `CLAUDE.md`: added "tool use confirmed" to the 27B MLX model recommendation for Mac Mini M4 24GB

### Test Results
- `Jackrong/MLX-Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled-v2-4bit` — tested 2026-06-28 on Mac Mini M4 Pro 24GB via `mlx_lm.server` (port 8080): **tool use confirmed** (✅ PASS, 182s cold/first load); model emitted valid `write` tool_call via `scripts/tool-call-test.sh`

---

## [1.2.0] — 2026-06-28

### Added
- `docs/LOCALLLMS.md`: new "MLX Runtime (Mac Mini M4 24GB+)" section — covers `mlx-lm` installation in a venv, pulling pre-converted MLX models from HuggingFace, starting `mlx_lm.server` on port 8080, testing tool-call capability against the MLX endpoint, and a table of available MLX model variants (4-bit, 6-bit). Added to Table of Contents.
- `opencode.json`: new `mlx` provider block pointing to `http://localhost:8080/v1`; includes `Jackrong/MLX-Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled-v2-4bit` (262k context, Claude Opus 4.6 reasoning distillate, ~12 GB at MLX 4-bit). Open Code selects this model when the MLX server is running; falls back to Ollama models when it is not.

### Changed
- `scripts/tool-call-test.sh`: added optional third argument `[endpoint]` (default: `http://localhost:11434/v1/chat/completions`) so the smoke test can target the MLX server or any other OpenAI-compatible endpoint. Usage comment and example updated.
- `README.md`: split the Available Models table into two sections — "Ollama models" (M1 16GB, existing) and "MLX models" (Mac Mini M4 24GB+, new); added `qwen3.5:latest` row with tool use confirmed (Mac Mini M4, 2026-06-28, ~18s); added 27B MLX reasoning distillate row with link to the new LOCALLLMS.md section.
- `CLAUDE.md`: added "Mac Mini M4 Pro 24GB, tested 2026-06-28" recommendations block alongside the existing M1 16GB block; documents `qwen3.5:latest` (Ollama) and the 27B MLX distillate as the recommended models for that machine; notes the `~/mlx-env` venv and port 8080 server requirement.

### Context
- Machine: Apple M4 Pro 12-core, 24 GB unified memory (Mac Mini)
- `qwen3.5:latest` — tested 2026-06-28 on Mac Mini M4 24GB via Ollama: **tool use confirmed** (✅ PASS, ~18s); previously marked read-only based on M1 16GB tests of `qwen3.5:9b`
- `Jackrong/MLX-Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled-v2-4bit` — **tool use confirmed** (✅ PASS, 182s cold/first load); llmfit scores 92.9/100 on M4 24GB, Perfect GPU fit, est. 13.6 tok/s warm

---

## [1.1.3] — 2026-06-01

### Removed
- `RECOMMENDATIONS.md`: deleted — the file was already banner-flagged as outdated, and all current content lives in `README.md`, `docs/TROUBLESHOOTING.md`, `docs/OPENCODE-COMMANDS.md`, and `CHANGELOG.md`. Its only unique content (the 2025-11-18 Ollama-vs-LM-Studio comparison) was dropped as the decision is settled

### Changed
- `README.md`: removed duplication between the two model tables and the two doc tables. The "Important: Tool Usage" and "Available Models" tables are merged into one — the tool-use warning is now a callout above a single table whose `Tool Use` column carries the ✅/❌ verdict. "What's Included" now lists only non-doc assets (with one `docs/` row pointing to the Documentation index) so docs are no longer listed twice

---

## [1.1.2] — 2026-06-01

### Changed
- `README.md`: complete rewrite as a lean overview — removed sections that duplicated doc content (Common Commands, Creating Custom Models, Performance Tips, When to Use Local vs Cloud, Troubleshooting, Resources); fixed "What's Included" to list all actual files and directories (`docs/OPENCODE-COMMANDS.md`, `docs/TROUBLESHOOTING.md`, `modelfiles/`, `scripts/`, `RECOMMENDATIONS.md`, `CHANGELOG.md` were missing); added a Documentation index table pointing to each doc's purpose; README is now an accurate entry point that delegates depth to docs/
- `docs/PROJECT-SETUP.md`: all setup sections (new project, existing project, quick reference) now show both the symlink and copy approach side by side; previously only the symlink path was shown, leaving the copy alternative buried in the comparison table

---

## [1.1.1] — 2026-06-01

### Added
- `docs/PROJECT-SETUP.md` — new guide covering how to use this repo in new and existing projects; includes symlink vs copy trade-offs, whether to commit `opencode.json`, new/existing project workflows, launching OpenCode, selecting a model in the TUI, one-off task commands, and keeping config up to date across multiple projects

### Changed
- `README.md`: added "Using in Your Projects" section with quick symlink setup and link to `docs/PROJECT-SETUP.md`; added `docs/PROJECT-SETUP.md` entry to Documentation section; updated Performance Tips table and model recommendations to reference `ministral-3:8b-32k` instead of `ministral-3:8b-16k`; added `docs/PROJECT-SETUP.md` to Table of Contents
- `CLAUDE.md`: added `docs/PROJECT-SETUP.md` entry to Documentation Structure section
- `.vibe/prompts/vibe.md`: added `docs/PROJECT-SETUP.md` to the documentation list in Repository Purpose

---

## [1.1.0] — 2026-06-01

### Added
- `modelfiles/ministral-3-8b-32k.Modelfile` — reproducible build definition (`FROM ministral-3:8b` + `PARAMETER num_ctx 32768`); tested 2026-06-01 on M1 16GB: **100% GPU, 11 GB footprint**
- `modelfiles/ministral-3-8b-64k.Modelfile` — experimental 64k variant; included as a reference/warning. Tested 2026-06-01 on M1 16GB: **fails** — 27% CPU spillover, 16 GB footprint (saturates all unified memory). Not recommended on M1 16GB.

### Changed
- `opencode.json`: `ministral-3:8b-32k` is now the recommended model entry; `ministral-3:8b-16k` relabeled as standard (no longer recommended)
- `modelfiles/README.md`: added GPU test results column; added 32k (recommended) and 64k (do not use) rows
- `CLAUDE.md`: updated Extended Context Models section and Model Selection Guidelines to lead with `ministral-3:8b-32k`
- `README.md`: Quick Start, Available Models table, and Creating Custom Models updated to build and use the 32k variant
- `docs/LOCALLLMS.md`: Available Models table updated; "Creating Ministral 3 8B" section split into 32k (recommended) and 16k (fallback) subsections with GPU test results
- `.vibe/prompts/vibe.md`: updated model list and Modelfiles list to reflect 32k as recommended; 64k noted as not suitable for M1 16GB

### Context Window Test Results (M1 16GB, 2026-06-01)
- `ministral-3:8b-16k` (16k) — `100% GPU`, ~6.5 GB — safe, current default
- `ministral-3:8b-32k` (32k) — `100% GPU`, 11 GB — **new recommended**
- `ministral-3:8b-64k` (64k) — `27% CPU / 73% GPU`, 16 GB — CPU spillover, do not use

### Notes
- Ollama docs recommend at least 32k context for agentic tools like Open Code; 16k is sufficient for small tasks but can run out during multi-file sessions
- 32k is Ollama's default context for machines with 24–48 GB of memory, confirming it as the natural ceiling for M1 16GB
- 64k saturates all 16 GB unified memory; the KV cache growth pushes compute onto CPU, degrading inference speed

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
