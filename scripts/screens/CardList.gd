extends Control

signal back_pressed()

var api_client
var cards_data = []

@onready var status_label = $VBoxContainer/StatusLabel
@onready var card_container = $VBoxContainer/ScrollContainer/CardContainer

func _ready():
	print("CardList ready")
	_setup_api_client()
	_load_cards()

func _setup_api_client():
	api_client = preload("res://scripts/network/APIClient.gd").new()
	api_client.name = "APIClient"
	add_child(api_client)
	
	if api_client.has_signal("request_completed"):
		api_client.request_completed.connect(_on_api_request_completed)
	if api_client.has_signal("request_failed"):
		api_client.request_failed.connect(_on_api_request_failed)

func _load_cards():
	status_label.text = "Loading cards..."
	status_label.modulate = Color.YELLOW
	api_client.get_cards()

func _on_api_request_completed(response):
	print("API request completed: ", response)
	
	if response.has("cards"):
		cards_data = response.cards
		_display_cards()
		status_label.text = "Loaded " + str(response.total) + " cards"
		status_label.modulate = Color.GREEN
	else:
		status_label.text = "No cards found"
		status_label.modulate = Color.RED

func _on_api_request_failed(error):
	print("API request failed: ", error)
	status_label.text = "Failed to load cards: " + str(error)
	status_label.modulate = Color.RED

func _display_cards():
	# Clear existing cards
	for child in card_container.get_children():
		child.queue_free()
	
	# Create card UI for each card
	for card_data in cards_data:
		var card_ui = _create_card_ui(card_data)
		card_container.add_child(card_ui)

func _create_card_ui(card_data) -> Control:
	var card_scene = preload("res://scenes/components/Card.tscn")
	var card_instance = card_scene.instantiate()
	
	# Set card data
	card_instance.card_name = card_data.name
	card_instance.cost = card_data.cost
	card_instance.description = card_data.description
	card_instance.card_type = card_data.type
	
	# Update display
	card_instance.call_deferred("update_card_display")
	
	return card_instance

func _on_refresh_button_pressed():
	print("Refresh button pressed")
	_load_cards()

func _on_back_button_pressed():
	print("Back button pressed")
	emit_signal("back_pressed")