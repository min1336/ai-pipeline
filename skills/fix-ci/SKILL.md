---
name: fix-ci
description: CI 실패 로그를 분석하고 수정합니다. deploy 워크플로우 실패 시 자동으로 사용합니다.
argument-hint: "[workflow-run-id]"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(npm:*), Bash(npx:*), Bash(pip:*), Bash(git:*), Bash(gh pr:*), mcp__github_ci__get_ci_status, mcp__github_ci__get_workflow_run_details, mcp__github_ci__download_job_log
---

# CI 실패 수정

## 컨텍스트

- pipeline 설정: !`cat .github/pipeline.yml 2>/dev/null || echo "설정 없음"`

## 안전장치

최대 시도 횟수: pipeline.yml의 `safety.max-ci-fix-attempts` (기본 2).

시도 횟수 확인:
```bash
git log --oneline --since="24 hours ago" | grep -c "fix: CI" || echo 0
```

최대 횟수 초과 시 PR에 경고 댓글을 남기고 중단.

## 작업 절차

### 1. CI 로그 분석

```
mcp__github_ci__download_job_log(run_id: $ARGUMENTS)
```

에러 메시지, 실패 단계, 스택 트레이스 추출.

### 2. 원인 진단

- 컴파일 에러? → 코드 수정
- 테스트 실패? → 테스트 또는 코드 수정
- 린트 에러? → 코드 스타일 수정
- 의존성 문제? → package.json 또는 lock 파일 수정
- 환경 문제? → 워크플로우 설정 수정 (이 경우 수동 확인 권고)

### 3. 수정 적용

원인에 따라 코드 수정. Edit, Write 도구 사용.

### 4. 로컬 검증

verify 스킬의 절차를 따라 검증.

### 5. 커밋 + 푸시

```bash
git add {수정된 파일만}
git commit -m "fix: CI 실패 수정 - {원인 요약}"
git push
```

### 6. 결과 보고

PR에 댓글:
```markdown
## 🔧 CI 수정 완료

**원인:** {원인}
**수정:** {수정 내용}
**검증:** 로컬 테스트 통과 ✅
**시도:** {N}/{max}회
```

### 7. 학습 기록 업데이트

수정 완료 후 `.github/ai-learnings.md`의 "CI 실패 패턴" 섹션에 기록:

```markdown
- [날짜] 원인 카테고리: 구체적 설명 (발견 횟수: N)
```

```bash
git add .github/ai-learnings.md
git commit -m "chore: AI 학습 기록 업데이트 — CI 실패 패턴 추가"
git push
```

## 중요 규칙

- 최대 시도 횟수를 반드시 지킬 것
- 수정 전 반드시 원인을 진단할 것 (맹목적 수정 금지)
- 수정 후 반드시 verify 절차를 거칠 것
- 환경 문제(시크릿 누락, 서비스 장애 등)는 수동 확인 권고
