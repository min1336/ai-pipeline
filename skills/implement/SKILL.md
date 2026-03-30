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
- 학습 기록: !`cat .github/ai-learnings.md 2>/dev/null || echo "학습 기록 없음"`

## 작업 절차

### 1. 이슈 및 구현 계획 읽기

```bash
gh issue view $ARGUMENTS --json title,body,comments
```

"📐 구현 계획" 댓글에서 계획을 추출.

### 2. 목표 앵커 파일 생성

구현 계획의 **구현 단계**와 **완료 기준**을 `.ai-plan.md`에 저장:

```bash
cat > .ai-plan.md << 'PLAN'
# 현재 구현 목표 (이슈 #N)

## 구현 단계
1. {계획에서 추출한 단계}
2. {계획에서 추출한 단계}
...

## 완료 기준 (Sprint Contract)
- [ ] {검증 가능한 조건 1}
- [ ] {검증 가능한 조건 2}
- [ ] {검증 가능한 조건 3}

## 현재 진행: 단계 1
PLAN
```

**매 구현 단계 시작 전**에 `.ai-plan.md`를 다시 읽어서 목표를 확인하고,
"현재 진행" 항목을 업데이트할 것. 이것이 긴 세션에서 목표 드리프트를 방지한다.

### 3. 브랜치 생성 + 초기 커밋

```bash
git checkout -b feat/$ARGUMENTS-{짧은-설명}
git add .ai-plan.md
git commit -m "chore: 구현 계획 앵커 파일 생성 (#$ARGUMENTS)"
```

### 4. 의존성 설치

pipeline.yml의 `build.install` 명령어 실행.

### 5. 단계별 구현 (체크포인트 패턴)

구현 계획의 "구현 단계"를 순서대로 따라 실행.
**각 단계마다 아래 사이클을 반복:**

```
┌─ 단계 시작: .ai-plan.md 다시 읽기 (목표 앵커링)
│
├─ 코드 작성 (Edit, Write 사용)
│   - 기존 코드 패턴과 컨벤션을 따를 것
│   - 학습 기록의 주의사항을 참고할 것
│   - 변경하지 않는 코드에 불필요한 수정 금지
│
├─ 즉시 검증 (자동 검증-수정 체인)
│   - 해당 단계와 관련된 테스트만 실행
│   - 린트/타입 체크 실행
│   - 실패 시: 에러 분석 → 수정 → 재검증 (최대 2회)
│   - 2회 실패 시: 해당 단계를 .ai-plan.md에 "blocked" 표시하고 다음 단계로
│
├─ 체크포인트 커밋
│   git add {이 단계에서 변경된 파일만}
│   git commit -m "feat: 단계 N — {단계 설명} (#$ARGUMENTS)"
│
└─ .ai-plan.md 업데이트: "현재 진행" → 다음 단계
```

### 6. 안전장치

구현 중 다음 사항 확인:
- API 키, 비밀값 하드코딩 금지
- debug/print 로그 포함 금지
- 기존 테스트가 깨지지 않는지 확인

### 7. 최종 검증 (전체 테스트 스위트)

모든 단계 완료 후:

```bash
{build.test}     # 전체 테스트
{build.lint}     # 린트
{build.type-check}  # 타입 체크 (있으면)
```

실패 시 수정 후 재실행 (최대 2회). 여전히 실패하면 PR에 실패 항목을 명시.

### 8. 완료 기준 체크 (Sprint Contract 검증)

`.ai-plan.md`의 **완료 기준**을 하나씩 검증:
- 통과하면 `[x]`로 체크
- 실패하면 `[ ]`로 남기고 이유를 기록

모든 기준이 통과해야 PR 생성. 일부 미통과 시 PR 본문에 명시.

### 9. 정리

```bash
rm .ai-plan.md
git add -A .ai-plan.md
```

### 10. PR 생성

```bash
git push -u origin HEAD
gh pr create --title "feat: {50자 이내 제목}" --body "## 요약
{변경 내용 요약}

## 변경 사항
{파일 목록}

## 완료 기준 검증
- [x] {충족된 기준}
- [x] {충족된 기준}
- [ ] {미충족 기준 + 이유} (해당 시)

## 테스트
{테스트 방법}

Closes #$ARGUMENTS"
```

### 11. 이슈 라벨 업데이트

```bash
./scripts/edit-issue-labels.sh --issue $ARGUMENTS --add-label "stage/implementing" --remove-label "stage/approved"
```

### 12. 학습 기록 업데이트

구현 중 발견한 프로젝트 고유 함정이 있으면 `.github/ai-learnings.md`의
"코드베이스 주의사항" 섹션에 기록:

```bash
git add .github/ai-learnings.md
git commit -m "chore: AI 학습 기록 업데이트 — 코드베이스 주의사항 추가"
git push
```

## 중요 규칙

- 구현 계획을 반드시 먼저 읽고 그대로 따를 것
- 요청된 것만 구현할 것 (불필요한 리팩토링, 기능 추가 금지)
- **매 단계마다 .ai-plan.md를 다시 읽을 것** (목표 앵커링)
- **매 단계마다 체크포인트 커밋할 것** (실패 시 복구 가능)
- **매 단계마다 관련 테스트를 실행할 것** (자동 검증-수정 체인)
- 학습 기록의 주의사항을 참고할 것
- PR 본문에 `Closes #이슈번호`를 반드시 포함할 것
- 완료 기준을 검증한 결과를 PR 본문에 포함할 것
- `git add -A` 금지, 변경된 파일만 개별 스테이징
