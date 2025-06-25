extends Node

# Singleton for managing game animations and effects
signal animation_completed(animation_name: String)

var tween: Tween

func _ready():
	print("AnimationManager initialized")

# Card play animation
func animate_card_play(card_node: Node, target_position: Vector2):
	if not card_node:
		return
	
	var original_pos = card_node.global_position
	var original_scale = card_node.scale
	
	# Create tween if not exists
	if not tween or not tween.is_valid():
		tween = create_tween()
		tween.set_parallel(true)
	
	# Animate to target
	tween.tween_property(card_node, "global_position", target_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(card_node, "scale", Vector2(1.2, 1.2), 0.3).set_ease(Tween.EASE_OUT)
	
	# Fade out
	await tween.tween_property(card_node, "modulate:a", 0.0, 0.2).finished
	
	# Clean up
	card_node.queue_free()
	emit_signal("animation_completed", "card_play")

# Damage number animation
func show_damage_number(target_node: Node, damage: int, is_healing: bool = false):
	if not target_node:
		return
	
	var damage_label = Label.new()
	damage_label.text = str(damage) if damage > 0 else "MISS"
	damage_label.modulate = Color.RED if not is_healing else Color.GREEN
	damage_label.add_theme_font_size_override("font_size", 24)
	damage_label.z_index = 100
	
	# Position above target
	target_node.add_child(damage_label)
	damage_label.position = Vector2(-20, -50)
	
	# Create tween if not exists
	if not tween or not tween.is_valid():
		tween = create_tween()
		tween.set_parallel(true)
	
	# Animate upward and fade
	tween.tween_property(damage_label, "position:y", damage_label.position.y - 100, 1.0).set_ease(Tween.EASE_OUT)
	await tween.tween_property(damage_label, "modulate:a", 0.0, 1.0).finished
	
	damage_label.queue_free()

# Screen shake effect
func screen_shake(intensity: float = 10.0, duration: float = 0.3):
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	
	var original_offset = camera.offset
	
	if not tween or not tween.is_valid():
		tween = create_tween()
	
	for i in range(int(duration * 30)): # 30 FPS shake
		var shake_offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(camera, "offset", original_offset + shake_offset, 0.033)
		await tween.finished
		
		if not tween or not tween.is_valid():
			tween = create_tween()
	
	# Return to original position
	tween.tween_property(camera, "offset", original_offset, 0.1)

# Glow effect for UI elements
func add_glow_effect(node: Control, color: Color = Color.CYAN, intensity: float = 2.0):
	if not node:
		return
	
	# Create glow shader material (simplified)
	var material = CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	node.material = material
	
	# Animate glow intensity
	if not tween or not tween.is_valid():
		tween = create_tween()
		tween.set_loops()
	
	tween.tween_property(node, "modulate", color * intensity, 1.0)
	tween.tween_property(node, "modulate", Color.WHITE, 1.0)

# Cyber glitch effect
func cyber_glitch_effect(node: Control, duration: float = 0.5):
	if not node:
		return
	
	var original_position = node.position
	var original_modulate = node.modulate
	
	if not tween or not tween.is_valid():
		tween = create_tween()
		tween.set_parallel(true)
	
	# Random position offsets
	for i in range(10):
		var glitch_offset = Vector2(
			randf_range(-5, 5),
			randf_range(-2, 2)
		)
		tween.tween_property(node, "position", original_position + glitch_offset, 0.05)
		await tween.finished
		
		if not tween or not tween.is_valid():
			tween = create_tween()
			tween.set_parallel(true)
	
	# Return to normal
	tween.tween_property(node, "position", original_position, 0.1)
	tween.tween_property(node, "modulate", original_modulate, 0.1)

# Typing effect for text
func typewriter_effect(label: Label, text: String, speed: float = 0.05):
	if not label:
		return
	
	label.text = ""
	
	for i in range(text.length()):
		label.text += text[i]
		await get_tree().create_timer(speed).timeout
	
	emit_signal("animation_completed", "typewriter")

# Pulse animation for important elements
func pulse_animation(node: Control, scale_factor: float = 1.1, duration: float = 0.5):
	if not node:
		return
	
	var original_scale = node.scale
	
	if not tween or not tween.is_valid():
		tween = create_tween()
		tween.set_loops()
	
	tween.tween_property(node, "scale", original_scale * scale_factor, duration / 2)
	tween.tween_property(node, "scale", original_scale, duration / 2)

# Card hover effect
func card_hover_effect(card_node: Control, hover_in: bool):
	if not card_node:
		return
	
	if not tween or not tween.is_valid():
		tween = create_tween()
		tween.set_parallel(true)
	
	if hover_in:
		tween.tween_property(card_node, "scale", Vector2(1.05, 1.05), 0.2)
		tween.tween_property(card_node, "z_index", 10, 0.1)
		add_glow_effect(card_node, Color.CYAN, 1.5)
	else:
		tween.tween_property(card_node, "scale", Vector2(1.0, 1.0), 0.2)
		tween.tween_property(card_node, "z_index", 0, 0.1)
		card_node.material = null

# Victory/Defeat animations
func show_victory_screen(container: Control):
	var victory_label = Label.new()
	victory_label.text = "VICTORY ACHIEVED"
	victory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	victory_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	victory_label.add_theme_font_size_override("font_size", 36)
	victory_label.modulate = Color(0, 1, 1, 0)
	victory_label.size = container.size
	
	container.add_child(victory_label)
	
	if not tween or not tween.is_valid():
		tween = create_tween()
		tween.set_parallel(true)
	
	# Fade in with scale effect
	tween.tween_property(victory_label, "modulate:a", 1.0, 1.0)
	tween.tween_property(victory_label, "scale", Vector2(1.2, 1.2), 0.5)
	tween.tween_property(victory_label, "scale", Vector2(1.0, 1.0), 0.5).set_delay(0.5)
	
	# Add celebratory particle effect
	_create_particle_burst(container, Color.GOLD, 20)

func show_defeat_screen(container: Control):
	var defeat_label = Label.new()
	defeat_label.text = "SYSTEM COMPROMISED"
	defeat_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	defeat_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	defeat_label.add_theme_font_size_override("font_size", 36)
	defeat_label.modulate = Color(1, 0, 0, 0)
	defeat_label.size = container.size
	
	container.add_child(defeat_label)
	
	if not tween or not tween.is_valid():
		tween = create_tween()
		tween.set_parallel(true)
	
	# Fade in with glitch effect
	tween.tween_property(defeat_label, "modulate:a", 1.0, 1.0)
	cyber_glitch_effect(defeat_label, 2.0)

# Particle burst effect
func _create_particle_burst(container: Control, color: Color, count: int):
	for i in range(count):
		var particle = ColorRect.new()
		particle.color = color
		particle.size = Vector2(4, 4)
		particle.position = container.size / 2
		
		container.add_child(particle)
		
		if not tween or not tween.is_valid():
			tween = create_tween()
			tween.set_parallel(true)
		
		# Random direction and distance
		var angle = randf() * TAU
		var distance = randf_range(50, 200)
		var target_pos = particle.position + Vector2(cos(angle), sin(angle)) * distance
		
		# Animate particle
		tween.tween_property(particle, "position", target_pos, 1.0)
		tween.tween_property(particle, "modulate:a", 0.0, 1.0)
		tween.tween_callback(particle.queue_free).set_delay(1.0)

# Sound effect integration
func play_sound_effect(sound_name: String):
	var sound_manager = _get_sound_manager()
	if sound_manager:
		var cyberpunk_sound = sound_manager.get_cyberpunk_sound(sound_name)
		sound_manager.play_sfx(cyberpunk_sound)
	else:
		print("Playing sound effect: ", sound_name)
	emit_signal("animation_completed", "sound_" + sound_name)

func _get_sound_manager():
	# Try to find SoundManager in the scene tree
	var root = get_tree().root
	return root.find_child("SoundManager", true, false)

# Matrix rain effect for background
func matrix_rain_effect(container: Control):
	var chars = ["0", "1", "デ", "ジ", "タ", "ル", "サ", "イ", "バ", "ー"]
	
	for i in range(20):
		var label = Label.new()
		label.text = chars[randi() % chars.size()]
		label.modulate = Color(0, 1, 0, 0.7)
		label.position.x = randf() * container.size.x
		label.position.y = -20
		
		container.add_child(label)
		
		if not tween or not tween.is_valid():
			tween = create_tween()
			tween.set_parallel(true)
		
		# Fall down
		var fall_duration = randf_range(2.0, 5.0)
		tween.tween_property(label, "position:y", container.size.y + 50, fall_duration)
		tween.tween_property(label, "modulate:a", 0.0, fall_duration)
		
		# Clean up after animation
		tween.tween_callback(label.queue_free).set_delay(fall_duration)

func stop_all_animations():
	if tween and tween.is_valid():
		tween.kill()
		tween = null