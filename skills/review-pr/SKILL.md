---
name: review-pr
description: PR을 2단계로 리뷰합니다. PR이 열리거나 업데이트될 때 자동으로 사용합니다.
argument-hint: "[pr-number]"
allowed-tools: Read, Glob, Grep, Bash(gh pr:*), Bash(gh issue:*), mcp__github_inline_comment__create_inline_comment
---

# PR 리뷰 (2단계 서브에이전트 방식)

## 컨텍스트

- pipeline 설정: !`cat .github/pipeline.yml 2>/dev/null || echo "설정 없음"`
- PR diff: !`gh pr diff $ARGUMENTS --name-only 2>/dev/null | head -30`

## 작업 절차

### Phase 1: 스펙/요구사항 준수 검증

PR이 연결된 이슈의 구현 계획을 충실히 따르는지 확인:

1. PR 본문에서 `Closes #N` 패턴으로 연결 이슈 번호 추출
2. 연결 이슈의 "📐 구현 계획" 댓글 읽기
3. 구현 계획 대비 PR diff 비교:
   - 계획된 파일이 모두 변경됐는가?
   - 계획에 없는 불필요한 변경이 있는가?
   - 구현 단계를 모두 따랐는가?
   - 테스트 계획을 이행했는가?

자세한 기준은 [phase1-spec.md](phase1-spec.md) 참조.

### Phase 2: 코드 품질/보안/성능 검증

pipeline.yml의 `review.roles`에 따라 활성화된 관점에서 리뷰:

**각 역할별 관점:**
- **security**: OWASP Top 10, 입력 검증, 하드코딩 비밀값
- **qa**: 테스트 커버리지, 엣지 케이스, 회귀 위험
- **reviewer**: 코드 패턴, 컨벤션, 중복, 복잡도, 성능

자세한 기준은 [phase2-quality.md](phase2-quality.md) 참조.

### 인라인 코멘트

심각한 문제는 인라인으로 지적:
```
mcp__github_inline_comment__create_inline_comment(
  path: "src/file.ts",
  line: 42,
  body: "🔴 SQL injection 취약점: 사용자 입력이 쿼리에 직접 삽입됩니다.",
  confirmed: true
)
```

- `confirmed: true`: 확실한 문제 → 즉시 게시
- `confirmed: false`: 불확실 → 세션 끝에 필터링

### 점수 산출

pipeline.yml의 `scoring.review.weights`에 따라 점수 산출:

```markdown
## 🔍 PR 리뷰 결과

### 점수
| 항목 | 점수 | 상세 |
|------|------|------|
| 보안 | {n}/25 | {설명} |
| 테스트 | {n}/25 | {설명} |
| 코드 품질 | {n}/20 | {설명} |
| 성능 | {n}/15 | {설명} |
| 문서 | {n}/15 | {설명} |
| **합계** | **{total}/100** | |

### 체크리스트
- [x] 코드 컨벤션 준수 ✅
- [ ] 테스트 커버리지 충분 ⚠️
...

### 판정
{verdict_emoji} **{verdict}**

{상세 피드백}

<!-- PIPELINE:{"stage":"reviewed","score":0,"verdict":"approve"} --> ← 실제 점수/판정으로 교체
```

### 판정 기준

pipeline.yml의 `scoring.review.verdicts`에 따라:
- 90~100: `auto-approve` → ✅ 머지 가능
- 70~89: `approve` → 👍 승인 권장
- 50~69: `request-changes` → ⚠️ 수정 필요
- 0~49: `block` → ❌ 주요 문제

### 학습 기록 업데이트

리뷰 완료 후, 점수가 70 미만이거나 block/request-changes 판정인 경우:

1. `.github/ai-learnings.md` 파일 읽기
2. 이번 리뷰에서 발견한 주요 문제가 기존 패턴과 겹치면 발견 횟수 증가
3. 새로운 패턴이면 "리뷰 패턴" 섹션에 추가:

```markdown
- [2024-03-15] N+1 쿼리: UserService에서 루프 내 개별 쿼리 (발견 횟수: 1)
```

4. 변경사항 커밋:
```bash
git add .github/ai-learnings.md
git commit -m "chore: AI 학습 기록 업데이트 — 리뷰 패턴 추가"
git push
```

## 중요 규칙

- PR diff를 실제로 읽고 분석할 것 (요약만 보고 판단 금지)
- 인라인 코멘트는 실제 문제에만 사용 (스타일 nitpick 금지)
- 점수는 근거와 함께 제시할 것
- PIPELINE 마커를 반드시 포함할 것
- 학습 기록은 구체적으로 기록 ("보안 문제" X → "SQL injection: 사용자 입력이 쿼리에 직접 삽입" O)
