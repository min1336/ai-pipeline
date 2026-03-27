# 역할 정의

pipeline.yml의 `review.roles`에서 활성화된 역할만 사용.

## 사용 가능한 역할

### architect (아키텍트)
- 설계 패턴, 모듈 구조, 의존성 관계
- 시스템 일관성, 확장성
- 기존 아키텍처와의 정합성

### security (보안)
- OWASP Top 10: injection, XSS, CSRF, SSRF
- 하드코딩된 비밀값, 인증 우회
- 입력 검증, 안전하지 않은 역직렬화

### qa (품질보증)
- 테스트 시나리오, 엣지 케이스
- 실패 모드, 회귀 위험
- 테스트 커버리지 충분성

### reviewer (코드 리뷰어)
- 코드 패턴, 컨벤션 준수
- 중복, 복잡도, 에러 핸들링
- 성능 (N+1, 메모리 누수)

### designer (디자이너)
- 컴포넌트 구조, 디자인 시스템
- 접근성 (aria, 키보드 내비게이션, 색상 대비)
- 반응형, UX 흐름

### po (프로덕트 오너)
- 비즈니스 가치, MVP 범위
- 성공 지표, 우선순위
- 사용자 영향

## 팀 크기 결정 (team-discuss 활성화 시)

- **simple**: 낮은 우선순위 + 단순 키워드 (typo, color, text) → 2명
- **normal**: 중간 규모 → 3~4명
- **complex**: 높은 우선순위 OR 복잡 키워드 (auth, payment, migration, security) → 전원
