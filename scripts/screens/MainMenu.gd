extends Control

signal play_pressed()
signal cards_pressed()
signal settings_pressed()
signal exit_pressed()
signal login_pressed()

@onready var play_button = $VBoxContainer/PlayButton
@onready var cards_button = $VBoxContainer/CardsButton
@onready var settings_button = $VBoxContainer/SettingsButton
@onready var login_button = $VBoxContainer/LoginButton
@onready var exit_button = $VBoxContainer/ExitButton
@onready var container = $VBoxContainer

func _ready():
	print("MainMenu ready")
	_setup_mobile_optimization()

func _setup_mobile_optimization():
	# Optimize layout for mobile
	TouchHelper.optimize_mobile_layout(container)
	
	# Add touch feedback to all buttons
	var buttons = [play_button, cards_button, settings_button, login_button, exit_button]
	for button in buttons:
		if button:
			TouchHelper.add_touch_feedback(button)
			button.button_down.connect(_on_button_pressed.bind(button))

func _on_button_pressed(button: Button):
	TouchHelper.create_press_feedback(button)

func _on_play_button_pressed():
	print("Play button pressed")
	emit_signal("play_pressed")

func _on_cards_button_pressed():
	print("Cards button pressed")
	emit_signal("cards_pressed")

func _on_settings_button_pressed():
	print("Settings button pressed")
	emit_signal("settings_pressed")

func _on_exit_button_pressed():
	print("Exit button pressed")
	emit_signal("exit_pressed")
	get_tree().quit()

func _on_login_button_pressed():
	print("Login button pressed")
	emit_signal("login_pressed")