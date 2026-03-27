---
name: writing-skills
description: 새로운 파이프라인 스킬을 만드는 가이드입니다. 스킬 확장이 필요할 때 사용합니다.
argument-hint: "[skill-name]"
disable-model-invocation: true
allowed-tools: Read, Write, Glob, Grep
---

# 스킬 작성 가이드

## 스킬 구조

```
skills/{skill-name}/
├── SKILL.md          ← 필수: 지시문 + 프론트매터
├── reference.md      ← 선택: 상세 레퍼런스
└── examples/         ← 선택: 예시
    └── example.md
```

## SKILL.md 템플릿

```yaml
---
name: {skill-name}
description: {한 줄 설명 — 언제 사용하는지}
argument-hint: "[argument]"
allowed-tools: Read, Glob, Grep, {필요한 도구}
---

# {스킬 이름}

## 컨텍스트

- pipeline 설정: !`cat .github/pipeline.yml 2>/dev/null || echo "설정 없음"`

## 작업 절차

### 1. {단계}
{구체적인 지시}

### 2. {단계}
{구체적인 지시}

## 중요 규칙
- {필수 준수 사항}
```

## 작성 원칙

1. **구체적으로**: "코드를 분석하세요" (X) → "OWASP Top 10 기준으로 입력 검증 누락을 찾으세요" (O)
2. **검증 가능하게**: 각 단계의 완료 기준을 명확히
3. **안전하게**: allowed-tools를 최소 권한으로 설정
4. **동적으로**: `` !`command` ``로 프로젝트 맥락을 주입
5. **재사용 가능하게**: 특정 레포 하드코딩 금지, pipeline.yml에서 설정 읽기

## allowed-tools 가이드

| 작업 | 필요한 도구 |
|------|-----------|
| 읽기 전용 | Read, Glob, Grep |
| 이슈/PR 관리 | + Bash(gh issue:*), Bash(gh pr:*) |
| 코드 수정 | + Edit, Write |
| 빌드/테스트 | + Bash(npm:*), Bash(npx:*) |
| Git 작업 | + Bash(git:*) |
| 인라인 코멘트 | + mcp__github_inline_comment__* |
| CI 로그 | + mcp__github_ci__* |
