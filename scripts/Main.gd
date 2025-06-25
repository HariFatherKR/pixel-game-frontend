extends Node2D

# Scene references
const MainMenuScene = preload("res://scenes/screens/MainMenu.tscn")
const CardListScene = preload("res://scenes/screens/CardList.tscn")
const CardDetailScene = preload("res://scenes/screens/CardDetail.tscn")
const LoginScreenScene = preload("res://scenes/screens/LoginScreen.tscn")
const DeckBuilderScene = preload("res://scenes/screens/DeckBuilder.tscn")
const BattleScene = preload("res://scenes/screens/BattleScene.tscn")

# Current scene management
var current_scene: Node

func _ready():
	print("Cyberpunk Deckbuilder initialized")
	_setup_initial_scene()

func _setup_initial_scene():
	_load_main_menu()

func _load_main_menu():
	if current_scene:
		current_scene.queue_free()
	
	current_scene = MainMenuScene.instantiate()
	$UI.add_child(current_scene)
	
	# Connect signals
	if current_scene.has_signal("play_pressed"):
		current_scene.play_pressed.connect(_on_play_pressed)
	if current_scene.has_signal("cards_pressed"):
		current_scene.cards_pressed.connect(_on_cards_pressed)
	if current_scene.has_signal("settings_pressed"):
		current_scene.settings_pressed.connect(_on_settings_pressed)
	if current_scene.has_signal("login_pressed"):
		current_scene.login_pressed.connect(_on_login_pressed)
	if current_scene.has_signal("exit_pressed"):
		current_scene.exit_pressed.connect(_on_exit_pressed)
	
	print("Main menu loaded")

func _on_play_pressed():
	print("Opening deck builder...")
	_load_deck_builder()
	
func _on_cards_pressed():
	print("Opening card list...")
	_load_card_list()
	
func _on_settings_pressed():
	print("Opening settings...")
	# TODO: Load settings scene
	
func _on_exit_pressed():
	print("Exiting game...")
	get_tree().quit()

func _load_card_list():
	if current_scene:
		current_scene.queue_free()
	
	current_scene = CardListScene.instantiate()
	$UI.add_child(current_scene)
	
	# Connect signals
	if current_scene.has_signal("back_pressed"):
		current_scene.back_pressed.connect(_on_card_list_back_pressed)
	if current_scene.has_signal("card_detail_requested"):
		current_scene.card_detail_requested.connect(_on_card_detail_requested)
	
	print("Card list loaded")

func _on_card_list_back_pressed():
	print("Returning to main menu...")
	_load_main_menu()

func _on_card_detail_requested(card_id: int):
	print("Loading card detail for ID: ", card_id)
	_load_card_detail(card_id)

func _load_card_detail(card_id: int):
	if current_scene:
		current_scene.queue_free()
	
	current_scene = CardDetailScene.instantiate()
	$UI.add_child(current_scene)
	
	# Connect back signal
	if current_scene.has_signal("back_pressed"):
		current_scene.back_pressed.connect(_on_card_detail_back_pressed)
	
	# Load card data
	current_scene.call_deferred("load_card", card_id)
	
	print("Card detail loaded")

func _on_card_detail_back_pressed():
	print("Returning to card list...")
	_load_card_list()

func _on_login_pressed():
	print("Opening login screen...")
	_load_login_screen()

func _load_login_screen():
	if current_scene:
		current_scene.queue_free()
	
	current_scene = LoginScreenScene.instantiate()
	$UI.add_child(current_scene)
	
	# Connect signals
	if current_scene.has_signal("back_pressed"):
		current_scene.back_pressed.connect(_on_login_back_pressed)
	if current_scene.has_signal("login_success"):
		current_scene.login_success.connect(_on_login_success)
	
	print("Login screen loaded")

func _on_login_back_pressed():
	print("Returning to main menu from login...")
	_load_main_menu()

func _on_login_success(username: String, token: String):
	print("Login successful for user: ", username)
	# TODO: Store user session data
	# For now, just return to main menu
	_load_main_menu()

func _load_deck_builder():
	if current_scene:
		current_scene.queue_free()
	
	current_scene = DeckBuilderScene.instantiate()
	$UI.add_child(current_scene)
	
	# Connect signals
	if current_scene.has_signal("back_pressed"):
		current_scene.back_pressed.connect(_on_deck_builder_back_pressed)
	if current_scene.has_signal("start_battle_requested"):
		current_scene.start_battle_requested.connect(_on_start_battle_requested)
	
	print("Deck builder loaded")

func _on_deck_builder_back_pressed():
	print("Returning to main menu from deck builder...")
	_load_main_menu()

func _load_battle_scene(game_id: int = -1, deck_id: int = -1):
	if current_scene:
		current_scene.queue_free()
	
	current_scene = BattleScene.instantiate()
	$UI.add_child(current_scene)
	
	# Connect signals
	if current_scene.has_signal("battle_ended"):
		current_scene.battle_ended.connect(_on_battle_ended)
	if current_scene.has_signal("return_to_menu"):
		current_scene.return_to_menu.connect(_on_battle_return_to_menu)
	
	# Start battle
	current_scene.start_battle(game_id, deck_id)
	
	print("Battle scene loaded")

func _on_battle_ended(victory: bool):
	print("Battle ended. Victory: ", victory)
	# TODO: Show rewards screen
	_load_main_menu()

func _on_battle_return_to_menu():
	print("Returning to main menu from battle...")
	_load_main_menu()

func _on_start_battle_requested(deck_id: int):
	print("Battle requested with deck_id: ", deck_id)
	_load_battle_scene(-1, deck_id)