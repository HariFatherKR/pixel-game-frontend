# Pixel Game Frontend

사이버펑크 테마의 덱빌딩 카드 게임 프론트엔드 (Godot Engine)

## 프로젝트 개요

- **엔진**: Godot 4.3+
- **언어**: GDScript
- **플랫폼**: Android, iOS, Web (PWA)
- **테마**: 사이버펑크 + B급 감성

## 시작하기

### Docker로 실행 (권장)

```bash
# 빠른 재빌드 및 실행
./rebuild.sh

# 또는 수동으로
docker-compose up --build

# 브라우저에서 접속
# http://localhost:8081
```

### 빠른 명령어
- `./rebuild.sh` - Docker 재빌드 및 실행
- `docker-compose logs -f` - 로그 확인
- `docker-compose down` - 컨테이너 중지

### 로컬 개발

```bash
# Godot 에디터에서 프로젝트 열기
godot project.godot

# F5키로 실행
```

## 프로젝트 구조

```
frontend/
├── scenes/          # 씬 파일 (.tscn)
│   ├── components/  # 재사용 가능한 UI 컴포넌트
│   └── screens/     # 화면별 씬
├── scripts/         # GDScript 파일 (.gd)
│   ├── components/  # 컴포넌트 로직
│   └── network/     # 네트워크 통신
├── assets/          # 에셋 파일
└── docs/           # 문서
```

## 주요 기능

- 카드 드래그 앤 드롭 시스템
- 사이버펑크 테마 UI
- 네트워크 통신 (HTTP/WebSocket)
- 모바일 터치 최적화

## 문서

- [프론트엔드 역할 가이드](docs/FRONTEND_ROLE.md)
- [제품 요구사항 문서](docs/PRD.md)