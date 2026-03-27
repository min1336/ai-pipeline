---
name: maintenance
description: 주간 유지보수를 수행합니다. 매주 월요일 크론으로 자동 실행됩니다.
allowed-tools: Read, Glob, Grep, Bash(gh issue:*), Bash(gh search:*), Bash(gh pr:*), Bash(git log:*), Bash(npm audit:*), Bash(pip audit:*), Bash(./scripts/edit-issue-labels.sh:*)
---

# 주간 유지보수

## 컨텍스트

- pipeline 설정: !`cat .github/pipeline.yml 2>/dev/null || echo "설정 없음"`

## 작업 절차

### 1. Stale 이슈 관리

pipeline.yml의 `safety.stale-days` (기본 30일), `safety.close-days` (기본 60일) 참조.

**보호 라벨** (자동 닫기 면제): `safety.protected-labels`

```bash
# 30일 이상 비활동 이슈
gh search issues --repo $REPO --state open --sort updated -- "updated:<30일전날짜>"
```

- 30일+ 비활동: `status/stale` 라벨 + 리마인더 댓글
- 60일+ 비활동 + 이미 stale: 닫기 (not-planned) + 댓글
- 보호 라벨이 있으면: 댓글만 (닫지 않음)

### 2. Stale PR 리마인더

```bash
# 14일 이상 리뷰 대기 PR
gh pr list --state open --json number,title,updatedAt
```

14일+ 대기 PR에 리마인더 댓글.

### 3. 의존성 보안 감사

프로젝트 언어에 따라:
- Node.js: `npm audit`
- Python: `pip audit`

**high/critical 취약점 발견 시:**
```bash
gh issue create --title "[보안] 의존성 취약점 발견 - {패키지명}" \
  --body "{상세 내용}" \
  --label "type/bug,priority/high"
```

### 4. 주간 리포트 생성

```bash
# 지난 7일 커밋
git log --oneline --since="7 days ago"

# 머지된 PR
gh pr list --state merged --search "merged:>7일전날짜"

# 열린/닫힌 이슈
gh search issues --repo $REPO --state open --sort created -- "created:>7일전날짜"
gh search issues --repo $REPO --state closed --sort updated -- "closed:>7일전날짜"
```

리포트 이슈 생성:
```bash
gh issue create --title "[주간 리포트] {날짜} 주간 요약" \
  --body "{리포트 내용}" \
  --label "type/report"
```

## 리포트 형식

```markdown
## 📊 주간 리포트

### 커밋 요약
- {N}개 커밋

### PR
- 머지: {N}개
- 열린: {N}개

### 이슈
- 생성: {N}개
- 해결: {N}개
- priority/high 미해결: {N}개

### 보안
- 취약점: {있음/없음}
```
