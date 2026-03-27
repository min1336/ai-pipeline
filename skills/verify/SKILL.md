---
name: verify
description: 수정사항이 실제로 동작하는지 검증합니다. fix-ci, fix-pr 후에 자동으로 사용합니다.
argument-hint: "[검증 대상 설명]"
allowed-tools: Read, Glob, Grep, Bash(npm:*), Bash(npx:*), Bash(pip:*), Bash(git:*)
---

# 수정 검증

## 원칙

**검증 없이 완료 처리하지 않는다.**
수정했으면 반드시 동작을 확인한 후에야 완료.

## 작업 절차

### 1. 변경 사항 파악

```bash
git diff --name-only HEAD~1
```

### 2. 관련 테스트 실행

변경된 파일에 대응하는 테스트만 실행:
- `*.service.ts` 변경 → `*.service.spec.ts` 실행
- `*.controller.ts` 변경 → `*.controller.spec.ts` 또는 e2e 실행

pipeline.yml의 `build.test` 명령어 사용.

### 3. 전체 테스트 실행

개별 테스트 통과 후 전체 테스트 스위트 실행.

### 4. 린트/타입 체크

```bash
{build.lint}
{build.type-check}
```

### 5. 빌드 확인

```bash
{build.build}
```

### 6. 결과 보고

```markdown
## ✅ 검증 완료

| 항목 | 결과 |
|------|------|
| 관련 테스트 | ✅ 통과 |
| 전체 테스트 | ✅ 통과 |
| 린트 | ✅ 통과 |
| 타입 체크 | ✅ 통과 |
| 빌드 | ✅ 통과 |
```

실패 시:
```markdown
## ❌ 검증 실패

| 항목 | 결과 | 상세 |
|------|------|------|
| 전체 테스트 | ❌ 실패 | {에러 메시지} |
```

## 중요 규칙

- 모든 검증 항목을 실제로 실행할 것 (결과 추측 금지)
- 실패 시 에러 메시지를 정확히 기록할 것
- 검증이 모두 통과해야만 완료 처리
