extends Control

signal back_pressed()

const MAX_DECK_SIZE = 30
const MAX_COPIES_PER_CARD = 3

var api_client
var all_cards = []
var deck_cards = []
var current_deck_name = "My Cyber Deck"

# UI References
@onready var deck_name_input = $MainContainer/LeftPanel/DeckInfo/DeckNameInput
@onready var card_count_label = $MainContainer/LeftPanel/DeckInfo/CardCountLabel
@onready var card_grid = $MainContainer/LeftPanel/TabContainer/"All Cards"/ScrollContainer/CardGrid
@onready var deck_card_list = $MainContainer/LeftPanel/TabContainer/"Deck Cards"/ScrollContainer/DeckCardList
@onready var search_input = $MainContainer/LeftPanel/TabContainer/"All Cards"/FilterContainer/SearchInput
@onready var type_filter = $MainContainer/LeftPanel/TabContainer/"All Cards"/FilterContainer/TypeFilter

# Stats UI
@onready var total_cards_label = $MainContainer/RightPanel/VBoxContainer/StatsContainer/TotalCardsLabel
@onready var action_cards_label = $MainContainer/RightPanel/VBoxContainer/StatsContainer/ActionCardsLabel
@onready var event_cards_label = $MainContainer/RightPanel/VBoxContainer/StatsContainer/EventCardsLabel
@onready var power_cards_label = $MainContainer/RightPanel/VBoxContainer/StatsContainer/PowerCardsLabel
@onready var cost_curve_container = $MainContainer/RightPanel/VBoxContainer/CostCurveContainer

# Card item scene (simplified button for now)
const card_item_style = """
background: #1a1a2e;
border: 2px solid #0ff;
border-radius: 4px;
padding: 10px;
"""

func _ready():
	print("DeckBuilder ready")
	_setup_api_client()
	_setup_filters()
	_load_cards()
	_update_deck_display()

func _setup_api_client():
	api_client = preload("res://scripts/network/APIClient.gd").new()
	api_client.name = "APIClient"
	add_child(api_client)
	
	if api_client.has_signal("request_completed"):
		api_client.request_completed.connect(_on_cards_loaded)
	if api_client.has_signal("request_failed"):
		api_client.request_failed.connect(_on_cards_load_failed)

func _setup_filters():
	type_filter.add_item("All Types")
	type_filter.add_item("Action")
	type_filter.add_item("Event")
	type_filter.add_item("Power")
	type_filter.selected = 0

func _load_cards():
	print("Loading cards from API...")
	api_client.get_cards()

func _on_cards_loaded(response):
	print("Cards loaded: ", response)
	if response.has("cards"):
		all_cards = response.cards
		_display_all_cards()
	else:
		print("No cards in response")

func _on_cards_load_failed(error):
	print("Failed to load cards: ", error)
	# Use demo cards for now
	all_cards = _get_demo_cards()
	_display_all_cards()

func _get_demo_cards():
	return [
		{"id": 1, "name": "Code Slash", "type": "action", "cost": 2, "description": "Deal 8 damage and apply Vulnerable"},
		{"id": 2, "name": "Firewall Up", "type": "action", "cost": 1, "description": "Gain 10 Shield"},
		{"id": 3, "name": "Bug Found", "type": "event", "cost": 0, "description": "Disable all traps, gain 1 random card"},
		{"id": 4, "name": "Syntax Error", "type": "action", "cost": 3, "description": "Deal 15 damage, discard 1 card"},
		{"id": 5, "name": "Debug Mode", "type": "power", "cost": 2, "description": "Draw 1 extra card each turn"},
		{"id": 6, "name": "Cache Hit", "type": "action", "cost": 0, "description": "Draw 2 cards"},
		{"id": 7, "name": "Stack Overflow", "type": "event", "cost": 1, "description": "All enemies take 5 damage"},
		{"id": 8, "name": "Encryption", "type": "power", "cost": 3, "description": "Gain 2 Shield at start of turn"}
	]

func _display_all_cards():
	# Clear existing cards
	for child in card_grid.get_children():
		child.queue_free()
	
	var search_text = search_input.text.to_lower()
	var type_index = type_filter.selected
	
	for card in all_cards:
		# Apply filters
		if search_text.length() > 0:
			if not card.name.to_lower().contains(search_text) and not card.description.to_lower().contains(search_text):
				continue
		
		if type_index > 0:
			var filter_type = ["", "action", "event", "power"][type_index]
			if card.type != filter_type:
				continue
		
		_create_card_item(card, card_grid, true)

