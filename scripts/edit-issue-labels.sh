#!/bin/bash
# 이슈 라벨 관리 래퍼
# 사용법: ./scripts/edit-issue-labels.sh --issue <number> --add-label <label> [--remove-label <label>]

set -euo pipefail

ISSUE=""
ADD_LABELS=()
REMOVE_LABELS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --issue)
      ISSUE="$2"
      shift 2
      ;;
    --add-label)
      ADD_LABELS+=("$2")
      shift 2
      ;;
    --remove-label)
      REMOVE_LABELS+=("$2")
      shift 2
      ;;
    *)
      echo "알 수 없는 인자: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$ISSUE" ]]; then
  echo "사용법: ./scripts/edit-issue-labels.sh --issue <number> --add-label <label>"
  exit 1
fi

# 라벨 추가
for label in "${ADD_LABELS[@]}"; do
  # 라벨이 없으면 생성
  gh label create "$label" --force 2>/dev/null || true
  gh issue edit "$ISSUE" --add-label "$label"
  echo "✅ 라벨 추가: $label → #$ISSUE"
done

# 라벨 제거
for label in "${REMOVE_LABELS[@]}"; do
  gh issue edit "$ISSUE" --remove-label "$label" 2>/dev/null || true
  echo "🗑️ 라벨 제거: $label → #$ISSUE"
done
