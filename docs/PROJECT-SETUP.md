# Using This Repo in Your Projects

This repo is a **shared configuration library** — you clone it once and wire it into as many projects as you like. This page explains exactly how.

## How OpenCode discovers its config

When you run `opencode` in a directory, it looks for `opencode.json` in the current working directory (your project root). If it finds one, it uses the models and provider settings defined there. If it doesn't find one, it falls back to `~/.config/opencode/opencode.json`.

Keeping `opencode.json` in the project root means each project can have its own model config, and you can commit it to the repo so teammates get the same setup automatically.

---

## New project setup

```bash
# 1. Create and enter your project
mkdir ~/code/my-project && cd ~/code/my-project
git init

# 2. Symlink the config from this repo
ln -s ~/code/ollama-opencode-setup/opencode.json opencode.json

# 3. Start OpenCode
opencode
```

That's it. OpenCode reads the symlinked config, shows the model picker, and you're ready.

---

## Existing project setup (e.g. ~/code/imagewize.com)

```bash
cd ~/code/imagewize.com

# Symlink the config
ln -s ~/code/ollama-opencode-setup/opencode.json opencode.json

# Start OpenCode
opencode
```

---

## Symlink vs copy — which to use

| | Symlink (`ln -s`) | Copy (`cp`) |
|---|---|---|
| **Updates** | Automatic — all projects get new models when this repo updates | Manual — you must re-copy after changes |
| **Independence** | All projects share one config | Each project can diverge |
| **Portability** | Breaks if this repo moves or is not cloned | Self-contained |
| **Recommended for** | Your own machines where this repo is always present | CI environments, sharing with teammates who don't have this repo |

**Recommendation:** symlink on your own machines, copy for anything that needs to be self-contained.

---

## Should you commit opencode.json?

**Yes, generally.** If teammates also use OpenCode, committing the file (or symlink) means they get the same model config without any setup. The file contains no secrets — just a provider URL and model names.

If you copy rather than symlink, the file is already a regular file and will be picked up by git normally.

If you symlink, git tracks the symlink itself:
```bash
git add opencode.json
git commit -m "chore: add OpenCode config (symlink to ollama-opencode-setup)"
```

Teammates who don't have this repo cloned will get the symlink but it will be broken for them. In that case, either:
- Copy instead of symlinking, or
- Add a setup note to your project's README

---

## Launching OpenCode

```bash
cd ~/code/your-project
opencode          # opens the interactive TUI
```

On first launch you'll see the **Select model** picker. Choose `Ministral 3 8B (32k context, tool use, recommended)` for general coding tasks.

To run a one-off task without the TUI:
```bash
opencode run "create a file called hello.md with the text: hello world" --model ollama/ministral-3:8b-32k
```

---

## Selecting a model in the TUI

Inside a session, press `ctrl+x m` (or type `/models`) to open the model picker at any time. You can switch models mid-session — useful for switching from a fast tool-use model to a larger read-only model for analysis.

---

## Recommended models per task

| Task | Model | Why |
|---|---|---|
| General coding, file edits | `ministral-3:8b-32k` | Fast tool use, 32k context, 100% GPU on M1 16GB |
| Memory-constrained machine | `ministral-3:8b-16k` | Same speed, smaller footprint (6.5 GB) |
| Quick single-file edits | `qwen3:4b` | Smallest footprint (2.5 GB) |
| Large multi-file analysis | `qwen3:8b-16k` | Extended context, confirmed tool use |
| Read-only code review | any model | Tool use not required for analysis |

---

## Keeping your config up to date

If you used a symlink, just pull this repo:
```bash
cd ~/code/ollama-opencode-setup
git pull
```

All symlinked projects immediately see the updated model list.

If a new recommended model is added (e.g. a new Modelfile), build it once:
```bash
ollama create ministral-3:8b-32k -f ~/code/ollama-opencode-setup/modelfiles/ministral-3-8b-32k.Modelfile
```

Then it's available in every project that uses the symlinked config.

---

## Quick reference

```bash
# First-time setup for a project
ln -s ~/code/ollama-opencode-setup/opencode.json ~/code/your-project/opencode.json

# Build the recommended model (once, not per project)
ollama create ministral-3:8b-32k -f ~/code/ollama-opencode-setup/modelfiles/ministral-3-8b-32k.Modelfile

# Launch
cd ~/code/your-project && opencode

# One-off task
opencode run "your task here" --model ollama/ministral-3:8b-32k

# Switch model inside TUI
ctrl+x m
```
