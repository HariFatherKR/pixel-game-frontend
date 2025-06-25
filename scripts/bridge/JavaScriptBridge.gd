extends Node

# JavaScript Bridge for Vibe Coding functionality
# Enables card effects to execute JavaScript-like code and manipulate DOM elements

signal code_executed(result: String)
signal console_log(message: String)
signal dom_updated(element_id: String, property: String, value: Variant)

var console_panel = null
var javascript_interface = null
var sandbox_enabled = true
var execution_history = []

# DOM element references (simulated)
var dom_elements = {}
var css_classes = {}

func _ready():
	print("JavaScriptBridge initialized")
	_setup_console_panel()
	_setup_dom_simulation()
	_register_default_functions()

func _setup_console_panel():
	# Create a console panel for displaying JavaScript-like logs
	console_panel = preload("res://scripts/ui/ConsolePanel.gd").new()
	console_panel.name = "ConsolePanel"
	add_child(console_panel)
	
	# Connect console logging
	console_log.connect(_on_console_log)

func _setup_dom_simulation():
	# Initialize simulated DOM elements that cards can manipulate
	dom_elements = {
		"player": {
			"health": 100,
			"maxHealth": 100,
			"energy": 3,
			"shield": 0,
			"className": "player-character"
		},
		"enemy": {
			"health": 50,
			"maxHealth": 50,
			"shield": 0,
			"intent": "attack",
			"className": "enemy-character"
		},
		"battlefield": {
			"effects": [],
			"className": "battle-area"
		},
		"ui": {
			"health-bar": {"value": 100, "max": 100},
			"energy-display": {"value": 3},
			"console": {"logs": []}
		}
	}

func _register_default_functions():
	# Register common JavaScript-like functions for cards to use
	pass

# Execute card code in vibe coding style
func execute_card_code(card_data: Dictionary) -> Dictionary:
	var result = {"success": false, "message": "", "effects": []}
	
	if not card_data.has("code"):
		result.message = "No code found in card"
		return result
	
	var code = card_data.get("code", "")
	var card_name = card_data.get("name", "Unknown Card")
	
	log_console("🎴 Executing card: " + card_name)
	log_console("📝 Code: " + code)
	
	# Parse and execute the card's JavaScript-like code
	var execution_result = _parse_and_execute(code, card_data)
	
	# Log execution result
	if execution_result.success:
		log_console("✅ Execution completed successfully")
		result.success = true
		result.effects = execution_result.effects
	else:
		log_console("❌ Execution failed: " + execution_result.error)
		result.message = execution_result.error
	
	# Add to execution history
	execution_history.append({
		"timestamp": Time.get_unix_time_from_system(),
		"card": card_name,
		"code": code,
		"result": execution_result
	})
	
	emit_signal("code_executed", JSON.stringify(result))
	return result

func _parse_and_execute(code: String, card_data: Dictionary) -> Dictionary:
	var result = {"success": false, "error": "", "effects": []}
	
	try:
		# Parse different types of card effects
		if "damage" in code.to_lower():
			result = _execute_damage_effect(code, card_data)
		elif "heal" in code.to_lower():
			result = _execute_heal_effect(code, card_data)
		elif "shield" in code.to_lower() or "block" in code.to_lower():
			result = _execute_shield_effect(code, card_data)
		elif "buff" in code.to_lower() or "debuff" in code.to_lower():
			result = _execute_status_effect(code, card_data)
		elif "energy" in code.to_lower():
			result = _execute_energy_effect(code, card_data)
		else:
			result = _execute_custom_effect(code, card_data)
		
		result.success = true
		
	except:
		result.error = "Code execution failed"
		log_console("💥 Runtime error in card code")
	
	return result

func _execute_damage_effect(code: String, card_data: Dictionary) -> Dictionary:
	var effects = []
	var damage_amount = _extract_number_from_code(code, 8) # Default 8 damage
	
	# Simulate dealing damage to enemy
	var enemy = dom_elements.get("enemy", {})
	var current_health = enemy.get("health", 50)
	var shield = enemy.get("shield", 0)
	
	# Apply shield logic
	var actual_damage = damage_amount
	if shield > 0:
		var shield_absorbed = min(shield, damage_amount)
		actual_damage = damage_amount - shield_absorbed
		enemy.shield = max(0, shield - shield_absorbed)
		log_console("🛡️ Shield absorbed " + str(shield_absorbed) + " damage")
	
	# Apply remaining damage
	enemy.health = max(0, current_health - actual_damage)
	dom_elements.enemy = enemy
	
	log_console("⚔️ Dealt " + str(actual_damage) + " damage to enemy")
	log_console("💖 Enemy health: " + str(enemy.health) + "/" + str(enemy.maxHealth))
	
	effects.append({
		"type": "damage",
		"target": "enemy",
		"amount": actual_damage,
		"remaining_health": enemy.health
	})
	
	# Check if enemy is defeated
	if enemy.health <= 0:
		log_console("💀 Enemy defeated!")
		effects.append({"type": "enemy_defeated"})
	
	# Update UI
	_update_dom_element("enemy-health", "value", enemy.health)
	_update_dom_element("enemy-shield", "value", enemy.shield)
	
	return {"success": true, "effects": effects}

