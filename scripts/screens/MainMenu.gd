extends Control

signal play_pressed()
signal cards_pressed()
signal settings_pressed()
signal exit_pressed()
signal login_pressed()

func _ready():
	print("MainMenu ready")

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