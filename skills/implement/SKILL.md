---
name: implement
description: 구현 계획에 따라 코드를 작성하고 PR을 생성합니다. stage/ready 이슈에 자동으로 사용합니다.
argument-hint: "[issue-number]"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(npm:*), Bash(npx:*), Bash(pip:*), Bash(git:*), Bash(gh pr:*), Bash(gh issue:*)
---

# 자동 구현

## 컨텍스트

- pipeline 설정: !`cat .github/pipeline.yml 2>/dev/null || echo "설정 없음"`
- 현재 브랜치: !`git branch --show-current`

## 작업 절차

### 1. 이슈 및 구현 계획 읽기

```bash
gh issue view $ARGUMENTS --json title,body,comments
```

"📐 구현 계획" 댓글에서 계획을 추출.

### 2. 브랜치 생성

```bash
git checkout -b feat/$ARGUMENTS-{짧은-설명}
```

브랜치 이름은 이슈 번호 + 2~3 단어 설명.

### 3. 의존성 설치

pipeline.yml의 `build.install` 명령어 실행.

### 4. 구현

구현 계획의 "구현 단계"를 순서대로 따라 실행:
- 파일 생성/수정은 Edit, Write 도구 사용
- 기존 코드 패턴과 컨벤션을 따를 것
- 변경하지 않는 코드에 불필요한 수정 금지

### 5. 안전장치

구현 중 다음 사항 확인:
- API 키, 비밀값 하드코딩 금지
- debug/print 로그 포함 금지
- 기존 테스트가 깨지지 않는지 확인

### 6. 테스트 작성 및 실행

구현 계획의 "테스트 계획"에 따라:
1. 테스트 코드 작성
2. pipeline.yml의 `build.test` 실행
3. 실패 시 수정 후 재실행

### 7. 린트/타입 체크

```bash
# pipeline.yml에서 명령어를 읽어서 실행
{build.lint}
{build.type-check}
```

### 8. 커밋

conventional commits 형식, 한국어:
```bash
git add {변경된 파일들만 — git add -A 금지}
git commit -m "feat: {구현 내용 요약}"
```

### 9. PR 생성

```bash
git push -u origin HEAD
gh pr create --title "feat: {50자 이내 제목}" --body "## 요약
{변경 내용 요약}

## 변경 사항
{파일 목록}

## 테스트
{테스트 방법}

Closes #$ARGUMENTS"
```

### 10. 이슈 라벨 업데이트

```bash
./scripts/edit-issue-labels.sh --issue $ARGUMENTS --add-label "stage/implementing" --remove-label "stage/ready"
```

## 중요 규칙

- 구현 계획을 반드시 먼저 읽고 그대로 따를 것
- 요청된 것만 구현할 것 (불필요한 리팩토링, 기능 추가 금지)
- PR 본문에 `Closes #이슈번호`를 반드시 포함할 것
- 모든 테스트가 통과한 상태에서만 PR 생성
- `git add -A` 금지, 변경된 파일만 개별 스테이징
