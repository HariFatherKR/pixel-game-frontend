extends Node2D

# Scene references
const MainMenuScene = preload("res://scenes/screens/MainMenu.tscn")

# Network managers
var api_client: APIClient
var game_client: GameClient

# Current scene management
var current_scene: Node

func _ready():
	print("Cyberpunk Deckbuilder initialized")
	_setup_network()
	_setup_initial_scene()

func _setup_network():
	# Initialize API client
	api_client = APIClient.new()
	api_client.name = "APIClient"
	add_child(api_client)
	
	# Initialize WebSocket client
	game_client = GameClient.new()
	game_client.name = "GameClient"
	add_child(game_client)
	
	# Connect network signals
	api_client.request_completed.connect(_on_api_request_completed)
	api_client.request_failed.connect(_on_api_request_failed)
	
	game_client.connected_to_server.connect(_on_game_server_connected)
	game_client.disconnected_from_server.connect(_on_game_server_disconnected)
	game_client.error_received.connect(_on_game_server_error)

func _setup_initial_scene():
	_load_main_menu()

func _load_main_menu():
	if current_scene:
		current_scene.queue_free()
	
	var main_menu = $UI/MainMenu
	if main_menu:
		current_scene = main_menu
		main_menu.play_pressed.connect(_on_play_pressed)
		main_menu.deck_pressed.connect(_on_deck_pressed)
		main_menu.collection_pressed.connect(_on_collection_pressed)
		main_menu.settings_pressed.connect(_on_settings_pressed)

func _on_play_pressed():
	print("Play button pressed - Starting game")
	# TODO: Check if user is logged in
	# TODO: Load deck selection or quick play
	_start_quick_match()

func _on_deck_pressed():
	print("Deck builder button pressed")
	# TODO: Load deck builder scene

func _on_collection_pressed():
	print("Collection button pressed")
	# TODO: Load collection scene

func _on_settings_pressed():
	print("Settings button pressed")
	# TODO: Load settings scene

func _start_quick_match():
	# For now, connect to game server for testing
	print("Attempting to connect to game server...")
	game_client.connect_to_game_server()

# Network callbacks
func _on_api_request_completed(response):
	print("API request completed: ", response)

func _on_api_request_failed(error):
	print("API request failed: ", error)

func _on_game_server_connected():
	print("Connected to game server!")

func _on_game_server_disconnected():
	print("Disconnected from game server")

func _on_game_server_error(error):
	print("Game server error: ", error)