extends Control

signal play_pressed()
signal cards_pressed()
signal settings_pressed()
signal exit_pressed()
signal login_pressed()
signal test_pressed()

@onready var play_button = $VBoxContainer/PlayButton
@onready var cards_button = $VBoxContainer/CardsButton
@onready var settings_button = $VBoxContainer/SettingsButton
@onready var login_button = $VBoxContainer/LoginButton
@onready var exit_button = $VBoxContainer/ExitButton
@onready var test_button = $VBoxContainer/TestButton
@onready var container = $VBoxContainer

func _ready():
	print("MainMenu ready")
	_setup_mobile_optimization()
	_setup_responsive_design()

func _setup_responsive_design():
	# Connect to responsive manager if available
	var responsive_manager = get_node_or_null("/root/Main/ResponsiveManager")
	if responsive_manager:
		responsive_manager.screen_size_changed.connect(adapt_to_screen_size)
		responsive_manager.orientation_changed.connect(_on_orientation_changed)
	
	# Initial adaptation
	adapt_to_screen_size(get_viewport().size)

func adapt_to_screen_size(new_size: Vector2):
	# Adapt button sizes and layout to screen size
	var responsive_manager = get_node_or_null("/root/Main/ResponsiveManager")
	if not responsive_manager:
		return
	
	# Get optimal button size for current screen
	var optimal_button_size = responsive_manager.get_optimal_button_size()
	
	# Update all buttons
	var buttons = [play_button, cards_button, settings_button, login_button, exit_button, test_button]
	for button in buttons:
		if button:
			button.custom_minimum_size = optimal_button_size
	
	# Adapt container layout
	responsive_manager.adapt_container_layout(container)
	
	# Update font sizes
	_update_responsive_fonts(responsive_manager)

func _update_responsive_fonts(responsive_manager):
	# Update title font size
	var title_label = $VBoxContainer/TitleLabel
	if title_label:
		var responsive_title_size = responsive_manager.get_responsive_font_size(36)
		title_label.add_theme_font_size_override("font_size", responsive_title_size)
	
	# Update subtitle font size
	var subtitle_label = $VBoxContainer/SubtitleLabel
	if subtitle_label:
		var responsive_subtitle_size = responsive_manager.get_responsive_font_size(16)
		subtitle_label.add_theme_font_size_override("font_size", responsive_subtitle_size)

func _on_orientation_changed(is_portrait: bool):
	# Handle orientation changes if needed
	print("MainMenu orientation changed to: ", "Portrait" if is_portrait else "Landscape")
	
	# Adjust layout for landscape mode
	if not is_portrait:
		# In landscape mode, make buttons smaller and more compact
		container.add_theme_constant_override("separation", 16)
	else:
		# In portrait mode, use normal spacing
		container.add_theme_constant_override("separation", 24)

func _setup_mobile_optimization():
	# Optimize layout for mobile
	TouchHelper.optimize_mobile_layout(container)
	
	# Add touch feedback to all buttons
	var buttons = [play_button, cards_button, settings_button, login_button, exit_button, test_button]
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

func _on_test_button_pressed():
	print("Test button pressed")
	emit_signal("test_pressed")

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