func _create_card_item(card: Dictionary, parent: Node, is_add_mode: bool):
	var card_button = Button.new()
	card_button.custom_minimum_size = Vector2(150, 200)
	
	# Create card display text
	var card_text = card.name + "\n"
	card_text += "Cost: " + str(card.cost) + "\n"
	card_text += "Type: " + card.type.capitalize() + "\n\n"
	card_text += card.description
	
	card_button.text = card_text
	card_button.clip_text = true
	card_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# Style based on card type
	var color = Color.CYAN
	match card.type:
		"action":
			color = Color(1, 0.5, 0.5)
		"event":
			color = Color(0.5, 1, 0.5)
		"power":
			color = Color(0.5, 0.5, 1)
	
	card_button.modulate = color
	
	if is_add_mode:
		card_button.pressed.connect(_on_card_add_pressed.bind(card))
	else:
		card_button.pressed.connect(_on_card_remove_pressed.bind(card))
	
	parent.add_child(card_button)

func _on_card_add_pressed(card: Dictionary):
	if deck_cards.size() >= MAX_DECK_SIZE:
		print("Deck is full!")
		return
	
	# Count existing copies
	var copies = 0
	for deck_card in deck_cards:
		if deck_card.id == card.id:
			copies += 1
	
	if copies >= MAX_COPIES_PER_CARD:
		print("Maximum copies of this card reached!")
		return
	
	deck_cards.append(card)
	_update_deck_display()
	print("Added card to deck: ", card.name)

func _on_card_remove_pressed(card: Dictionary):
	for i in range(deck_cards.size() - 1, -1, -1):
		if deck_cards[i].id == card.id:
			deck_cards.remove_at(i)
			break
	
	_update_deck_display()
	print("Removed card from deck: ", card.name)

func _update_deck_display():
	# Update card count
	card_count_label.text = "Cards: " + str(deck_cards.size()) + "/" + str(MAX_DECK_SIZE)
	
	# Update deck cards display
	for child in deck_card_list.get_children():
		child.queue_free()
	
	# Group cards by ID and count
	var card_counts = {}
	for card in deck_cards:
		if not card_counts.has(card.id):
			card_counts[card.id] = {"card": card, "count": 0}
		card_counts[card.id].count += 1
	
	# Display grouped cards
	for card_data in card_counts.values():
		var card = card_data.card
		var count = card_data.count
		
		var card_container = HBoxContainer.new()
		
		# Card info
		var info_label = Label.new()
		info_label.text = card.name + " (Cost: " + str(card.cost) + ") x" + str(count)
		info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		# Remove button
		var remove_button = Button.new()
		remove_button.text = "Remove"
		remove_button.pressed.connect(_on_card_remove_pressed.bind(card))
		
		card_container.add_child(info_label)
		card_container.add_child(remove_button)
		deck_card_list.add_child(card_container)
	
	# Update statistics
	_update_deck_stats()

func _update_deck_stats():
	var total = deck_cards.size()
	var action_count = 0
	var event_count = 0
	var power_count = 0
	var cost_distribution = {}
	
	for card in deck_cards:
		match card.type:
			"action":
				action_count += 1
			"event":
				event_count += 1
			"power":
				power_count += 1
		
		var cost = card.cost
		if not cost_distribution.has(cost):
			cost_distribution[cost] = 0
		cost_distribution[cost] += 1
	
	# Update labels
	total_cards_label.text = "Total Cards: " + str(total)
	action_cards_label.text = "Action Cards: " + str(action_count)
	event_cards_label.text = "Event Cards: " + str(event_count)
	power_cards_label.text = "Power Cards: " + str(power_count)
	
	# Update cost curve
	for child in cost_curve_container.get_children():
		child.queue_free()
	
	# Display cost distribution
	for cost in range(0, 6):
		var count = cost_distribution.get(cost, 0)
		var cost_label = Label.new()
		cost_label.text = "Cost " + str(cost) + ": " + str(count) + " cards"
		
		# Visual bar
		if count > 0:
			var bar_length = int((float(count) / float(total)) * 100)
			cost_label.text += " [" + "=" .repeat(bar_length / 5) + "]"
		
		cost_curve_container.add_child(cost_label)

func _on_deck_name_changed(new_name: String):
	current_deck_name = new_name

func _on_search_text_changed(text: String):
	_display_all_cards()

func _on_type_filter_selected(index: int):
	_display_all_cards()

func _on_save_button_pressed():
	print("Saving deck: ", current_deck_name)
	# TODO: Implement deck saving when API is ready
	var deck_data = {
		"name": current_deck_name,
		"cards": deck_cards
	}
	print("Deck data: ", deck_data)

func _on_load_button_pressed():
	print("Loading deck...")
	# TODO: Implement deck loading when API is ready

func _on_clear_button_pressed():
	deck_cards.clear()
	_update_deck_display()
	print("Deck cleared")

func _on_back_button_pressed():
	print("Returning to main menu...")
	emit_signal("back_pressed")