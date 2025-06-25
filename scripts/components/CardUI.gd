extends Panel

signal card_played(card_data: Dictionary)
signal card_selected(card_data: Dictionary)

var card_data = {}
var is_dragging = false
var drag_offset = Vector2.ZERO
var original_position = Vector2.ZERO
var original_parent = null
var can_play = true

@onready var name_label = $VBoxContainer/NameLabel
@onready var cost_label = $VBoxContainer/CostLabel
@onready var type_label = $VBoxContainer/TypeLabel
@onready var description_label = $VBoxContainer/DescriptionLabel

func _ready():
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup_card(data: Dictionary, energy: int = 999):
	card_data = data
	
	# Update labels
	name_label.text = data.get("name", "Unknown")
	cost_label.text = "Cost: " + str(data.get("cost", 0))
	type_label.text = data.get("type", "ACTION")
	description_label.text = data.get("description", "")
	
	# Update visual based on type
	var base_color = Color.CYAN
	match data.get("type", ""):
		"ACTION":
			base_color = Color(1, 0.5, 0.5)
		"EVENT":
			base_color = Color(0.5, 1, 0.5)
		"POWER":
			base_color = Color(0.5, 0.5, 1)
	
	# Apply color tint
	name_label.modulate = base_color
	var style = get_theme_stylebox("panel").duplicate()
	style.border_color = base_color
	add_theme_stylebox_override("panel", style)
	
	# Check if can play
	can_play = data.get("cost", 0) <= energy
	if not can_play:
		modulate.a = 0.5

func _on_gui_input(event: InputEvent):
	if not can_play:
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drag(event.position)
			else:
				_end_drag()
	
	elif event is InputEventMouseMotion and is_dragging:
		_update_drag(event.global_position)

func _start_drag(local_pos: Vector2):
	is_dragging = true
	drag_offset = local_pos
	original_position = global_position
	original_parent = get_parent()
	
	# Move to top layer
	var viewport = get_viewport()
	if viewport:
		original_parent.remove_child(self)
		viewport.add_child(self)
		global_position = original_position
	
	# Visual feedback
	scale = Vector2(1.1, 1.1)
	z_index = 100

func _update_drag(global_pos: Vector2):
	if is_dragging:
		global_position = global_pos - drag_offset

func _end_drag():
	if not is_dragging:
		return
		
	is_dragging = false
	scale = Vector2(1.0, 1.0)
	z_index = 0
	
	# Check if dropped in valid area
	var play_area = _get_play_area()
	if play_area and play_area.get_global_rect().has_point(global_position + size / 2):
		emit_signal("card_played", card_data)
		queue_free()
	else:
		# Return to original position
		_return_to_hand()

func _return_to_hand():
	var viewport = get_viewport()
	if viewport and original_parent:
		viewport.remove_child(self)
		original_parent.add_child(self)
		position = original_position - original_parent.global_position

func _get_play_area():
	# Find the drop area in the scene
	var root = get_tree().root
	var drop_area = root.find_child("CardDropArea", true, false)
	return drop_area

func _on_mouse_entered():
	if not is_dragging and can_play:
		var animation_manager = _get_animation_manager()
		if animation_manager:
			animation_manager.card_hover_effect(self, true)
		else:
			scale = Vector2(1.05, 1.05)
			z_index = 10

func _on_mouse_exited():
	if not is_dragging:
		var animation_manager = _get_animation_manager()
		if animation_manager:
			animation_manager.card_hover_effect(self, false)
		else:
			scale = Vector2(1.0, 1.0)
			z_index = 0

func _get_animation_manager():
	var battle_scene = get_tree().root.find_child("BattleScene", true, false)
	if battle_scene and battle_scene.has_method("get_node"):
		return battle_scene.animation_manager
	return null