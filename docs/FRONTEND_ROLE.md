# 프론트엔드 개발자 역할 가이드

## 🎯 역할 개요

프론트엔드 개발자로서 Godot Engine을 사용하여 사이버펑크 테마의 덱빌딩 카드 게임 클라이언트를 개발합니다. 모바일 웹 플랫폼을 주 타겟으로 하며, 추후 Android/iOS 네이티브 앱 지원도 고려합니다.

## 🛠 기술 스택

### 게임 엔진
- **Godot Engine 4.3+**: 오픈소스 게임 엔진
- **GDScript**: Godot의 주 프로그래밍 언어
- **HTML5/WebAssembly**: 웹 배포를 위한 내보내기 형식

### 개발 도구
- **Git**: 버전 관리
- **Visual Studio Code**: GDScript 편집 (옵션)
- **Godot Editor**: 씬 편집 및 디버깅

## 📁 프로젝트 구조

```
frontend/
├── scenes/          # 씬 파일 (.tscn)
│   ├── components/  # 재사용 가능한 UI 컴포넌트
│   ├── screens/     # 화면별 씬 (메뉴, 전투, 덱빌더 등)
│   └── effects/     # 비주얼 이펙트 씬
├── scripts/         # GDScript 파일 (.gd)
│   ├── components/  # 컴포넌트 로직
│   ├── network/     # 네트워크 통신
│   ├── game/        # 게임 로직
│   └── utils/       # 유틸리티 함수
├── resources/       # 리소스 파일
│   ├── themes/      # UI 테마
│   ├── fonts/       # 폰트
│   └── shaders/     # 셰이더
└── assets/          # 에셋 파일
    ├── sprites/     # 이미지
    ├── audio/       # 사운드
    └── animations/  # 애니메이션
```

## 📋 주요 책임

### 1. UI/UX 구현
- 사이버펑크 테마의 비주얼 디자인 적용
- 모바일 터치에 최적화된 인터페이스
- 반응형 레이아웃 (다양한 화면 크기 대응)

### 2. 게임플레이 구현
- 카드 드래그 앤 드롭 시스템
- 턴제 전투 메커니즘
- 덱 빌딩 인터페이스
- 애니메이션 및 이펙트

### 3. 네트워크 통신
- RESTful API 클라이언트 (HTTP)
- WebSocket 실시간 통신
- 상태 동기화

### 4. 특수 기능
- "Vibe 코딩" 컨셉 구현
- 카드 효과와 JavaScript/DOM 연동
- 콘솔 로그 시각화

## 🔧 현재 구현 상태

### ✅ 완료된 기능

#### Phase 0: 프로젝트 설정
- Godot 프로젝트 기본 구조
- 모바일 해상도 설정 (360x640)
- 터치 입력 설정
- PWA 지원 활성화

#### Phase 1: 기본 UI
- 메인 메뉴 화면
- 사이버펑크 테마 적용
- 화면 전환 시스템

#### Phase 2: 카드 시스템
- Card 컴포넌트 (드래그 앤 드롭)
- 카드 정보 표시
- 호버 애니메이션

#### Phase 3: 전투 시스템
- BattleScene 구현
- 턴제 전투 로직
- 에너지 시스템
- 카드 핸드 관리 (HandManager)
- 콘솔 패널 (ConsolePanel)

#### 네트워크 모듈
- APIClient (HTTP 통신)
- GameClient (WebSocket)
- 인증, 카드, 덱, 매치 API

### 🚀 진행 중/예정 작업

#### 우선순위 높음
1. **JavaScript Bridge**
   - Godot ↔ JavaScript 통신
   - 카드 효과의 실제 DOM 조작
   - 코드 실행 시각화

2. **카드 효과 시스템**
   - 데미지 애니메이션
   - 상태 이상 표시
   - 화면 효과 (글리치, 네온 등)

#### 중간 우선순위
1. **덱 빌더 화면**
   - 카드 컬렉션 UI
   - 덱 편집 기능
   - 필터/정렬 시스템

