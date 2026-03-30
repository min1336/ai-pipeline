# AGENTS.md

## Build & Test
이 레포는 빌드/테스트가 필요 없는 설정 전용 레포입니다.
워크플로우 YAML과 스킬 Markdown 파일로 구성됩니다.

## Code Conventions
- 한국어 주석
- Conventional commits (feat/fix/refactor/docs/chore)
- YAML 들여쓰기 2칸
- Markdown 파일은 한 줄 80자 이내 권장

## Architecture
- `.github/workflows/` — Reusable Workflows (workflow_call)
- `skills/` — Claude Code Skills (SKILL.md + 레퍼런스)
- `actions/` — Composite Actions (재사용 단계)
- `scripts/` — GitHub CLI 래퍼 스크립트
- `templates/` — 소비자 레포에 복사할 파일
- `docs/` — 레퍼런스 문서

### 컨텍스트 전달 흐름
```
AGENTS.md (프로젝트 규칙)
  + pipeline.yml (파이프라인 설정 + 도메인 컨텍스트)
  + gather-context (동적: 최근 커밋, 관련 이슈)
  → Reusable Workflow의 prompt에 주입
  → Claude Code Action 실행
```

### 라벨 상태 머신
```
이슈 생성 → [stage/enriching] → [stage/enriched]
  → [stage/ready] → [stage/approved] → [stage/implementing]
  → PR 생성 → [stage/reviewed] → 머지
```

## Boundaries
- NEVER modify consuming repos' code directly
- NEVER hardcode API keys or secrets
- NEVER add external plugin dependencies
- NEVER skip Human-in-the-loop (stage/approved) by default
