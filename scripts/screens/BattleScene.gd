extends Control

signal battle_ended(victory: bool)
signal return_to_menu()

var api_client
var game_session = null
var current_game_id = -1
var animation_manager

# Battle state
var player_state = {}
var enemy_state = {}
var hand_cards = []
var current_energy = 3
var max_energy = 3
var turn_number = 1
var is_player_turn = true
var selected_card = null
var dragging_card = null

# UI References
@onready var floor_label = $TopPanel/HBoxContainer/FloorLabel
@onready var turn_label = $TopPanel/HBoxContainer/TurnLabel
@onready var energy_label = $TopPanel/HBoxContainer/EnergyLabel
@onready var end_turn_button = $TopPanel/HBoxContainer/EndTurnButton

# Enemy UI
@onready var enemy_name_label = $BattleField/EnemyArea/EnemyPanel/VBoxContainer/EnemyNameLabel
@onready var enemy_health_bar = $BattleField/EnemyArea/EnemyPanel/VBoxContainer/EnemyHealthBar
@onready var enemy_health_label = $BattleField/EnemyArea/EnemyPanel/VBoxContainer/EnemyHealthLabel
@onready var enemy_shield_label = $BattleField/EnemyArea/EnemyPanel/VBoxContainer/EnemyShieldLabel
@onready var intent_label = $BattleField/EnemyArea/EnemyPanel/VBoxContainer/IntentLabel
@onready var enemy_buffs_container = $BattleField/EnemyArea/EnemyPanel/VBoxContainer/BuffsContainer

# Player UI
@onready var player_name_label = $BattleField/PlayerArea/PlayerPanel/VBoxContainer/PlayerNameLabel
@onready var player_health_bar = $BattleField/PlayerArea/PlayerPanel/VBoxContainer/PlayerHealthBar
@onready var player_health_label = $BattleField/PlayerArea/PlayerPanel/VBoxContainer/PlayerHealthLabel
@onready var player_shield_label = $BattleField/PlayerArea/PlayerPanel/VBoxContainer/PlayerShieldLabel
@onready var player_buffs_container = $BattleField/PlayerArea/PlayerPanel/VBoxContainer/BuffsContainer

# Hand UI
@onready var card_container = $HandArea/Panel/VBoxContainer/CardContainer
@onready var draw_pile_label = $HandArea/Panel/VBoxContainer/DeckInfo/DrawPileLabel
@onready var discard_pile_label = $HandArea/Panel/VBoxContainer/DeckInfo/DiscardPileLabel
@onready var exhaust_pile_label = $HandArea/Panel/VBoxContainer/DeckInfo/ExhaustPileLabel

# Drop area
@onready var drop_indicator = $CardDropArea/DropIndicator
@onready var drop_label = $CardDropArea/DropLabel

func _ready():
	print("BattleScene ready")
	_setup_api_client()
	_setup_drop_area()
	_setup_animations()
	_apply_cyberpunk_theme()

func _setup_api_client():
	api_client = preload("res://scripts/network/APIClient.gd").new()
	api_client.name = "APIClient"
	add_child(api_client)
	
	if api_client.has_signal("request_completed"):
		api_client.request_completed.connect(_on_api_request_completed)
	if api_client.has_signal("request_failed"):
		api_client.request_failed.connect(_on_api_request_failed)

func _setup_drop_area():
	# Set up card drop detection
	set_process_input(true)
	# Make drop area always visible during player turn
	drop_indicator.visible = true
	drop_label.visible = true

func _setup_animations():
	# Load animation manager
	animation_manager = preload("res://scripts/effects/AnimationManager.gd").new()
	animation_manager.name = "AnimationManager"
	add_child(animation_manager)
	animation_manager.animation_completed.connect(_on_animation_completed)
	
	# Load sound manager
	var sound_manager = preload("res://scripts/audio/SoundManager.gd").new()
	sound_manager.name = "SoundManager"
	add_child(sound_manager)
	
	# Load JavaScript bridge for vibe coding
	var js_bridge = preload("res://scripts/bridge/JavaScriptBridge.gd").new()
	js_bridge.name = "JavaScriptBridge"
	add_child(js_bridge)
	js_bridge.code_executed.connect(_on_code_executed)
	js_bridge.dom_updated.connect(_on_dom_updated)
	
	# Load code viewer for debugging
	var code_viewer = preload("res://scripts/screens/CodeViewer.gd").new()
	code_viewer.name = "CodeViewer"
	add_child(code_viewer)
	code_viewer.code_executed.connect(_on_manual_code_executed)

func _apply_cyberpunk_theme():
	# Apply glowing effects to important UI elements
	if animation_manager:
		animation_manager.add_glow_effect(energy_label, Color.GREEN)
		animation_manager.pulse_animation(end_turn_button, 1.05, 1.0)
		
		# Add matrix rain effect to background
		animation_manager.matrix_rain_effect(self)

func _on_animation_completed(animation_name: String):
	print("Animation completed: ", animation_name)

