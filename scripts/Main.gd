extends Node2D

# Scene references
const MainMenuScene = preload("res://scenes/screens/MainMenu.tscn")
const CardListScene = preload("res://scenes/screens/CardList.tscn")

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
	if current_scene.has_signal("exit_pressed"):
		current_scene.exit_pressed.connect(_on_exit_pressed)
	
	print("Main menu loaded")

func _on_play_pressed():
	print("Starting game...")
	# TODO: Load game scene
	
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
	
	# Connect back signal
	if current_scene.has_signal("back_pressed"):
		current_scene.back_pressed.connect(_on_card_list_back_pressed)
	
	print("Card list loaded")

func _on_card_list_back_pressed():
	print("Returning to main menu...")
	_load_main_menu()