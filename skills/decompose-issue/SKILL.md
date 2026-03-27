---
name: decompose-issue
description: 이슈를 분류하고 구현 계획을 작성합니다. stage/enriched 이슈에 자동으로 사용합니다.
argument-hint: "[issue-number]"
allowed-tools: Read, Glob, Grep, Bash(gh issue:*), Bash(gh search:*), Bash(./scripts/edit-issue-labels.sh:*)
---

# 이슈 세분화

## 컨텍스트

- pipeline 설정: !`cat .github/pipeline.yml 2>/dev/null || echo "설정 없음"`
- 이슈 라벨: !`gh issue view $ARGUMENTS --json labels --jq '.labels[].name' 2>/dev/null || echo "라벨 없음"`

## 작업 절차

### 1. 이슈 및 분석 댓글 읽기

```bash
gh issue view $ARGUMENTS --json title,body,labels,comments
```

PIPELINE 마커에서 이전 단계 정보 확인 (stage, score).

### 2. 유형/우선순위 분류

pipeline.yml의 `labels.auto-rules`에 따라 자동 라벨 매칭.

**우선순위 기준:**
- `priority/critical`: 서비스 중단, 보안 취약점, 데이터 손실
- `priority/high`: 핵심 기능 장애, 많은 사용자 영향
- `priority/medium`: 일반 개선, 새 기능
- `priority/low`: 사소한 개선, 오타, 스타일

### 3. 중복 검사

```bash
gh search issues --repo $REPO --state open "관련 키워드" --limit 5
```

유사 이슈가 있으면 댓글에 언급.

### 4. 코드베이스 분석

이슈 해결에 필요한 파일과 모듈을 탐색:
- 관련 파일 목록
- 변경이 필요한 파일 (생성/수정/삭제)
- 영향받는 다른 모듈
- 필요한 의존성 변경

### 5. 구현 계획 작성

```markdown
## 📐 구현 계획

### 접근 방식
{전략, 알고리즘, 라이브러리 선택 + 근거}

### 변경 파일
| 파일 | 작업 | 설명 |
|------|------|------|
| src/... | 수정 | ... |
| src/... | 생성 | ... |

### 구현 단계
1. {구체적인 단계}
2. {구체적인 단계}
...

### 테스트 계획
- {어떤 테스트를 어떻게}

### 위험 요소
- {잠재적 문제 + 대응 방안}

<!-- PIPELINE:{"stage":"ready","plan":true} -->
```

### 6. 라벨 업데이트

```bash
./scripts/edit-issue-labels.sh --issue $ARGUMENTS --add-label "stage/ready" --add-label "type/{type}" --add-label "priority/{priority}" --remove-label "stage/enriched"
```

## 중요 규칙

- 코드베이스를 실제로 탐색하여 구현 계획을 작성할 것 (추측 금지)
- 변경 파일 테이블에 실제 존재하는 파일 경로를 사용할 것
- 테스트 계획은 프로젝트의 기존 테스트 패턴을 따를 것
- PIPELINE 마커를 반드시 포함할 것
