#!/usr/bin/env bash
# Tool-calling smoke test for Ollama (or any OpenAI-compatible) endpoint.
# Confirms a model emits a valid tool_call (not prose / not a bash heredoc)
# when asked to write a file.
#
# Usage: ./scripts/tool-call-test.sh <model> [num_ctx] [endpoint]
# Example (Ollama):  ./scripts/tool-call-test.sh ministral-3:8b 16384
# Example (MLX):     ./scripts/tool-call-test.sh qwen3.5-27b-distilled-v2 16384 http://localhost:8080/v1/chat/completions

set -euo pipefail

MODEL="${1:?usage: tool-call-test.sh <model> [num_ctx] [endpoint]}"
NUM_CTX="${2:-16384}"
ENDPOINT="${3:-http://localhost:11434/v1/chat/completions}"

read -r -d '' PAYLOAD <<JSON || true
{
  "model": "${MODEL}",
  "options": { "num_ctx": ${NUM_CTX} },
  "messages": [
    { "role": "system", "content": "You are a coding agent. When asked to create or edit files, you MUST call the provided tools. Do not print file contents as text." },
    { "role": "user", "content": "Create a file called todo.md containing 3 sample tasks in markdown." }
  ],
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "write",
        "description": "Write content to a file on disk.",
        "parameters": {
          "type": "object",
          "properties": {
            "filePath": { "type": "string", "description": "Absolute path of the file to write" },
            "content":  { "type": "string", "description": "Full file content" }
          },
          "required": ["filePath", "content"]
        }
      }
    }
  ],
  "tool_choice": "auto",
  "stream": false
}
JSON

echo "=== Model: ${MODEL} (num_ctx=${NUM_CTX}) ==="
START=$(date +%s)
RESP=$(curl -s "${ENDPOINT}" -H 'Content-Type: application/json' -d "${PAYLOAD}")
END=$(date +%s)

echo "Elapsed: $((END - START))s"

# Did it emit a tool call?
TOOL_NAME=$(printf '%s' "${RESP}" | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
    tc = d["choices"][0]["message"].get("tool_calls") or []
    if tc:
        print(tc[0]["function"]["name"])
    else:
        print("__NONE__")
except Exception as e:
    print("__ERR__:" + str(e))
')

if [ "${TOOL_NAME}" = "write" ]; then
  echo "RESULT: ✅ PASS — emitted write tool_call"
elif [ "${TOOL_NAME}" = "__NONE__" ]; then
  echo "RESULT: ❌ FAIL — no tool_call (returned prose/text instead)"
  printf '%s' "${RESP}" | python3 -c 'import sys,json; print("  text preview:", (json.load(sys.stdin)["choices"][0]["message"].get("content") or "")[:200])' 2>/dev/null || true
else
  echo "RESULT: ⚠️  ${TOOL_NAME}"
fi
