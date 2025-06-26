extends RefCounted
class_name TouchHelper

# Touch Helper Utility for Mobile Optimization
# Provides consistent touch feedback and gesture handling

const MIN_TOUCH_SIZE = 44  # Minimum touch target size in pixels
const TOUCH_FEEDBACK_DURATION = 0.15
const HAPTIC_FEEDBACK_DURATION = 30  # milliseconds

# Enhanced touch feedback for UI elements
static func add_touch_feedback(node: Control):
	if not node:
		return
	
	# Ensure minimum touch size
	ensure_min_touch_size(node)
	
	# Connect mouse/touch events for visual feedback
	if not node.mouse_entered.is_connected(_on_touch_enter):
		node.mouse_entered.connect(_on_touch_enter.bind(node))
	if not node.mouse_exited.is_connected(_on_touch_exit):
		node.mouse_exited.connect(_on_touch_exit.bind(node))

static func ensure_min_touch_size(node: Control):
	if not node:
		return
	
	var current_size = node.size
	var min_size = Vector2(MIN_TOUCH_SIZE, MIN_TOUCH_SIZE)
	
	if current_size.x < min_size.x or current_size.y < min_size.y:
		node.custom_minimum_size = Vector2(
			max(current_size.x, min_size.x),
			max(current_size.y, min_size.y)
		)

static func _on_touch_enter(node: Control):
	if not node:
		return
	
	var tween = node.create_tween()
	tween.tween_property(node, "scale", Vector2(1.05, 1.05), TOUCH_FEEDBACK_DURATION)
	tween.parallel().tween_property(node, "modulate", Color(1.1, 1.1, 1.1, 1.0), TOUCH_FEEDBACK_DURATION)

static func _on_touch_exit(node: Control):
	if not node:
		return
	
	var tween = node.create_tween()
	tween.tween_property(node, "scale", Vector2(1.0, 1.0), TOUCH_FEEDBACK_DURATION)
	tween.parallel().tween_property(node, "modulate", Color(1.0, 1.0, 1.0, 1.0), TOUCH_FEEDBACK_DURATION)

# Create press feedback animation
static func create_press_feedback(node: Control):
	if not node:
		return
	
	var tween = node.create_tween()
	tween.tween_property(node, "scale", Vector2(0.95, 0.95), 0.05)
	tween.tween_property(node, "scale", Vector2(1.05, 1.05), 0.05)
	
	# Add haptic feedback for mobile devices
	provide_haptic_feedback()

# Provide haptic feedback for mobile devices
static func provide_haptic_feedback(duration: int = HAPTIC_FEEDBACK_DURATION):
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(duration)

# Enhanced drag detection for cards
static func is_drag_gesture(start_pos: Vector2, current_pos: Vector2, threshold: float = 10.0) -> bool:
	return start_pos.distance_to(current_pos) > threshold

# Check if touch is within bounds with tolerance
static func is_touch_in_bounds(touch_pos: Vector2, rect: Rect2, tolerance: float = 5.0) -> bool:
	var expanded_rect = Rect2(
		rect.position - Vector2(tolerance, tolerance),
		rect.size + Vector2(tolerance * 2, tolerance * 2)
	)
	return expanded_rect.has_point(touch_pos)

# Optimize layout for mobile screens
static func optimize_mobile_layout(container: Container):
	if not container:
		return
	
	# Add appropriate spacing for touch targets
	if container is VBoxContainer:
		container.add_theme_constant_override("separation", 16)
	elif container is HBoxContainer:
		container.add_theme_constant_override("separation", 12)
	
	# Ensure children have proper touch sizes
	for child in container.get_children():
		if child is Control:
			ensure_min_touch_size(child)

# Create responsive font size based on screen size
static func get_responsive_font_size(base_size: int) -> int:
	var viewport = Engine.get_main_loop().get_viewport()
	if not viewport:
		return base_size
	
	var screen_scale = min(viewport.size.x / 360.0, viewport.size.y / 640.0)
	return int(base_size * max(screen_scale, 0.8))  # Minimum 80% of base size