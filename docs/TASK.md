# 프론트엔드 개발 태스크 추적

## 📋 태스크 목록

### ✅ 완료된 태스크

#### Phase 1: 프로젝트 초기 설정
- [x] Git 저장소 초기화 및 GitHub 연결
- [x] Godot 프로젝트 기본 구조 생성
- [x] Docker 환경 설정 (Dockerfile, docker-compose.yml)
- [x] 자동 재빌드 스크립트 생성 (rebuild.sh)
- [x] 기본 씬 파일 생성 (Main.tscn, MainMenu.tscn, Card.tscn)
- [x] 기본 스크립트 구현 (Main.gd, MainMenu.gd, Card.gd)
- [x] 네트워크 모듈 스켈레톤 생성 (APIClient.gd, GameClient.gd)

### ✅ 완료된 태스크

#### Phase 2: API 연동
- [x] 서버 상태 확인 (/health 엔드포인트 발견)
- [x] Swagger UI 확인 및 API 문서화 완료
- [x] API 엔드포인트 문서화 (docs/API_ENDPOINTS.md)
- [x] APIClient.gd 실제 API에 맞게 업데이트
- [x] 카드 목록 화면 구현 (CardList.tscn, CardList.gd)
- [x] 메인 메뉴에서 카드 목록으로 네비게이션 구현
- [x] 실제 서버 데이터와 연동된 카드 표시

### 🚧 진행 중

#### Phase 2: API 연동 (추가)
- [ ] 개별 카드 상세 조회 기능
- [ ] 로그인/회원가입 기능 구현 (서버 구현 대기 중)
- [ ] JWT 토큰 관리

### 📅 예정된 태스크

#### Phase 3: 게임 핵심 기능
- [ ] 카드 데이터 API 연동
- [ ] 카드 목록 화면 구현
- [ ] 덱 빌더 화면 구현
- [ ] 덱 저장/불러오기 기능

#### Phase 4: 전투 시스템
- [ ] 전투 씬 구현 (BattleScene)
- [ ] 카드 드래그 앤 드롭 개선
- [ ] 턴제 전투 로직
- [ ] 에너지 시스템
- [ ] 카드 효과 시스템

#### Phase 5: WebSocket 실시간 통신
- [ ] WebSocket 연결 구현
- [ ] 실시간 게임 상태 동기화
- [ ] 멀티플레이어 매칭 시스템
- [ ] 재연결 로직

#### Phase 6: UI/UX 개선
- [ ] 사이버펑크 테마 적용
- [ ] 애니메이션 효과 추가
- [ ] 사운드 효과 및 BGM
- [ ] 모바일 터치 최적화

#### Phase 7: JavaScript Bridge
- [ ] Godot ↔ JavaScript 통신 구현
- [ ] 카드 효과의 DOM 조작
- [ ] 콘솔 패널 구현
- [ ] 코드 실행 시각화

## 🔧 기술 스택

- **게임 엔진**: Godot 4.3+
- **언어**: GDScript
- **백엔드 API**: Go (Gin Framework)
- **배포**: Docker, nginx
- **플랫폼**: Web (PWA), Android, iOS

## 📝 개발 노트

### 2025-06-25
- 프로젝트 초기 설정 완료
- Docker 환경 구축 완료
- 기본 UI 구조 생성
- API 서버 연동 준비 중

### API 엔드포인트 (예상)
```
POST   /api/auth/register     # 회원가입
POST   /api/auth/login        # 로그인
GET    /api/cards             # 카드 목록
GET    /api/cards/:id         # 카드 상세
GET    /api/decks             # 덱 목록
POST   /api/decks             # 덱 생성
PUT    /api/decks/:id         # 덱 수정
DELETE /api/decks/:id         # 덱 삭제
WS     /ws                    # WebSocket 연결
```

## 🐛 이슈 및 해결

### 알려진 이슈
- Swagger 문서 접근 불가 (서버 확인 필요)
- WebSocket 연결 테스트 필요

### 해결된 이슈
- ✅ Docker 포트 충돌 (8080 → 8081로 변경)
- ✅ Godot 씬 파일 구조 오류 수정

## 📊 진행률

전체 진행률: **35%**

- Phase 1: 100% ✅
- Phase 2: 70% 🚧 (API 연동 대부분 완료, 인증 기능 대기 중)
- Phase 3: 0% ⏳
- Phase 4: 0% ⏳
- Phase 5: 0% ⏳
- Phase 6: 0% ⏳
- Phase 7: 0% ⏳

### 최근 완료 사항 (2025-06-25)
- ✅ Swagger API 문서 확인 및 분석
- ✅ API 엔드포인트 완전 문서화
- ✅ APIClient를 실제 서버 API에 맞게 업데이트
- ✅ 카드 목록 화면 구현 및 서버 데이터 연동
- ✅ 메인 메뉴 ↔ 카드 목록 네비게이션 구현