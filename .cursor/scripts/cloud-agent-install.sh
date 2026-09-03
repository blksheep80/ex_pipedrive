#!/usr/bin/env bash
# Idempotent bootstrap for ExPipedrive cloud agents (Build + per-repo install).
# Matches .tool-versions / CI primary cell: Elixir 1.17.2, OTP 27.
set -euo pipefail

repo_root() {
  cd "$(dirname "$0")/../.." && pwd
}

install_mix_project() {
  local dir="$1"
  echo "==> mix deps.get + compile: $dir"
  cd "$dir"
  mix local.hex --force
  mix local.rebar --force
  mix deps.get
  MIX_ENV=test mix compile --warnings-as-errors
}

ROOT="$(repo_root)"
install_mix_project "$ROOT"

# Multi-repo cloud environments clone siblings beside core.
for sibling in ex_pipedrive_web ex_pipedrive_oban ex_pipedrive_phoenix; do
  sibling_path="$(dirname "$ROOT")/$sibling"
  if [ -f "$sibling_path/mix.exs" ]; then
    install_mix_project "$sibling_path"
  fi
done

# Warm Dialyzer PLT on core (best-effort; speeds later agent runs).
cd "$ROOT"
mix dialyzer --plt 2>/dev/null || true

echo "==> Cloud agent install complete"
