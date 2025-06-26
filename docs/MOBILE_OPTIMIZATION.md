# 모바일 최적화 가이드

## 📱 개요

이 문서는 Pixel Game 프론트엔드의 모바일 최적화 구현 사항을 설명합니다. 모든 터치 인터페이스, 반응형 디자인, 성능 최적화가 포함되어 있습니다.

## 🎯 최적화 목표

1. **터치 친화적 인터페이스**: 모든 UI 요소가 손가락 터치에 최적화
2. **반응형 디자인**: 다양한 화면 크기와 방향에 자동 적응
3. **성능 최적화**: 60 FPS 유지 및 빠른 터치 응답
4. **접근성**: 한 손 조작 및 안전 영역 지원

## 🔧 구현된 시스템

### 1. TouchHelper 시스템

**위치**: `scripts/utils/TouchHelper.gd`

```gdscript
# 최소 터치 타겟 크기 보장
TouchHelper.ensure_min_touch_size(button)

# 터치 피드백 추가
TouchHelper.add_touch_feedback(control)

# 햅틱 피드백 제공
TouchHelper.provide_haptic_feedback(duration)
```

**기능**:
- 최소 44px × 44px 터치 타겟 크기 자동 보장
- 일관된 터치 피드백 애니메이션
- 모바일 기기에서 햅틱 피드백 지원
- 드래그 제스처 감지 및 유효성 검사

### 2. ResponsiveManager 시스템

**위치**: `scripts/utils/ResponsiveManager.gd`

```gdscript
# 화면 크기 카테고리 확인
var size_category = responsive_manager.get_screen_size_category()

# 반응형 폰트 크기 계산
var font_size = responsive_manager.get_responsive_font_size(base_size)

# 레이아웃 자동 적응
responsive_manager.adapt_container_layout(container)
```

**기능**:
- 화면 크기별 자동 분류 (SMALL, MEDIUM, LARGE, EXTRA_LARGE)
- 뷰포트 크기에 따른 동적 스케일링
- 가로/세로 모드 감지 및 레이아웃 조정
- 안전 영역(Safe Area) 지원

### 3. 향상된 터치 입력

**위치**: `scripts/components/CardUI.gd`

```gdscript
# 터치 및 마우스 이벤트 통합 처리
if event is InputEventScreenTouch:
    if event.pressed:
        touch_start_pos = event.position
        is_potential_drag = true
        _start_drag(event.position)
    else:
        if is_potential_drag and not is_dragging:
            # 탭 제스처
            emit_signal("card_selected", card_data)
        _end_drag()
```

**개선 사항**:
- `InputEventScreenTouch`와 `InputEventScreenDrag` 지원
- 탭과 드래그 제스처 명확한 구분
- 드래그 임계값 기반 제스처 감지
- 부드러운 애니메이션 피드백

### 4. HTML5 모바일 웹 최적화

**위치**: `export/html5/index.html`

```html
<!-- 향상된 뷰포트 설정 -->
<meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover'>

<!-- PWA 지원 -->
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">

<!-- 안전 영역 지원 -->
padding: env(safe-area-inset-top) env(safe-area-inset-right) env(safe-area-inset-bottom) env(safe-area-inset-left);
```

**CSS 최적화**:
- 반응형 폰트 크기: `clamp(16px, 4vw, 18px)`
- 반응형 버튼 크기: `min(240px, 80vw)`
- 터치 액션 최적화: `touch-action: manipulation`
- 미디어 쿼리로 다양한 화면 크기 대응

## 📏 UI 크기 가이드라인

### 터치 타겟 크기
- **최소 크기**: 44px × 44px (iOS 가이드라인)
- **권장 크기**: 56px × 56px (Material Design)
- **메인 버튼**: 240px × 56px
- **카드**: 140px × 180px

### 간격 및 패딩
- **소형 화면**: 12px 간격
- **중형 화면**: 16px 간격
- **대형 화면**: 20-24px 간격