func start_battle(game_id: int = -1, deck_id: int = -1):
	print("Starting battle...")
	
	if game_id > 0:
		# Resume existing game
		current_game_id = game_id
		api_client.get_game(game_id)
	else:
		# Start new game
		api_client.start_game("STORY", deck_id)

func _on_api_request_completed(response):
	print("Battle API response: ", response)
	
	if response.has("game_session"):
		_handle_game_session_update(response.game_session)
	elif response.has("action_result"):
		_handle_action_result(response.action_result)
	else:
		print("Unknown response format")

func _on_api_request_failed(error):
	print("Battle API error: ", error)
	# TODO: Show error to player

func _handle_game_session_update(session):
	game_session = session
	current_game_id = session.id
	
	# Update UI
	floor_label.text = "Floor: " + str(session.current_floor)
	turn_label.text = "Turn: " + str(session.turn)
	
	# Update states
	if session.has("player_state"):
		_update_player_state(session.player_state)
	
	if session.has("enemy_state"):
		_update_enemy_state(session.enemy_state)
	
	# Check game status
	if session.status == "COMPLETED":
		_handle_victory()
	elif session.status == "FAILED":
		_handle_defeat()

func _update_player_state(state):
	var old_health = player_state.get("health", state.health)
	player_state = state
	
	# Update health with animation
	player_health_bar.max_value = state.max_health
	
	# Animate health change
	if animation_manager and old_health != state.health:
		var health_diff = old_health - state.health
		if health_diff > 0:
			# Player took damage
			animation_manager.show_damage_number(player_health_bar, health_diff, false)
			animation_manager.screen_shake(8.0, 0.4)
		elif health_diff < 0:
			# Player healed
			animation_manager.show_damage_number(player_health_bar, abs(health_diff), true)
	
	player_health_bar.value = state.health
	player_health_label.text = str(state.health) + "/" + str(state.max_health)
	
	# Update shield
	player_shield_label.text = "Shield: " + str(state.shield)
	
	# Update energy with glow effect
	current_energy = state.energy
	max_energy = state.max_energy
	energy_label.text = "Energy: " + str(current_energy) + "/" + str(max_energy)
	
	# Update hand
	_update_hand(state.hand)
	
	# Update deck info
	draw_pile_label.text = "Draw: " + str(state.draw_pile.size())
	discard_pile_label.text = "Discard: " + str(state.discard_pile.size())
	exhaust_pile_label.text = "Exhaust: " + str(state.exhaust_pile.size())
	
	# Update buffs/debuffs
	_update_status_effects(player_buffs_container, state.buffs, state.debuffs)

func _update_enemy_state(state):
	var old_health = enemy_state.get("health", state.health)
	enemy_state = state
	
	# Update name
	enemy_name_label.text = state.get("name", "Enemy")
	
	# Update health with animation
	enemy_health_bar.max_value = state.max_health
	
	# Animate health change
	if animation_manager and old_health != state.health:
		var health_diff = old_health - state.health
		if health_diff > 0:
			# Enemy took damage
			animation_manager.show_damage_number(enemy_health_bar, health_diff, false)
			animation_manager.cyber_glitch_effect(enemy_name_label)
		elif health_diff < 0:
			# Enemy healed
			animation_manager.show_damage_number(enemy_health_bar, abs(health_diff), true)
	
	enemy_health_bar.value = state.health
	enemy_health_label.text = str(state.health) + "/" + str(state.max_health)
	
	# Update shield
	enemy_shield_label.text = "Shield: " + str(state.shield)
	
	# Update intent with glow effect
	_update_enemy_intent(state.intent)
	if animation_manager:
		animation_manager.add_glow_effect(intent_label, Color.RED, 1.2)
	
	# Update buffs/debuffs
	_update_status_effects(enemy_buffs_container, state.buffs, state.debuffs)

func _update_enemy_intent(intent):
	if intent == null:
		intent_label.text = "Intent: Unknown"
		return
	
	var intent_text = "Intent: "
	match intent.type:
		"ATTACK":
			intent_text += "Attack " + str(intent.value)
		"DEFEND":
			intent_text += "Defend " + str(intent.value)
		"BUFF":
			intent_text += "Buff"
		"DEBUFF":
			intent_text += "Debuff"
		_:
			intent_text += "Unknown"
	
	intent_label.text = intent_text

func _update_status_effects(container: Node, buffs: Array, debuffs: Array):
	# Clear existing
	for child in container.get_children():
		child.queue_free()
	
	# Add buffs
	for buff in buffs:
		var label = Label.new()
		label.text = buff.type + ":" + str(buff.value)
		label.modulate = Color.GREEN
		container.add_child(label)
	
	# Add debuffs
	for debuff in debuffs:
		var label = Label.new()
		label.text = debuff.type + ":" + str(debuff.value)
		label.modulate = Color.RED
		container.add_child(label)

func _update_hand(cards: Array):
	hand_cards = cards
	
	# Clear existing cards
	for child in card_container.get_children():
		child.queue_free()
	
	# Create card UI elements
	for card in cards:
		_create_card_ui(card)

