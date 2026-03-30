# ai-pipeline

다중 레포 AI DevOps 파이프라인.
이슈 하나 만들면 PR까지 AI가 자동으로 처리합니다.

## 파이프라인 흐름

```
사람: 이슈 생성
  │
  ▼
AI: 구체화 (enrich)         ← 이슈 품질 평가, 부족하면 질문
  │
  ▼  [stage/enriched]
AI: 세분화 (decompose)      ← 구현 계획 작성, 파일/단계 특정
  │
  ▼  [stage/ready]
사람: 계획 확인 + 승인       ← Human-in-the-loop (stage/approved 라벨)
  │
  ▼  [stage/approved]
AI: 구현 (implement)        ← 브랜치, 코드, 테스트, PR 생성
  │
  ▼
AI: 리뷰 (review)           ← 2단계 리뷰 (스펙 검증 + 품질/보안)
  │
  ├─ 통과 → 사람: 머지
  └─ 수정 필요 → AI: 피드백 반영 (fix-pr)
                   └─ CI 실패 → AI: 자동 수정 (fix-ci)
```

## 빠른 시작 (3단계)

### 1. 프로젝트 레포에 파일 추가

```bash
# 워크플로우 (오케스트레이터)
mkdir -p .github/workflows
cp templates/workflows/ai.yml .github/workflows/ai.yml

# 파이프라인 설정
cp templates/pipeline.yml .github/pipeline.yml

# 프로젝트 규칙 (AI 컨텍스트)
cp templates/AGENTS.md AGENTS.md
```

### 2. 시크릿 설정

레포 Settings > Secrets > Actions에 추가:
- `CLAUDE_OAUTH_TOKEN` — Claude 인증 토큰

### 3. 커스터마이징

`.github/pipeline.yml` 수정:
```yaml
project:
  name: my-project
  language: python        # 프로젝트 언어

build:
  test: pytest            # 테스트 명령어
  lint: ruff check .      # 린트 명령어

pipeline:
  require-approval: true  # 구현 전 사람 승인 필수
```

`AGENTS.md` 수정:
- 프로젝트 아키텍처, 코딩 컨벤션, 도메인 용어 등 추가
- 내용이 풍부할수록 AI 코드 품질이 올라감

## @claude 명령어

이슈/PR 코멘트에서 수동으로 AI를 호출할 수 있습니다:

| 명령어 | 설명 | 사용 위치 |
|--------|------|----------|
| `@claude enrich` | 이슈 재분석 | 이슈 |
| `@claude decompose` | 구현 계획 재작성 | 이슈 |
| `@claude implement` | 구현 시작 | 이슈 |
| `@claude review` | PR 리뷰 | PR |
| `@claude fix` | 리뷰 피드백 반영 | PR |
| `@claude help` | 도움말 | 이슈/PR |

## 구조

```
ai-pipeline/
├── .github/workflows/    ← Reusable Workflows (언제/조건)
│   ├── enrich.yml           이슈 구체화
│   ├── decompose.yml        이슈 세분화
│   ├── implement.yml        자동 구현
│   ├── review.yml           PR 리뷰
│   ├── fix-pr.yml           리뷰 피드백 반영
│   ├── ci-fix.yml           CI 실패 수정
│   └── maintenance.yml      주간 유지보수
│
├── skills/               ← Claude Code Skills (무엇을/어떻게)
│   ├── enrich-issue/        이슈 품질 평가 + 코드베이스 분석
│   ├── decompose-issue/     구현 계획 + 파일/단계 특정
│   ├── implement/           코드 작성 + 테스트 + PR
│   ├── review-pr/           2단계 리뷰 (스펙 + 품질)
│   ├── fix-pr/              리뷰 피드백 반영
│   ├── fix-ci/              CI 로그 분석 + 수정
│   ├── verify/              수정 검증 (테스트/린트/빌드)
│   ├── maintenance/         stale 관리 + 보안 감사
│   └── writing-skills/      새 스킬 작성 가이드
│
├── actions/              ← Composite Actions (공통 단계)
│   ├── load-skills/         중앙 레포 스킬 로드
│   ├── parse-pipeline/      pipeline.yml 파싱
│   ├── gather-context/      프로젝트 컨텍스트 수집
│   └── post-score/          점수 게시
│
├── scripts/              ← GitHub CLI 래퍼
├── templates/            ← 소비자 레포에 복사할 파일
│   ├── workflows/ai.yml     오케스트레이터
│   ├── pipeline.yml         설정 예시
│   └── AGENTS.md            프로젝트 규칙 템플릿
│
└── docs/                 ← 레퍼런스 문서
    └── pipeline-schema.md   pipeline.yml 스키마
```

## 컨텍스트 엔지니어링

AI의 코드 품질은 전달받는 컨텍스트에 비례합니다.
이 파이프라인은 3계층으로 컨텍스트를 주입합니다:

| 계층 | 소스 | 내용 |
|------|------|------|
| 프로젝트 규칙 | `AGENTS.md` | 아키텍처, 컨벤션, 도메인 용어, 금지 사항 |
| 파이프라인 설정 | `pipeline.yml` | 빌드 명령어, 점수 기준, 도메인 컨텍스트 |
| 동적 컨텍스트 | `gather-context` | 최근 커밋, 관련 이슈, 구현 계획 |

### AGENTS.md를 잘 쓰는 법

```markdown
## Domain Knowledge
### 용어 사전
| 용어 | 정의 |
| Workspace | 팀 격리 단위 — workspace_id FK로 모든 테이블에 존재 |

### 비즈니스 규칙
- 결제 코드는 반드시 트랜잭션으로 감쌀 것
- 사용자 삭제는 soft delete만 허용

## Boundaries
- NEVER modify migration files after applied
- NEVER bypass authentication checks
```

## Human-in-the-loop

파이프라인은 완전 자동화가 아닙니다. 핵심 결정에 사람이 개입합니다:

| 단계 | AI 역할 | 사람 역할 |
|------|---------|----------|
| 구체화 | 이슈 분석 + 질문 | 추가 정보 제공 |
| 세분화 | 구현 계획 작성 | **계획 확인 + 승인** |
| 구현 | 코드 작성 | PR 머지 결정 |
| 리뷰 | 코드 검토 + 점수 | 최종 판단 |

`pipeline.require-approval: false`로 설정하면 승인 없이 자동 구현됩니다 (주의).

## 안전장치

- **최소 권한**: 각 스킬에 필요한 도구만 허용 (`allowedTools`)
- **최대 시도**: CI/PR 수정은 N회 제한 (무한 루프 방지)
- **동시 실행 제어**: 같은 이슈/PR에 하나의 파이프라인만 실행
- **skip-ai 라벨**: 특정 이슈/PR에서 AI 비활성화
- **라벨 기반 상태**: 각 단계가 라벨로 추적되어 감사 가능

## 의존성

- `anthropics/claude-code-action@v1`
- GitHub CLI (`gh`) — Runner 기본 제공
- `git` — Runner 기본 제공
- `yq` — parse-pipeline에서 자동 설치

외부 플러그인 의존 없음.
