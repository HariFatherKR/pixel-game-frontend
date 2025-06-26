extends Node
class_name ResponsiveManager

# Responsive Design Manager for Mobile Optimization
# Handles adaptive layouts based on screen size and orientation

signal screen_size_changed(new_size: Vector2)
signal orientation_changed(is_portrait: bool)

var current_screen_size: Vector2
var is_portrait_mode: bool = true
var base_resolution := Vector2(360, 640)  # Target mobile resolution

# Screen size breakpoints
const SMALL_SCREEN_WIDTH = 320
const MEDIUM_SCREEN_WIDTH = 480
const LARGE_SCREEN_WIDTH = 768

enum ScreenSize {
	SMALL,
	MEDIUM,
	LARGE,
	EXTRA_LARGE
}

func _ready():
	name = "ResponsiveManager"
	_update_screen_info()
	
	# Connect to screen size changes
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _update_screen_info():
	var viewport = get_viewport()
	current_screen_size = viewport.size
	is_portrait_mode = current_screen_size.y > current_screen_size.x
	
	print("Screen size updated: ", current_screen_size, " Portrait: ", is_portrait_mode)

func _on_viewport_size_changed():
	var old_portrait = is_portrait_mode
	_update_screen_info()
	
	screen_size_changed.emit(current_screen_size)
	
	if old_portrait != is_portrait_mode:
		orientation_changed.emit(is_portrait_mode)

func get_screen_size_category() -> ScreenSize:
	var width = current_screen_size.x
	
	if width < SMALL_SCREEN_WIDTH:
		return ScreenSize.SMALL
	elif width < MEDIUM_SCREEN_WIDTH:
		return ScreenSize.MEDIUM
	elif width < LARGE_SCREEN_WIDTH:
		return ScreenSize.LARGE
	else:
		return ScreenSize.EXTRA_LARGE

func get_scale_factor() -> float:
	# Calculate scale factor based on current screen vs base resolution
	var scale_x = current_screen_size.x / base_resolution.x
	var scale_y = current_screen_size.y / base_resolution.y
	
	# Use the smaller scale to maintain aspect ratio
	return min(scale_x, scale_y)

func get_responsive_font_size(base_size: int) -> int:
	var scale = get_scale_factor()
	var min_scale = 0.8  # Minimum 80% of base size
	var max_scale = 1.5  # Maximum 150% of base size
	
	scale = clamp(scale, min_scale, max_scale)
	return int(base_size * scale)

func get_responsive_spacing(base_spacing: int) -> int:
	var scale = get_scale_factor()
	return max(int(base_spacing * scale), base_spacing)

func get_responsive_size(base_size: Vector2) -> Vector2:
	var scale = get_scale_factor()
	return Vector2(
		max(base_size.x * scale, base_size.x * 0.8),
		max(base_size.y * scale, base_size.y * 0.8)
	)

# Adapt container layout for current screen size
func adapt_container_layout(container: Container):
	if not container:
		return
	
	var screen_category = get_screen_size_category()
	var spacing = 16  # Base spacing
	
	match screen_category:
		ScreenSize.SMALL:
			spacing = 12
		ScreenSize.MEDIUM:
			spacing = 16
		ScreenSize.LARGE:
			spacing = 20
		ScreenSize.EXTRA_LARGE:
			spacing = 24
	
	# Apply responsive spacing
	if container is VBoxContainer:
		container.add_theme_constant_override("separation", spacing)
	elif container is HBoxContainer:
		container.add_theme_constant_override("separation", spacing)
	elif container is GridContainer:
		container.add_theme_constant_override("h_separation", spacing)
		container.add_theme_constant_override("v_separation", spacing)

# Optimize card layout for current screen
func optimize_card_layout(card_container: Container, card_size: Vector2):
	if not card_container:
		return
	
	var available_width = current_screen_size.x - 40  # Account for margins
	var cards_per_row = max(1, int(available_width / (card_size.x + 10)))
	
	# Adjust card container based on available space
	if card_container is HBoxContainer:
		# For horizontal layout, ensure cards fit properly
		var total_cards_width = cards_per_row * card_size.x
		var total_spacing = (cards_per_row - 1) * 10
		
		if total_cards_width + total_spacing > available_width:
			# Scale down cards if needed
			var scale_factor = available_width / (total_cards_width + total_spacing)
			card_container.scale = Vector2(scale_factor, scale_factor)

# Apply safe area margins for devices with notches, etc.
func apply_safe_area_margins(control: Control):
	if not control:
		return
	
	# Get safe area from the OS (if available)
	var safe_area = DisplayServer.screen_get_usable_rect()
	var screen_rect = DisplayServer.screen_get_size()
	
	# Calculate margins based on safe area
	var top_margin = safe_area.position.y
	var bottom_margin = screen_rect.y - (safe_area.position.y + safe_area.size.y)
	var left_margin = safe_area.position.x
	var right_margin = screen_rect.x - (safe_area.position.x + safe_area.size.x)
	
	# Apply margins to the control
	if control.get_parent() is Control:
		control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		control.offset_left = left_margin
		control.offset_top = top_margin
		control.offset_right = -right_margin
		control.offset_bottom = -bottom_margin

# Get optimal button size for current screen
func get_optimal_button_size() -> Vector2:
	var base_size = Vector2(240, 56)
	return get_responsive_size(base_size)