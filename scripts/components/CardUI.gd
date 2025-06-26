extends Panel

signal card_played(card_data: Dictionary)
signal card_selected(card_data: Dictionary)

var card_data = {}
var is_dragging = false
var drag_offset = Vector2.ZERO
var original_position = Vector2.ZERO
var original_parent = null
var can_play = true
var is_hovered = false
var touch_feedback_tween: Tween
var touch_start_pos = Vector2.ZERO
var is_potential_drag = false

@onready var name_label = $VBoxContainer/NameLabel
@onready var cost_label = $VBoxContainer/CostLabel
@onready var type_label = $VBoxContainer/TypeLabel
@onready var description_label = $VBoxContainer/DescriptionLabel

func _ready():
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Mobile optimization
	TouchHelper.ensure_min_touch_size(self)

func setup_card(data: Dictionary, energy: int = 999):
	card_data = data
	
	# Generate JavaScript code if not present
	if not data.has("code"):
		data.code = _generate_javascript_code(data)
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
	
	# Handle touch input (mobile)
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start_pos = event.position
			is_potential_drag = true
			_start_drag(event.position)
		else:
			if is_potential_drag and not is_dragging:
				# This was a tap, not a drag
				emit_signal("card_selected", card_data)
			_end_drag()
			is_potential_drag = false
	
	elif event is InputEventScreenDrag and is_potential_drag:
		# Check if this should become a drag gesture
		if not is_dragging and TouchHelper.is_drag_gesture(touch_start_pos, event.position):
			is_dragging = true
		
		if is_dragging:
			_update_drag(event.position + global_position)
	
	# Handle mouse input (desktop fallback)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				touch_start_pos = event.position
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
	
	# Enhanced visual feedback for touch
	_create_touch_feedback()
	
	# Move to top layer
	var viewport = get_viewport()
	if viewport:
		original_parent.remove_child(self)
		viewport.add_child(self)
		global_position = original_position
	
	# Enhanced visual feedback with smooth scaling
	if touch_feedback_tween:
		touch_feedback_tween.kill()
	touch_feedback_tween = create_tween()
	touch_feedback_tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.2)
	touch_feedback_tween.parallel().tween_property(self, "modulate", Color(1.2, 1.2, 1.2, 1.0), 0.2)
	z_index = 100
	
	# Add haptic feedback for mobile
	TouchHelper.provide_haptic_feedback(50)

func _update_drag(global_pos: Vector2):
	if is_dragging:
		global_position = global_pos - drag_offset

func _end_drag():
	if not is_dragging:
		return
		
	is_dragging = false
	z_index = 0
	
	# Smooth return animation
	if touch_feedback_tween:
		touch_feedback_tween.kill()
	touch_feedback_tween = create_tween()
	touch_feedback_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
	touch_feedback_tween.parallel().tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
	
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

func _on_mouse_entered():
	if not is_dragging and can_play:
		is_hovered = true
		if touch_feedback_tween:
			touch_feedback_tween.kill()
		touch_feedback_tween = create_tween()
		touch_feedback_tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.15)
		touch_feedback_tween.parallel().tween_property(self, "modulate", Color(1.1, 1.1, 1.1, 1.0), 0.15)

func _on_mouse_exited():
	if not is_dragging and is_hovered:
		is_hovered = false
		if touch_feedback_tween:
			touch_feedback_tween.kill()
		touch_feedback_tween = create_tween()
		touch_feedback_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)
		touch_feedback_tween.parallel().tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.15)

func _create_touch_feedback():
	# Create visual feedback for touch interactions
	# This could include particle effects, glow, etc.
	pass

func _generate_javascript_code(data: Dictionary) -> String:
	# Generate JavaScript-like code based on card properties
	var code = ""
	var card_name = data.get("name", "").to_lower()
	var description = data.get("description", "").to_lower()
	var card_type = data.get("type", "ACTION")
	var cost = data.get("cost", 1)
	
	# Parse description for damage/heal/shield values
	var damage_regex = RegEx.new()
	damage_regex.compile("(\\d+)\\s*damage")
	var damage_match = damage_regex.search(description)
	
	var heal_regex = RegEx.new()
	heal_regex.compile("(\\d+)\\s*(heal|health|hp)")
	var heal_match = heal_regex.search(description)
	
	var shield_regex = RegEx.new()
	shield_regex.compile("(\\d+)\\s*(shield|block|armor)")
	var shield_match = shield_regex.search(description)
	
	# Generate code based on card effects
	if damage_match:
		var damage_amount = damage_match.get_string(1).to_int()
		code += "// Deal damage to enemy\n"
		code += "enemy.takeDamage(" + str(damage_amount) + ");\n"
		code += "console.log('Dealt " + str(damage_amount) + " damage!');"
	elif heal_match:
		var heal_amount = heal_match.get_string(1).to_int()
		code += "// Heal player\n"
		code += "player.heal(" + str(heal_amount) + ");\n"
		code += "console.log('Healed " + str(heal_amount) + " HP!');"
	elif shield_match:
		var shield_amount = shield_match.get_string(1).to_int()
		code += "// Gain shield\n"
		code += "player.gainShield(" + str(shield_amount) + ");\n"
		code += "console.log('Gained " + str(shield_amount) + " shield!');"
	else:
		# Generate code based on card name/type
		if "slash" in card_name or "attack" in card_name:
			code += "// Attack enemy\n"
			code += "enemy.takeDamage(8);\n"
			code += "console.log('Executed attack command!');"
		elif "debug" in card_name or "bug" in card_name:
			code += "// Debug system\n"
			code += "system.debug();\n"
			code += "console.log('Debugging enemy vulnerabilities...');"
		elif "hack" in card_name or "exploit" in card_name:
			code += "// Exploit enemy system\n"
			code += "enemy.exploit();\n"
			code += "console.log('Enemy system compromised!');"
		elif "firewall" in card_name or "shield" in card_name:
			code += "// Activate defensive systems\n"
			code += "player.activateFirewall();\n"
			code += "console.log('Firewall protocols active!');"
		elif "virus" in card_name or "malware" in card_name:
			code += "// Deploy virus\n"
			code += "enemy.infect(virus);\n"
			code += "console.log('Virus deployed successfully!');"
		else:
			# Default effect based on type
			match card_type:
				"ACTION":
					code += "// Execute action\n"
					code += "executeAction('" + data.get("name", "Unknown") + "');\n"
					code += "console.log('Action executed!');"
				"EVENT":
					code += "// Trigger event\n"
					code += "triggerEvent('" + data.get("name", "Unknown") + "');\n"
					code += "console.log('Event triggered!');"
				"POWER":
					code += "// Activate power\n"
					code += "activatePower('" + data.get("name", "Unknown") + "');\n"
					code += "console.log('Power activated!');"
	
	return code

func get_card_code() -> String:
	return card_data.get("code", "")