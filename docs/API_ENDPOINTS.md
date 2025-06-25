# API 엔드포인트 문서

## 서버 정보

- **베이스 URL**: http://localhost:8080
- **API 베이스**: `/api/v1`
- **상태**: ✅ 실행 중
- **버전**: 0.1.0 (dev)

## 🎯 확인된 엔드포인트

### 시스템
- `GET /health` - 서버 상태 확인 ✅
- `GET /v1/version` - API 버전 정보 ✅

### 카드 관리
- `GET /api/v1/cards` - 카드 목록 조회 ✅
- `GET /api/v1/cards/{id}` - 특정 카드 조회 ✅

## 📊 API 응답 예시

### GET /v1/version
```json
{
  "version": "0.1.0",
  "build": "dev"
}
```

### GET /health
```json
{
  "status": "healthy",
  "service": "pixel-game-backend",
  "timestamp": 1750828495
}
```

### GET /api/v1/cards
```json
{
  "cards": [
    {
      "id": 1,
      "name": "Code Slash",
      "type": "action",
      "cost": 2,
      "description": "Deal 8 damage and apply Vulnerable"
    },
    {
      "id": 2,
      "name": "Firewall Up",
      "type": "action", 
      "cost": 1,
      "description": "Gain 10 Shield"
    },
    {
      "id": 3,
      "name": "Bug Found",
      "type": "event",
      "cost": 0,
      "description": "Disable all traps, gain 1 random card"
    }
  ],
  "total": 3
}
```

## 🔧 데이터 모델

### Card
```typescript
{
  id: number,
  name: string,
  type: "action" | "event" | "power",
  cost: number,
  description: string
}
```

### CardsResponse
```typescript
{
  cards: Card[],
  total: number
}
```

### ErrorResponse
```typescript
{
  error: string,
  message: string
}
```

## 🔐 인증

API는 `ApiKeyAuth` 방식을 지원하며, `Authorization` 헤더를 사용합니다.

## 📝 미구현 엔드포인트 (예상)

아직 구현되지 않았지만 필요할 것으로 예상되는 엔드포인트:

- `POST /api/v1/auth/register` - 회원가입
- `POST /api/v1/auth/login` - 로그인
- `GET /api/v1/decks` - 덱 목록
- `POST /api/v1/decks` - 덱 생성
- `PUT /api/v1/decks/{id}` - 덱 수정
- `DELETE /api/v1/decks/{id}` - 덱 삭제
- `WS /ws` - WebSocket 연결

---
*업데이트: 2025-06-25*