func _create_card_ui(card: Dictionary):
	# Use the CardUI component
	var card_scene = preload("res://scenes/components/CardUI.tscn")
	var card_ui = card_scene.instantiate()
	
	# Setup card with current energy
	card_ui.setup_card(card, current_energy)
	
	# Connect signals
	card_ui.card_played.connect(_on_card_played)
	card_ui.card_selected.connect(_on_card_selected)
	
	card_container.add_child(card_ui)

func _on_card_selected(card: Dictionary):
	if not is_player_turn:
		return
	
	selected_card = card
	print("Selected card: ", card.name)

func _on_card_played(card: Dictionary):
	if not is_player_turn:
		return
	
	_play_card(card)

func _play_card(card: Dictionary):
	if card.cost > current_energy:
		print("Not enough energy!")
		if animation_manager:
			animation_manager.cyber_glitch_effect(energy_label)
			animation_manager.play_sound_effect("error")
		return
	
	print("Playing card: ", card.name)
	
	# Execute JavaScript code for vibe coding experience
	var js_bridge = get_node_or_null("JavaScriptBridge")
	if js_bridge:
		js_bridge.execute_card_code(card)
	
	# Screen shake for impact
	if animation_manager:
		animation_manager.screen_shake(5.0, 0.2)
		animation_manager.play_sound_effect("card_play")
	
	# Check if card needs target
	var target_id = -1
	if _card_needs_target(card):
		# For now, always target first enemy
		# TODO: Implement target selection
		target_id = 0
	
	# Send play action to server
	api_client.play_action(current_game_id, "PLAY_CARD", card.id, target_id)

func _card_needs_target(card: Dictionary) -> bool:
	# Check if card description mentions targeting
	return "target" in card.description.to_lower() or card.type == "ACTION"

func _on_end_turn_pressed():
	if not is_player_turn:
		return
	
	print("Ending turn...")
	is_player_turn = false
	end_turn_button.disabled = true
	
	# Add turn transition effect
	if animation_manager:
		animation_manager.play_sound_effect("turn_end")
		# Add fade effect to signal turn change
		var fade_overlay = ColorRect.new()
		fade_overlay.color = Color(0, 0, 0, 0)
		fade_overlay.size = get_viewport().size
		add_child(fade_overlay)
		
		var tween = create_tween()
		tween.tween_property(fade_overlay, "color:a", 0.3, 0.5)
		tween.tween_property(fade_overlay, "color:a", 0.0, 0.5)
		tween.tween_callback(fade_overlay.queue_free)
	
	# Send end turn action
	api_client.end_turn(current_game_id)

func _handle_action_result(result):
	print("Action result: ", result)
	
	# Update game state based on result
	if result.has("game_session"):
		_handle_game_session_update(result.game_session)
	
	# Check turn phase
	if result.has("turn_phase"):
		if result.turn_phase == "ENEMY":
			is_player_turn = false
			# Enemy turn will be handled by server
		else:
			is_player_turn = true
			end_turn_button.disabled = false

func _handle_victory():
	print("Victory!")
	if animation_manager:
		animation_manager.show_victory_screen(self)
		animation_manager.play_sound_effect("victory")
	emit_signal("battle_ended", true)

func _handle_defeat():
	print("Defeat!")
	if animation_manager:
		animation_manager.show_defeat_screen(self)
		animation_manager.play_sound_effect("defeat")
	emit_signal("battle_ended", false)

func _on_code_executed(result: String):
	print("JavaScript code executed: ", result)
	# Handle vibe coding results and sync with game state

func _on_dom_updated(element_id: String, property: String, value: Variant):
	print("DOM updated: ", element_id, ".", property, " = ", value)
	# Sync DOM changes with actual game UI
	match element_id:
		"player-health":
			if property == "value":
				player_health_bar.value = value
				player_health_label.text = str(value) + "/" + str(player_state.get("max_health", 100))
		"enemy-health":
			if property == "value":
				enemy_health_bar.value = value
				enemy_health_label.text = str(value) + "/" + str(enemy_state.get("max_health", 50))
		"player-shield":
			if property == "value":
				player_shield_label.text = "Shield: " + str(value)
		"enemy-shield":
			if property == "value":
				enemy_shield_label.text = "Shield: " + str(value)
		"energy-display":
			if property == "value":
				current_energy = value
				energy_label.text = "Energy: " + str(current_energy) + "/" + str(max_energy)

func _on_manual_code_executed(code: String):
	print("Manual code execution: ", code)
	var js_bridge = get_node_or_null("JavaScriptBridge")
	if js_bridge:
		js_bridge.execute_raw_code(code)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		# TODO: Show pause menu
		pass
	elif event.is_action_pressed("ui_accept"):
		# Show/hide JavaScript console for debugging
		var console = get_node_or_null("JavaScriptBridge/ConsolePanel")
		if console:
			console.toggle_visibility()
	elif event.is_action_pressed("ui_select"):
		# Show code viewer for selected card
		if selected_card:
			var code_viewer = get_node_or_null("CodeViewer")
			if code_viewer:
				code_viewer.show_card_code(selected_card)