extends Panel

# Signals
signal card_clicked(card_id: int)

# Card properties
var card_id: int = 0
var card_name: String = "Debug Card"
var cost: int = 2
var power: int = 5
var description: String = "This is a test card"
var card_type: String = "action"

# Drag and drop variables
var is_dragging: bool = false
var drag_offset: Vector2

func _ready():
	# Update card display
	update_card_display()
	
	# Enable input
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func update_card_display():
	if has_node("VBoxContainer/TitleLabel"):
		$VBoxContainer/TitleLabel.text = card_name
	if has_node("VBoxContainer/CostLabel"):
		$VBoxContainer/CostLabel.text = "Cost: " + str(cost)
	if has_node("VBoxContainer/DescriptionLabel"):
		$VBoxContainer/DescriptionLabel.text = description
	if has_node("VBoxContainer/PowerLabel"):
		var power_text = "Type: " + card_type
		if power > 0:
			power_text += " | Power: " + str(power)
		$VBoxContainer/PowerLabel.text = power_text

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start dragging
				is_dragging = true
				drag_offset = global_position - event.global_position
			else:
				# Stop dragging and check for click
				if is_dragging:
					var drag_distance = (global_position - (event.global_position + drag_offset)).length()
					if drag_distance < 10:  # Consider it a click if drag distance is small
						emit_signal("card_clicked", card_id)
						print("Card clicked: ", card_id, " - ", card_name)
				is_dragging = false
	
	elif event is InputEventMouseMotion and is_dragging:
		# Update position while dragging
		global_position = event.global_position + drag_offset

func _on_mouse_entered():
	# Hover effect
	modulate = Color(1.2, 1.2, 1.2)
	scale = Vector2(1.05, 1.05)

func _on_mouse_exited():
	# Remove hover effect
	modulate = Color(1, 1, 1)
	scale = Vector2(1, 1)