extends Control

signal play_pressed()
signal deck_pressed()
signal collection_pressed()
signal settings_pressed()

@onready var play_button = $VBoxContainer/ButtonContainer/PlayButton
@onready var deck_button = $VBoxContainer/ButtonContainer/DeckButton
@onready var collection_button = $VBoxContainer/ButtonContainer/CollectionButton
@onready var settings_button = $VBoxContainer/ButtonContainer/SettingsButton

func _ready():
	# Connect button signals
	play_button.pressed.connect(_on_play_pressed)
	deck_button.pressed.connect(_on_deck_pressed)
	collection_button.pressed.connect(_on_collection_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	
	# Add button hover effects
	_setup_button_effects(play_button)
	_setup_button_effects(deck_button)
	_setup_button_effects(collection_button)
	_setup_button_effects(settings_button)
	
	# Animate entrance
	_animate_entrance()

func _setup_button_effects(button: Button):
	button.mouse_entered.connect(func(): _on_button_hover(button, true))
	button.mouse_exited.connect(func(): _on_button_hover(button, false))

func _on_button_hover(button: Button, is_hovering: bool):
	var tween = create_tween()
	if is_hovering:
		tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.1)
	else:
		tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)

func _animate_entrance():
	# Fade in animation
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	
	# Title animation
	var title_container = $VBoxContainer/TitleContainer
	var original_position = title_container.position
	title_container.position.y -= 50
	title_container.modulate.a = 0
	
	tween.parallel().tween_property(title_container, "position:y", original_position.y, 0.8)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(title_container, "modulate:a", 1.0, 0.8)
	
	# Button stagger animation
	var buttons = $VBoxContainer/ButtonContainer.get_children()
	for i in range(buttons.size()):
		var button = buttons[i]
		button.modulate.a = 0
		button.position.x -= 100
		
		tween.tween_property(button, "position:x", button.position.x + 100, 0.3)\
			.set_ease(Tween.EASE_OUT).set_delay(0.1 * i)
		tween.parallel().tween_property(button, "modulate:a", 1.0, 0.3)

func _on_play_pressed():
	_animate_button_press(play_button)
	play_pressed.emit()

func _on_deck_pressed():
	_animate_button_press(deck_button)
	deck_pressed.emit()

func _on_collection_pressed():
	_animate_button_press(collection_button)
	collection_pressed.emit()

func _on_settings_pressed():
	_animate_button_press(settings_button)
	settings_pressed.emit()

func _animate_button_press(button: Button):
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.05)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.05)