func _execute_heal_effect(code: String, card_data: Dictionary) -> Dictionary:
	var effects = []
	var heal_amount = _extract_number_from_code(code, 5) # Default 5 heal
	
	var player = dom_elements.get("player", {})
	var current_health = player.get("health", 100)
	var max_health = player.get("maxHealth", 100)
	
	var actual_heal = min(heal_amount, max_health - current_health)
	player.health = current_health + actual_heal
	dom_elements.player = player
	
	log_console("💚 Healed " + str(actual_heal) + " health")
	log_console("💖 Player health: " + str(player.health) + "/" + str(player.maxHealth))
	
	effects.append({
		"type": "heal",
		"target": "player",
		"amount": actual_heal,
		"remaining_health": player.health
	})
	
	_update_dom_element("player-health", "value", player.health)
	return {"success": true, "effects": effects}

func _execute_shield_effect(code: String, card_data: Dictionary) -> Dictionary:
	var effects = []
	var shield_amount = _extract_number_from_code(code, 3) # Default 3 shield
	
	var player = dom_elements.get("player", {})
	player.shield = player.get("shield", 0) + shield_amount
	dom_elements.player = player
	
	log_console("🛡️ Gained " + str(shield_amount) + " shield")
	log_console("🛡️ Total shield: " + str(player.shield))
	
	effects.append({
		"type": "shield",
		"target": "player",
		"amount": shield_amount,
		"total_shield": player.shield
	})
	
	_update_dom_element("player-shield", "value", player.shield)
	return {"success": true, "effects": effects}

func _execute_status_effect(code: String, card_data: Dictionary) -> Dictionary:
	var effects = []
	var effect_type = "unknown"
	var duration = 2
	
	if "buff" in code.to_lower():
		effect_type = "buff"
		log_console("⬆️ Applied buff effect")
	else:
		effect_type = "debuff"
		log_console("⬇️ Applied debuff effect")
	
	effects.append({
		"type": "status_effect",
		"effect": effect_type,
		"duration": duration
	})
	
	return {"success": true, "effects": effects}

func _execute_energy_effect(code: String, card_data: Dictionary) -> Dictionary:
	var effects = []
	var energy_change = _extract_number_from_code(code, 1)
	
	var player = dom_elements.get("player", {})
	player.energy = max(0, player.get("energy", 3) + energy_change)
	dom_elements.player = player
	
	if energy_change > 0:
		log_console("⚡ Gained " + str(energy_change) + " energy")
	else:
		log_console("⚡ Lost " + str(abs(energy_change)) + " energy")
	
	log_console("⚡ Current energy: " + str(player.energy))
	
	effects.append({
		"type": "energy",
		"change": energy_change,
		"current_energy": player.energy
	})
	
	_update_dom_element("energy-display", "value", player.energy)
	return {"success": true, "effects": effects}

func _execute_custom_effect(code: String, card_data: Dictionary) -> Dictionary:
	var effects = []
	
	# Handle special card effects based on card name or description
	var card_name = card_data.get("name", "").to_lower()
	
	if "debug" in card_name or "bug" in card_name:
		log_console("🐛 Debug mode activated")
		log_console("📊 System diagnostics running...")
		effects.append({"type": "debug", "message": "Debug information revealed"})
	elif "hack" in card_name or "exploit" in card_name:
		log_console("🔓 Exploit found in enemy system")
		log_console("🎯 Vulnerability analysis complete")
		effects.append({"type": "hack", "message": "Enemy system compromised"})
	elif "firewall" in card_name or "security" in card_name:
		log_console("🔥 Firewall activated")
		log_console("🛡️ Security protocols enabled")
		effects.append({"type": "security", "message": "Defense systems online"})
	else:
		log_console("🎮 Custom effect executed")
		effects.append({"type": "custom", "message": "Special effect triggered"})
	
	return {"success": true, "effects": effects}

func _extract_number_from_code(code: String, default_value: int) -> int:
	# Extract numeric values from code strings
	var regex = RegEx.new()
	regex.compile("\\d+")
	var result = regex.search(code)
	
	if result:
		return result.get_string().to_int()
	else:
		return default_value

func _update_dom_element(element_id: String, property: String, value: Variant):
	# Simulate DOM updates
	if not dom_elements.has("ui"):
		dom_elements.ui = {}
	
	if not dom_elements.ui.has(element_id):
		dom_elements.ui[element_id] = {}
	
	dom_elements.ui[element_id][property] = value
	emit_signal("dom_updated", element_id, property, value)

func log_console(message: String):
	print("[JS Bridge] " + message)
	emit_signal("console_log", message)
	
	# Add to DOM console logs
	if dom_elements.has("ui") and dom_elements.ui.has("console"):
		dom_elements.ui.console.logs.append({
			"timestamp": Time.get_unix_time_from_system(),
			"message": message
		})

func _on_console_log(message: String):
	if console_panel:
		console_panel.add_log(message)

# Get current DOM state for debugging
func get_dom_state() -> Dictionary:
	return dom_elements.duplicate(true)

# Reset DOM to initial state
func reset_dom():
	_setup_dom_simulation()
	log_console("🔄 DOM state reset")

# Execute raw JavaScript-like code (for advanced cards)
func execute_raw_code(code: String) -> Dictionary:
	log_console("🔧 Executing raw code: " + code)
	return _parse_and_execute(code, {})

# Get execution history for debugging
func get_execution_history() -> Array:
	return execution_history.duplicate(true)

# Clear execution history
func clear_execution_history():
	execution_history.clear()
	log_console("🗑️ Execution history cleared")