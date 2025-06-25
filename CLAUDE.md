# Claude Code 사용 가이드

## 🚀 빠른 명령어

### Docker 재빌드 및 실행
```bash
./rebuild.sh
```

또는 Claude Code에서 다음 명령어를 입력하세요:
- `/rebuild` - Docker 컨테이너 재빌드 및 실행
- `/logs` - Docker 로그 확인
- `/stop` - Docker 컨테이너 중지

## 📝 주요 작업

### 1. Docker 관리
- **재빌드**: `./rebuild.sh` 또는 `/rebuild`
- **시작**: `docker-compose up -d`
- **중지**: `docker-compose down`
- **로그**: `docker-compose logs -f`

### 2. Git 작업
- **커밋 & 푸시**: 작업 완료 시 자동으로 수행됨
- **상태 확인**: `git status`

### 3. 접속 URL
- **로컬 테스트**: http://localhost:8081

## 🛠 개발 팁

1. **Godot 씬 수정 후**: Docker 재빌드 필요 없음 (HTML5 익스포트 전까지)
2. **HTML/CSS 수정 후**: `./rebuild.sh` 실행
3. **포트 충돌 시**: docker-compose.yml에서 포트 변경

## 📂 프로젝트 구조
```
frontend/
├── scenes/          # Godot 씬 파일
├── scripts/         # GDScript 파일
├── assets/          # 에셋 (이미지, 사운드 등)
├── export/html5/    # 웹 빌드 출력
├── rebuild.sh       # Docker 재빌드 스크립트
└── docker-compose.yml
```