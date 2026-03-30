# AGENTS.md
<!-- 이 파일을 프로젝트 루트에 복사한 후 수정하세요. -->
<!-- Claude Code가 모든 세션에서 자동으로 읽는 프로젝트 맥락 파일입니다. -->
<!-- 내용이 풍부할수록 AI의 코드 품질이 올라갑니다. -->

## Build & Test

```bash
# 의존성 설치
npm install

# 개발 서버
npm run dev

# 테스트
npm test

# 린트
npm run lint

# 빌드
npm run build
```

## Architecture

<!-- 프로젝트의 핵심 구조를 설명하세요. AI가 코드를 작성할 때 가장 먼저 참고합니다. -->

```
src/
├── app/           ← 라우트 (Next.js App Router)
├── components/    ← UI 컴포넌트
├── lib/           ← 비즈니스 로직
├── services/      ← 외부 API 연동
├── models/        ← 데이터 모델/타입
└── utils/         ← 순수 유틸리티 함수
```

### 데이터 흐름

<!-- 요청이 어떻게 처리되는지 간략히 설명하세요. -->

```
Client → API Route → Service → Database
                   ↓
              Validation → Error Response
```

### 핵심 모듈

<!-- 주요 모듈의 책임을 한 줄로 설명하세요. -->

| 모듈 | 책임 | 주의사항 |
|------|------|---------|
| `lib/auth` | 인증/인가 | 세션 토큰 형식 변경 금지 |
| `lib/db` | DB 연결/쿼리 | 커넥션 풀 직접 관리 금지 |
| `services/payment` | 결제 처리 | 테스트 시 반드시 mock 사용 |

## Code Conventions

<!-- AI가 따라야 할 코딩 규칙. 구체적일수록 좋습니다. -->

### 스타일
- 한국어 주석
- Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`
- 함수/변수: camelCase, 타입/클래스: PascalCase
- 파일명: kebab-case

### 패턴
- 에러 핸들링: `throw` 대신 `Result<T, E>` 패턴 (해당 시)
- API 응답: `{ data, error, status }` 형태 통일
- 비동기: `async/await` 사용, `.then()` 체인 금지
- Import 순서: 외부 → 내부 → 상대경로 → 타입

### 테스트
- 테스트 파일: 같은 디렉토리에 `*.test.ts`
- 네이밍: `describe('모듈명')` > `it('한국어로 동작 설명')`
- Mock: 외부 서비스만 mock, 내부 로직은 실제 실행

## Domain Knowledge

<!-- AI가 알아야 할 비즈니스 도메인 정보. 이것이 코드 품질을 결정합니다. -->

### 용어 사전

| 용어 | 정의 | 코드에서 |
|------|------|---------|
| Workspace | 팀 격리 단위 | `workspace_id` FK |
| Member | Workspace 구성원 | `User` + `WorkspaceMember` |
| Pipeline | 자동화 흐름 | `PipelineRun` 테이블 |

### 비즈니스 규칙

<!-- AI가 구현 시 반드시 지켜야 할 비즈니스 로직 -->

- 결제 관련 코드는 반드시 트랜잭션으로 감싸야 함
- 사용자 삭제는 soft delete (deleted_at 타임스탬프)
- 멀티테넌시: 모든 쿼리에 workspace_id 필터 필수

### 외부 연동

| 서비스 | 용도 | 환경변수 |
|--------|------|---------|
| Stripe | 결제 | `STRIPE_SECRET_KEY` |
| SendGrid | 이메일 | `SENDGRID_API_KEY` |
| S3 | 파일 저장 | `AWS_*` |

## Boundaries

<!-- AI가 절대 하면 안 되는 것 -->

- NEVER modify migration files after they've been applied
- NEVER hardcode API keys or secrets
- NEVER bypass authentication checks
- NEVER delete data without soft delete
- NEVER change public API response shapes (breaking change)
- NEVER add dependencies without documenting why in the PR

## Recent Decisions

<!-- 최근 내린 아키텍처 결정. AI가 이전 결정과 모순되는 코드를 쓰지 않도록. -->
<!-- 날짜를 포함하세요. 오래된 결정은 정리하세요. -->

| 날짜 | 결정 | 이유 |
|------|------|------|
| 2024-03 | ORM → Raw SQL 전환 | 복잡한 쿼리 성능 문제 |
| 2024-02 | Monorepo 도입 | 공유 타입 동기화 비용 |
