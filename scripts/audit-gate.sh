#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/audit-gate.sh [options]

Run the external audit gate against this repository.

Options:
  --audit-bin <path>  Explicit audit executable
  -h, --help          Show this help
USAGE
}

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AUDIT_BIN="${STYIO_AUDIT_BIN:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --audit-bin)
      AUDIT_BIN="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$AUDIT_BIN" ]]; then
  if command -v audit >/dev/null 2>&1; then
    AUDIT_BIN="$(command -v audit)"
  elif [[ -x "$ROOT/../audit/bin/audit" ]]; then
    AUDIT_BIN="$ROOT/../audit/bin/audit"
  elif [[ -x "$HOME/audit/bin/audit" ]]; then
    AUDIT_BIN="$HOME/audit/bin/audit"
  fi
fi

if [[ -z "$AUDIT_BIN" || ! -x "$AUDIT_BIN" ]]; then
  echo "audit executable not found; set STYIO_AUDIT_BIN or pass --audit-bin" >&2
  exit 2
fi

"$AUDIT_BIN" gate --repo "$ROOT" --project styio-platform
