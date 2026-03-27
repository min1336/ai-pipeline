# ai-pipeline

다중 레포 AI DevOps 파이프라인.

이슈 하나 만들면 PR까지 AI가 자동으로 처리합니다.

## 사용법

프로젝트 레포에 파일 3개만 추가하면 동작합니다:

1. `AGENTS.md` — 프로젝트 규칙
2. `.github/pipeline.yml` — 파이프라인 설정
3. `.github/workflows/ai.yml` — 이 레포의 워크플로우 호출

## 파이프라인 흐름

```
사람: 이슈 생성 → AI: 구체화 → 세분화 → 구현 → PR 생성 → 사람: 리뷰/머지
```

## 구조

```
ai-pipeline/
├── .github/workflows/    ← Reusable Workflows (언제/조건)
├── skills/               ← Claude Code Skills (무엇을/어떻게)
├── actions/              ← Composite Actions (공통 단계)
└── scripts/              ← GitHub CLI 래퍼
```

## 의존성

- `anthropics/claude-code-action@v1`
- GitHub CLI (`gh`) — Runner 기본 제공
- `git` — Runner 기본 제공

외부 플러그인 (gstack, superpowers 등) 의존 없음.
