---
name: enrich-issue
description: 새 이슈를 분석하고 품질 점수를 산출합니다. 이슈가 열렸을 때 자동으로 사용합니다.
argument-hint: "[issue-number]"
allowed-tools: Read, Glob, Grep, Bash(gh issue:*), Bash(gh search:*), Bash(./scripts/edit-issue-labels.sh:*)
---

# 이슈 구체화

## 컨텍스트

- pipeline 설정: !`cat .github/pipeline.yml 2>/dev/null || echo "설정 없음 — 기본값 사용"`
- 프로젝트 구조: !`find . -maxdepth 2 -type f -name "*.ts" -o -name "*.py" -o -name "*.go" -o -name "*.java" | head -20`

## 작업 절차

### 1. 이슈 읽기

```bash
gh issue view $ARGUMENTS --json title,body,labels,author
```

### 2. 이슈 유형 판별

이슈 제목과 본문을 읽고 유형을 판별:
- **bug**: 오류, 장애, 예상과 다른 동작
- **feature**: 새로운 기능 요청
- **enhancement**: 기존 기능 개선
- **docs**: 문서 추가/수정
- **question**: 질문

### 3. 품질 점수 산출

채점 기준은 [scoring.md](scoring.md) 참조.
유형별로 다른 기준을 적용하여 10점 만점으로 채점.

### 4. 코드베이스 분석

이슈와 관련된 파일을 탐색:
- 키워드로 관련 파일 검색 (Grep, Glob)
- 관련 코드 영역 파악
- 영향 범위 추정

### 5. 결과 게시

#### 점수 >= threshold (기본 8점)

이슈에 분석 댓글 게시:

```markdown
## 🔍 이슈 분석 완료

**유형:** {type}
**점수:** {score}/10
**관련 파일:** {files}

### 분석 요약
{summary}

### 영향 범위
{scope}

<!-- PIPELINE:{"stage":"enriched","score":{score}} -->
```

라벨 추가:
```bash
./scripts/edit-issue-labels.sh --issue $ARGUMENTS --add-label "stage/enriched" --add-label "type/{type}"
```

#### 점수 < threshold

부족한 정보를 질문하는 댓글 게시:

```markdown
## 📝 추가 정보가 필요합니다

**현재 점수:** {score}/10 (기준: {threshold}점)

다음 정보를 추가해주시면 더 정확하게 처리할 수 있습니다:

{questions}

<!-- PIPELINE:{"stage":"enriching","score":{score},"attempts":1} -->
```

라벨 추가:
```bash
./scripts/edit-issue-labels.sh --issue $ARGUMENTS --add-label "stage/enriching"
```

## 중요 규칙

- 점수 산출은 반드시 scoring.md 기준을 따를 것
- 코드베이스를 실제로 탐색하여 관련 파일을 찾을 것 (추측 금지)
- 댓글에 PIPELINE 마커를 반드시 포함할 것
- stage/enriched와 stage/enriching 라벨은 반드시 스크립트로 추가할 것
