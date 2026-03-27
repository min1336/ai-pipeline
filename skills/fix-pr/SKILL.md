---
name: fix-pr
description: PR 리뷰 피드백을 반영하여 수정합니다. 리뷰에서 수정 요청 시 자동으로 사용합니다.
argument-hint: "[pr-number]"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(npm:*), Bash(npx:*), Bash(git:*), Bash(gh pr:*)
---

# PR 리뷰 피드백 수정

## 컨텍스트

- pipeline 설정: !`cat .github/pipeline.yml 2>/dev/null || echo "설정 없음"`

## 안전장치

최대 시도 횟수: pipeline.yml의 `safety.max-pr-fix-attempts` (기본 2).

시도 횟수 확인:
```bash
gh pr view $ARGUMENTS --json comments --jq '[.comments[] | select(.body | contains("🔧 리뷰 피드백 반영"))] | length'
```

최대 횟수 초과 시 수동 확인 요청 댓글을 남기고 중단.

## 작업 절차

### 1. 리뷰 피드백 수집

```bash
gh pr view $ARGUMENTS --json comments,reviews
```

"🔍 PR 리뷰 결과" 댓글에서 수정 필요 항목 추출:
- 🔴 Critical: 반드시 수정
- 🟡 Warning: 가능하면 수정

인라인 코멘트도 확인:
```bash
gh api repos/{owner}/{repo}/pulls/$ARGUMENTS/comments
```

### 2. 수정 적용

🔴 항목을 우선 수정, 🟡 항목은 가능한 범위에서 수정.

### 3. 검증

verify 스킬 절차를 따라 전체 검증.

### 4. 커밋 + 푸시

```bash
git add {수정된 파일만}
git commit -m "fix: PR 리뷰 피드백 반영 - {수정 요약}"
git push
```

### 5. 결과 보고

PR에 댓글:
```markdown
## 🔧 리뷰 피드백 반영 완료

| 지적 사항 | 수정 여부 |
|-----------|----------|
| 🔴 {항목1} | ✅ 수정 |
| 🔴 {항목2} | ✅ 수정 |
| 🟡 {항목3} | ✅ 수정 |

**시도:** {N}/{max}회
```

## 중요 규칙

- 🔴 항목은 반드시 모두 수정할 것
- 수정 후 반드시 verify 절차를 거칠 것
- 최대 시도 횟수 초과 시 수동 확인 요청
- 리뷰어의 의도를 이해하고 수정할 것 (기계적 수정 금지)