2. **추가 게임 모드**
   - 스토리 모드
   - 일일 챌린지
   - 이벤트 모드

## 💻 개발 가이드

### 시작하기
```bash
# 프로젝트 클론
git clone [repository-url]
cd pixel-game/frontend

# Godot에서 프로젝트 열기
godot project.godot
```

### 코딩 컨벤션
- **씬 파일**: PascalCase (예: `MainMenu.tscn`)
- **스크립트**: PascalCase (예: `CardManager.gd`)
- **변수**: snake_case
- **신호**: snake_case
- **함수**: snake_case

### 브랜치 전략
- `main`: 프로덕션 브랜치
- `develop`: 개발 브랜치
- `feature/*`: 기능 개발
- `fix/*`: 버그 수정

### 커밋 메시지
```
feat(frontend): 새로운 기능 추가
fix(frontend): 버그 수정
docs: 문서 업데이트
style: 코드 스타일 변경
refactor: 코드 리팩토링
```

## 🔗 주요 파일 위치

### 문서
- `docs/PRD.md`: 제품 요구사항 문서
- `docs/FRONTEND_TASKS.md`: 프론트엔드 태스크 목록
- `docs/FRONTEND_TECH_REVIEW.md`: 기술 스택 검토
- `docs/BATTLE_SYSTEM_PROGRESS.md`: 전투 시스템 진행 상황

### 핵심 스크립트
- `scripts/Main.gd`: 메인 게임 컨트롤러
- `scripts/screens/BattleScene.gd`: 전투 화면 로직
- `scripts/components/Card.gd`: 카드 컴포넌트
- `scripts/network/APIClient.gd`: HTTP 클라이언트
- `scripts/network/GameClient.gd`: WebSocket 클라이언트

## 🤝 협업 가이드

### PM과의 소통
- 기능 우선순위 확인
- 진행 상황 정기 보고
- 기술적 이슈 공유

### 백엔드 팀과의 협업
- API 스펙 확인 및 피드백
- WebSocket 메시지 포맷 협의
- 에러 처리 방식 통일

### 디자인 요구사항
- 사이버펑크 테마 유지
- B급 감성의 유머 요소
- 네온 색상 팔레트 (시안, 마젠타, 그린)
- 터미널/콘솔 스타일 UI

## 📚 참고 자료

### Godot 문서
- [Godot Engine Documentation](https://docs.godotengine.org/)
- [GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/)
- [Mobile Development](https://docs.godotengine.org/en/stable/tutorials/platform/android/index.html)

### 프로젝트 특화
- PRD의 "Vibe 코딩" 컨셉 이해
- 카드 효과와 코드 실행의 연동
- 사이버펑크 비주얼 레퍼런스

## 🎮 테스트 및 디버깅

### 로컬 테스트
1. Godot Editor에서 F6 키로 현재 씬 실행
2. F5 키로 메인 씬부터 실행
3. 디버거 패널에서 변수 확인

### 웹 빌드 테스트
```bash
# HTML5로 내보내기 후
python -m http.server 8000
# 브라우저에서 localhost:8000 접속
```

### 주의사항
- 모바일 터치 이벤트 테스트
- 다양한 해상도에서 UI 확인
- 네트워크 지연 시나리오 고려

## 🚨 알려진 이슈 및 해결책

### 현재 이슈
- JavaScript Bridge 미구현 (기술 스택 결정 대기)
- 블록(방어) 시스템 미구현
- 상태 이상 효과 미구현

### 기술적 고려사항
- Godot vs 순수 웹 기술 스택 선택
- DOM 조작 효과 구현 방식
- 크로스 플랫폼 빌드 전략

## 📈 성과 지표

- 프레임레이트 유지 (60 FPS)
- 터치 반응성 (100ms 이내)
- 메모리 사용량 최적화
- 네트워크 대역폭 효율성

---

새로운 AI가 이 문서를 참고하여 프론트엔드 개발을 계속 진행할 수 있도록 작성되었습니다. 질문이나 추가 정보가 필요한 경우 팀과 소통하시기 바랍니다.