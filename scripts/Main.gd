extends Node2D

# Scene references
const MainMenuScene = preload("res://scenes/screens/MainMenu.tscn")

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
	if current_scene.has_signal("settings_pressed"):
		current_scene.settings_pressed.connect(_on_settings_pressed)
	if current_scene.has_signal("exit_pressed"):
		current_scene.exit_pressed.connect(_on_exit_pressed)
	
	print("Main menu loaded")

func _on_play_pressed():
	print("Starting game...")
	# TODO: Load game scene
	
func _on_settings_pressed():
	print("Opening settings...")
	# TODO: Load settings scene
	
func _on_exit_pressed():
	print("Exiting game...")
	get_tree().quit()