#!/bin/bash
# usage: run_agent.sh <workdir> <prompt_file> <out_jsonl>
set -u
wd="$1"; pf="$2"; out="$3"
cd "$wd" || exit 1
# conda environment from environment.yml; override CONDA_ENV_BIN if yours lives elsewhere
export PATH="${CONDA_ENV_BIN:-$HOME/miniforge3/envs/ieu-ai-workshop/bin}:$PATH"
export R_LIBS_USER=/nonexistent_r_libs
SANDBOX_JSON='{"sandbox":{"enabled":true,"autoAllowBashIfSandboxed":true,"allowUnsandboxedCommands":false}}'
start=$(date +%s)
claude -p "$(cat "$pf")" --model claude-sonnet-5-5 --setting-sources project --strict-mcp-config \
  --no-session-persistence --permission-mode acceptEdits --permission-prompts none --settings "$SANDBOX_JSON" \
  --allowedTools "Read" "Glob" "Grep" "Write" "Edit" \
  "Bash(conda run -n ieu-ai-workshop Rscript:*)" "Bash(Rscript:*)" "Bash(find:*)" "Bash(echo:*)" "Bash(sed:*)" "Bash(pwd)" "Bash(printf:*)" "Bash(test:*)" "Bash(which:*)" "Bash(python3:*)" "Bash(rm:*)" "Bash(mv:*)" "Bash(touch:*)" "Bash(ls:*)" "Bash(cat:*)" "Bash(head:*)" "Bash(tail:*)" \
  "Bash(wc:*)" "Bash(mkdir:*)" "Bash(git:*)" "Bash(diff:*)" "Bash(grep:*)" "Bash(cd:*)" "Bash(cp:*)" "Bash(sort:*)" "Bash(awk:*)" "Bash(cut:*)" \
  --output-format stream-json --verbose > "$out" 2> "${out%.jsonl}.err"
echo "exit=$? seconds=$(( $(date +%s) - start ))"
