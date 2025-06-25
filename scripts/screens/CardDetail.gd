extends Control

signal back_pressed()

var api_client
var card_id: int = 0
var card_data = {}

@onready var status_label = $VBoxContainer/StatusLabel
@onready var card_container = $VBoxContainer/CardContainer
@onready var title_label = $VBoxContainer/CardContainer/CardContent/TitleLabel
@onready var type_value = $VBoxContainer/CardContainer/CardContent/TypeContainer/TypeValue
@onready var cost_value = $VBoxContainer/CardContainer/CardContent/CostContainer/CostValue
@onready var description_label = $VBoxContainer/CardContainer/CardContent/DescriptionLabel
@onready var effect_label = $VBoxContainer/CardContainer/CardContent/EffectLabel

func _ready():
	print("CardDetail ready")
	_setup_api_client()
	_hide_card_content()

func _setup_api_client():
	api_client = preload("res://scripts/network/APIClient.gd").new()
	api_client.name = "APIClient"
	add_child(api_client)
	
	if api_client.has_signal("request_completed"):
		api_client.request_completed.connect(_on_api_request_completed)
	if api_client.has_signal("request_failed"):
		api_client.request_failed.connect(_on_api_request_failed)

func load_card(id: int):
	card_id = id
	_hide_card_content()
	status_label.text = "Loading card details..."
	status_label.modulate = Color.YELLOW
	api_client.get_card(card_id)

func _hide_card_content():
	card_container.visible = false
	status_label.visible = true

func _show_card_content():
	card_container.visible = true
	status_label.visible = false

func _on_api_request_completed(response):
	print("Card detail API request completed: ", response)
	
	if response.has("id"):
		card_data = response
		_display_card_details()
		_show_card_content()
	else:
		status_label.text = "Card not found"
		status_label.modulate = Color.RED

func _on_api_request_failed(error):
	print("Card detail API request failed: ", error)
	status_label.text = "Failed to load card: " + str(error)
	status_label.modulate = Color.RED

func _display_card_details():
	# Update UI with card data
	title_label.text = card_data.get("name", "Unknown Card")
	type_value.text = card_data.get("type", "unknown")
	cost_value.text = str(card_data.get("cost", 0))
	description_label.text = card_data.get("description", "No description available")
	
	# Generate effect code based on card type and name
	var effect_code = _generate_effect_code(card_data)
	effect_label.text = effect_code
	
	# Color type based on card type
	match card_data.get("type", "unknown"):
		"action":
			type_value.modulate = Color(1, 0.5, 0.5, 1)  # Red
		"event":
			type_value.modulate = Color(0.5, 0.5, 1, 1)   # Blue
		"power":
			type_value.modulate = Color(0.5, 1, 0.5, 1)   # Green
		_:
			type_value.modulate = Color(0.8, 0.8, 0.8, 1) # Gray

func _generate_effect_code(card: Dictionary) -> String:
	var card_name = card.get("name", "Unknown")
	var card_type = card.get("type", "unknown")
	var description = card.get("description", "")
	
	var code = "// JavaScript Effect for: " + card_name + "\n"
	code += "// Type: " + card_type + "\n\n"
	
	match card_name:
		"Code Slash":
			code += "// Deal damage and apply visual effect\n"
			code += "enemy.health -= 8;\n"
			code += "enemy.element.style.filter = 'hue-rotate(45deg) contrast(1.2)';\n"
			code += "enemy.element.classList.add('vulnerable');\n"
			code += "console.log('💥 Code Slash: 8 damage + Vulnerable applied!');"
		
		"Firewall Up":
			code += "// Gain shield and apply protective effect\n"
			code += "player.shield += 10;\n"
			code += "player.element.style.boxShadow = '0 0 20px cyan';\n"
			code += "player.element.style.border = '3px solid cyan';\n"
			code += "console.log('🛡️ Firewall Up: +10 Shield activated!');"
		
		"Bug Found":
			code += "// Disable traps and gain bonus card\n"
			code += "document.querySelectorAll('.trap').forEach(trap => {\n"
			code += "  trap.style.opacity = '0.3';\n"
			code += "  trap.classList.add('disabled');\n"
			code += "});\n"
			code += "player.drawCard();\n"
			code += "console.log('🐛 Bug Found: Traps disabled, card drawn!');"
		
		_:
			code += "// Custom effect based on description\n"
			code += "// " + description + "\n"
			code += "console.log('✨ " + card_name + " activated!');"
	
	return code

func _on_back_button_pressed():
	print("Card detail back button pressed")
	emit_signal("back_pressed")