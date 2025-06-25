extends Control
class_name Card

signal card_used(card)
signal card_hovered(card)
signal card_drag_started(card)
signal card_drag_ended(card)

@export var card_data: Dictionary = {}
@export var is_draggable: bool = true
@export var is_playable: bool = true

var is_hovering: bool = false
var is_dragging: bool = false
var drag_offset: Vector2
var original_position: Vector2
var original_scale: Vector2

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	original_scale = scale
	
	if card_data.has("name"):
		update_card_display()

func update_card_display():
	if has_node("CardContainer/NameLabel"):
		$CardContainer/NameLabel.text = card_data.get("name", "")
	
	if has_node("CardContainer/CostLabel"):
		$CardContainer/CostLabel.text = str(card_data.get("cost", 0))
	
	if has_node("CardContainer/DescriptionLabel"):
		$CardContainer/DescriptionLabel.text = card_data.get("description", "")
	
	if has_node("CardContainer/CodeSnippet"):
		$CardContainer/CodeSnippet.text = card_data.get("code_snippet", "")

func _on_mouse_entered():
	if not is_dragging:
		is_hovering = true
		card_hovered.emit(self)
		_animate_hover()

func _on_mouse_exited():
	if not is_dragging:
		is_hovering = false
		_animate_unhover()

func _on_gui_input(event):
	if not is_draggable or not is_playable:
		return
		
	if event is InputEventScreenTouch:
		if event.pressed:
			_start_drag(event.position)
		else:
			_end_drag()
	
	elif event is InputEventScreenDrag:
		if is_dragging:
			_update_drag(event.position)

func _start_drag(touch_position: Vector2):
	is_dragging = true
	drag_offset = global_position - touch_position
	original_position = position
	card_drag_started.emit(self)
	
	# Visual feedback
	z_index = 10
	scale = original_scale * 1.1
	modulate.a = 0.8

func _update_drag(touch_position: Vector2):
	global_position = touch_position + drag_offset

func _end_drag():
	is_dragging = false
	card_drag_ended.emit(self)
	
	# Check if card was dropped in valid zone
	var play_zone = get_tree().get_first_node_in_group("play_zone")
	if play_zone and play_zone.get_global_rect().has_point(global_position):
		card_used.emit(self)
	else:
		# Return to original position
		var tween = create_tween()
		tween.tween_property(self, "position", original_position, 0.3)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Reset visual state
	z_index = 0
	scale = original_scale
	modulate.a = 1.0

func _animate_hover():
	var tween = create_tween()
	tween.tween_property(self, "scale", original_scale * 1.05, 0.1)
	tween.parallel().tween_property(self, "position:y", position.y - 10, 0.1)

func _animate_unhover():
	var tween = create_tween()
	tween.tween_property(self, "scale", original_scale, 0.1)
	tween.parallel().tween_property(self, "position:y", position.y + 10, 0.1)

func set_playable(playable: bool):
	is_playable = playable
	modulate = Color.WHITE if playable else Color(0.6, 0.6, 0.6, 1.0)
	
func get_card_type() -> String:
	return card_data.get("type", "action")

func get_card_cost() -> int:
	return card_data.get("cost", 0)

func execute_effect(target = null):
	# This will be overridden by specific card types
	print("Executing card effect: ", card_data.get("name", ""))
	if card_data.has("effect_function"):
		# Call the JavaScript bridge here for DOM manipulation
		pass