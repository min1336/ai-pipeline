#!/bin/bash
# GitHub CLI 래퍼 — 허용된 명령어만 실행
# 사용법: ./scripts/gh.sh <subcommand> [args...]

set -euo pipefail

ALLOWED_COMMANDS="issue|search|label|pr"

SUBCMD="${1:-}"

if [[ -z "$SUBCMD" ]]; then
  echo "사용법: ./scripts/gh.sh <issue|search|label|pr> [args...]"
  exit 1
fi

if [[ ! "$SUBCMD" =~ ^($ALLOWED_COMMANDS)$ ]]; then
  echo "허용되지 않은 명령어: $SUBCMD"
  echo "허용 목록: $ALLOWED_COMMANDS"
  exit 1
fi

exec gh "$@"