## 🧪 테스트 프레임워크

**위치**: `scripts/screens/MobileTestScene.gd`

### 자동화된 테스트
1. **화면 크기 감지**: 현재 뷰포트 크기 및 모바일 여부 확인
2. **터치 타겟 크기**: 모든 UI 요소가 최소 크기 요구사항을 충족하는지 검증
3. **반응형 스케일링**: ResponsiveManager 기능 테스트
4. **TouchHelper 기능**: 최소 크기 적용 및 피드백 시스템 검증

### 인터랙티브 테스트
1. **터치 응답 시간**: 100ms 이내 응답 확인
2. **카드 드래그**: 드래그 앤 드롭 기능 테스트
3. **카드 탭**: 탭 제스처 인식 테스트

## 🎮 사용 방법

### 개발자용

```gdscript
# 새 UI 요소에 터치 최적화 적용
func _ready():
    TouchHelper.add_touch_feedback(my_button)
    TouchHelper.ensure_min_touch_size(my_button)

# 반응형 디자인 적용
func setup_responsive_layout():
    var responsive_manager = get_node("/root/Main/ResponsiveManager")
    responsive_manager.adapt_container_layout(my_container)
    
    # 폰트 크기 자동 조정
    var responsive_font_size = responsive_manager.get_responsive_font_size(16)
    my_label.add_theme_font_size_override("font_size", responsive_font_size)
```

### 테스터용

1. 메인 메뉴에서 "🧪 MOBILE TEST" 버튼 클릭
2. 자동화된 테스트 결과 확인
3. 터치 응답 테스트 버튼으로 인터랙티브 테스트
4. 카드 드래그/탭 기능 테스트

## 📱 지원되는 기기 및 브라우저

### 모바일 기기
- **iOS**: Safari (iOS 12+)
- **Android**: Chrome (Android 8+)
- **기타**: Firefox Mobile, Samsung Internet

### 화면 크기
- **소형**: 320px 이하 (iPhone SE 등)
- **중형**: 321px - 480px (표준 스마트폰)
- **대형**: 481px - 768px (대형 스마트폰, 소형 태블릿)
- **특대형**: 768px 이상 (태블릿)

## 🔄 향후 개선 계획

1. **성능 최적화**
   - 60 FPS 보장을 위한 추가 최적화
   - 메모리 사용량 최적화

2. **접근성 개선**
   - 시각/청각 장애인을 위한 접근성 기능
   - 키보드 네비게이션 지원

3. **고급 제스처**
   - 핀치 줌 지원
   - 멀티터치 제스처

4. **PWA 기능 확장**
   - 오프라인 모드 지원
   - 푸시 알림 구현

## 🐛 알려진 이슈 및 해결 방법

### iOS Safari에서 뷰포트 이슈
**문제**: iOS Safari에서 주소창 높이 변화 시 레이아웃 깨짐  
**해결**: CSS `100dvh` (dynamic viewport height) 사용

### Android Chrome에서 터치 지연
**문제**: 터치 이벤트 300ms 지연  
**해결**: `touch-action: manipulation` CSS 속성 적용

### 저사양 기기에서 애니메이션 끊김
**문제**: GPU 가속 부족으로 인한 프레임 드롭  
**해결**: 애니메이션 복잡도 감소 및 하드웨어 가속 활용

## 📚 참고 자료

- [Apple Human Interface Guidelines - Touch](https://developer.apple.com/design/human-interface-guidelines/inputs/touch/)
- [Material Design - Touch targets](https://material.io/design/usability/accessibility.html#layout-and-typography)
- [MDN - Touch events](https://developer.mozilla.org/en-US/docs/Web/API/Touch_events)
- [Godot Engine - Input examples](https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html)

---

이 모바일 최적화 시스템을 통해 모든 사용자가 쾌적한 터치 인터페이스를 경험할 수 있습니다.