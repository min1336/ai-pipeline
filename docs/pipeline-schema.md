# pipeline.yml 스키마 레퍼런스

`.github/pipeline.yml`에서 사용 가능한 모든 필드입니다.
모든 값에 기본값이 있으므로 변경이 필요한 항목만 작성하면 됩니다.

## project

| 필드 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `project.name` | string | `"unknown"` | 프로젝트 이름 |
| `project.language` | string | `"typescript"` | 주 언어 (`typescript`, `python`, `go`, `java`, `rust`) |
| `project.description` | string | — | 프로젝트 설명. AI 컨텍스트로 전달됨 |

## build

AI가 구현 후 검증에 사용하는 명령어.

| 필드 | 타입 | 기본값 | 사용처 |
|------|------|--------|--------|
| `build.install` | string | `"npm install"` | implement |
| `build.test` | string | `"npm test"` | implement, verify, fix-ci |
| `build.lint` | string | `"npm run lint"` | implement, verify, fix-ci |
| `build.type-check` | string | — | verify |
| `build.build` | string | — | verify |

## review

| 필드 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `review.roles` | string[] | `[security, qa, reviewer]` | 활성화할 리뷰 관점 |

## scoring

### scoring.issue

| 필드 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `scoring.issue.threshold` | number | `8` | 이슈 품질 통과 점수 (10점 만점) |

### scoring.review

| 필드 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `scoring.review.threshold` | number | `70` | PR 리뷰 통과 점수 (100점 만점) |
| `scoring.review.weights.security` | number | `25` | 보안 점수 배점 |
| `scoring.review.weights.testing` | number | `25` | 테스트 점수 배점 |
| `scoring.review.weights.quality` | number | `20` | 코드 품질 점수 배점 |
| `scoring.review.weights.performance` | number | `15` | 성능 점수 배점 |
| `scoring.review.weights.documentation` | number | `15` | 문서 점수 배점 |
| `scoring.review.verdicts.auto-approve` | number | `90` | 자동 승인 임계값 |
| `scoring.review.verdicts.approve` | number | `70` | 승인 권장 임계값 |
| `scoring.review.verdicts.request-changes` | number | `50` | 수정 요청 임계값 |
| `scoring.review.verdicts.block` | number | `0` | 차단 임계값 |

## labels

| 필드 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `labels.auto-rules[].pattern` | string (regex) | — | 이슈 제목/본문 매칭 패턴 |
| `labels.auto-rules[].label` | string | — | 매칭 시 추가할 라벨 |

## safety

| 필드 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `safety.max-ci-fix-attempts` | number | `2` | CI 자동 수정 최대 시도 |
| `safety.max-pr-fix-attempts` | number | `2` | PR 피드백 반영 최대 시도 |
| `safety.stale-days` | number | `30` | 비활동 경고 일수 |
| `safety.close-days` | number | `60` | 자동 닫기 일수 |
| `safety.protected-labels` | string[] | `[]` | 자동 닫기 면제 라벨 |

## pipeline

| 필드 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `pipeline.require-approval` | boolean | `true` | 구현 전 사람 승인 필요 여부 |
| `pipeline.max-turns.*` | number | 단계별 상이 | Claude 최대 대화 턴 수 |

## context

AI에게 전달되는 프로젝트 고유 컨텍스트.

| 필드 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `context.architecture` | string | — | 디렉토리 구조 설명 |
| `context.conventions` | string | — | 코딩 컨벤션 |
| `context.glossary` | string | — | 도메인 용어 정의 |

## 파이프라인 라벨 상태 머신

```
이슈 생성
  │
  ▼
[stage/enriching] ←─ 추가 정보 필요
  │
  ▼ (점수 >= threshold)
[stage/enriched]
  │
  ▼
[stage/ready] ←─ 구현 계획 작성 완료
  │
  ▼ (사람이 승인)
[stage/approved]
  │
  ▼
[stage/implementing]
  │
  ▼
PR 생성 → [stage/reviewed] → 머지
```
