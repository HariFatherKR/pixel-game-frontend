# API 엔드포인트 문서

## 서버 정보

- **베이스 URL**: http://localhost:8080
- **상태**: ✅ 실행 중
- **인증**: JWT Bearer Token (대부분의 엔드포인트에 필요)

## 🔐 인증 엔드포인트

### POST /auth/register
- **설명**: 새 사용자 등록
- **요청 본문**:
  ```json
  {
    "username": "string",
    "email": "string",
    "password": "string",
    "platform": "web" // web/android/ios
  }
  ```
- **응답**: AuthResponse (token, refresh_token, user 정보)

### POST /auth/login
- **설명**: 사용자 로그인
- **요청 본문**:
  ```json
  {
    "username": "string",
    "password": "string"
  }
  ```
- **응답**: AuthResponse (token, refresh_token, user 정보)

## 🎴 카드 관리 엔드포인트

### GET /cards
- **설명**: 모든 카드 목록 조회
- **인증**: 필요 ✅
- **쿼리 파라미터**:
  - `type`: 카드 타입 필터
  - `rarity`: 희귀도 필터
  - `page`: 페이지 번호
  - `limit`: 페이지당 항목 수
- **응답**: CardsResponse (cards 배열, 페이지네이션 정보)

### GET /cards/my-collection
- **설명**: 내 카드 컬렉션 조회
- **인증**: 필요 ✅
- **응답**: 사용자의 카드 컬렉션

## 🗂️ 덱 관리 엔드포인트

### GET /cards/decks
- **설명**: 내 덱 목록 조회
- **인증**: 필요 ✅
- **응답**: 덱 목록 배열

### POST /cards/decks
- **설명**: 새 덱 생성
- **인증**: 필요 ✅
- **요청 본문**:
  ```json
  {
    "name": "string",
    "card_ids": [1, 2, 3, ...] // 10-30장
  }
  ```
- **응답**: 생성된 Deck 객체

## 🎮 게임 세션 엔드포인트

### POST /games/start
- **설명**: 새 게임 시작
- **인증**: 필요 ✅
- **요청 본문**:
  ```json
  {
    "game_mode": "STORY", // STORY/DAILY_CHALLENGE/EVENT
    "deck_id": 1 // 선택사항
  }
  ```
- **응답**: GameSession 객체

### GET /games/current
- **설명**: 현재 진행 중인 게임 조회
- **인증**: 필요 ✅
- **응답**: GameSession 객체

### GET /games/{id}
- **설명**: 특정 게임 조회
- **인증**: 필요 ✅
- **경로 파라미터**: id (게임 ID)
- **응답**: GameSession 객체

### POST /games/{id}/actions
- **설명**: 게임 액션 수행
- **인증**: 필요 ✅
- **경로 파라미터**: id (게임 ID)
- **요청 본문**:
  ```json
  {
    "action_type": "PLAY_CARD", // PLAY_CARD/END_TURN/USE_POTION
    "card_id": 1, // 선택사항
    "target_id": 1, // 선택사항
    "action_data": {} // 선택사항
  }
  ```
- **응답**: 액션 결과

### POST /games/{id}/end-turn
- **설명**: 턴 종료
- **인증**: 필요 ✅
- **경로 파라미터**: id (게임 ID)
- **응답**: 턴 결과

### POST /games/{id}/surrender
- **설명**: 게임 포기
- **인증**: 필요 ✅
- **경로 파라미터**: id (게임 ID)
- **응답**: 포기 결과

### GET /games/stats
- **설명**: 게임 통계 조회
- **인증**: 필요 ✅
- **응답**: UserGameStats 객체

## 🔧 시스템 엔드포인트

### GET /health
- **설명**: 서버 상태 확인
- **인증**: 불필요
- **응답**: HealthResponse

## 📊 데이터 모델

### Card
```typescript
{
  id: number,
  name: string,
  description: string,
  type: "ACTION" | "EVENT" | "POWER",
  rarity: "COMMON" | "RARE" | "EPIC" | "LEGENDARY",
  cost: number
}
```

### Deck
```typescript
{
  id: number,
  user_id: number,
  name: string,
  card_ids: number[],
  is_active: boolean
}
```

### GameSession
```typescript
{
  id: number,
  status: string,
  game_mode: string,
  current_floor: number,
  turn: number,
  player_state: PlayerState,
  enemy_state: EnemyState
}
```

### AuthResponse
```typescript
{
  token: string,
  refresh_token: string,
  user: {
    id: number,
    username: string,
    email: string
  }
}
```

## 🔑 인증 방법

대부분의 엔드포인트는 JWT Bearer 토큰 인증이 필요합니다:
```
Authorization: Bearer {token}
```

---
*업데이트: 2025-06-25*