extends Control

# Console Panel for displaying JavaScript execution logs
# Mimics developer console for vibe coding experience

signal console_cleared()
signal log_selected(log_data: Dictionary)

var log_container
var scroll_container
var clear_button
var toggle_button
var log_entries = []
var max_logs = 100
var is_visible = true
var auto_scroll = true

# Console styling
var console_font_size = 12
var log_colors = {
	"info": Color.WHITE,
	"success": Color.GREEN,
	"error": Color.RED,
	"warning": Color.YELLOW,
	"debug": Color.CYAN
}

func _ready():
	name = "ConsolePanel"
	_setup_ui()
	_setup_styling()
	_connect_signals()
	
	# Add welcome message
	add_log("🎮 JavaScript Bridge Console initialized")
	add_log("💡 Card effects will appear here...")

func _setup_ui():
	# Main container
	set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	size.y = 200
	
	# Background panel
	var background = Panel.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	
	# Header with title and controls
	var header = HBoxContainer.new()
	header.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	header.size.y = 30
	add_child(header)
	
	# Console title
	var title_label = Label.new()
	title_label.text = "📟 JavaScript Console"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_label)
	
	# Clear button
	clear_button = Button.new()
	clear_button.text = "Clear"
	clear_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	header.add_child(clear_button)
	
	# Toggle button
	toggle_button = Button.new()
	toggle_button.text = "Hide"
	toggle_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	header.add_child(toggle_button)
	
	# Scroll container for logs
	scroll_container = ScrollContainer.new()
	scroll_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll_container.offset_top = 35
	scroll_container.offset_bottom = -5
	scroll_container.scroll_horizontal_enabled = false
	add_child(scroll_container)
	
	# Log container
	log_container = VBoxContainer.new()
	log_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(log_container)

func _setup_styling():
	# Apply cyberpunk console theme
	var theme = load("res://themes/cyberpunk_theme.tres")
	if theme:
		set_theme(theme)
	
	# Console-specific styling
	modulate = Color(1, 1, 1, 0.95)

func _connect_signals():
	if clear_button:
		clear_button.pressed.connect(_on_clear_pressed)
	if toggle_button:
		toggle_button.pressed.connect(_on_toggle_pressed)

func add_log(message: String, log_type: String = "info"):
	var timestamp = Time.get_datetime_string_from_system()
	var log_data = {
		"timestamp": timestamp,
		"message": message,
		"type": log_type
	}
	
	log_entries.append(log_data)
	
	# Limit log entries
	if log_entries.size() > max_logs:
		log_entries.pop_front()
		if log_container.get_child_count() > 0:
			log_container.get_child(0).queue_free()
	
	_create_log_entry(log_data)
	
	# Auto-scroll to bottom
	if auto_scroll:
		await get_tree().process_frame
		_scroll_to_bottom()

func _create_log_entry(log_data: Dictionary):
	var entry_container = HBoxContainer.new()
	entry_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Timestamp
	var time_label = Label.new()
	time_label.text = "[" + log_data.timestamp.split(" ")[1] + "]"
	time_label.custom_minimum_size.x = 80
	time_label.add_theme_font_size_override("font_size", console_font_size - 2)
	time_label.modulate = Color.GRAY
	entry_container.add_child(time_label)
	
	# Log message
	var message_label = RichTextLabel.new()
	message_label.bbcode_enabled = true
	message_label.fit_content = true
	message_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message_label.custom_minimum_size.y = 20
	message_label.add_theme_font_size_override("normal_font_size", console_font_size)
	
	# Apply color based on log type
	var color = log_colors.get(log_data.type, Color.WHITE)
	var colored_message = "[color=" + color.to_html() + "]" + log_data.message + "[/color]"
	message_label.text = colored_message
	
	entry_container.add_child(message_label)
	
	# Add click functionality for detailed view
	entry_container.gui_input.connect(_on_log_entry_clicked.bind(log_data))
	
	log_container.add_child(entry_container)
	
	# Add separator for readability
	if log_entries.size() > 1:
		var separator = HSeparator.new()
		separator.modulate = Color(0.3, 0.3, 0.3, 0.5)
		log_container.add_child(separator)

func _on_log_entry_clicked(log_data: Dictionary, event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("log_selected", log_data)
		print("Selected log: ", log_data.message)

func _scroll_to_bottom():
	if scroll_container:
		scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

func _on_clear_pressed():
	clear_logs()

func _on_toggle_pressed():
	toggle_visibility()

func clear_logs():
	log_entries.clear()
	
	# Remove all log entries from UI
	for child in log_container.get_children():
		child.queue_free()
	
	emit_signal("console_cleared")
	add_log("🗑️ Console cleared", "info")

func toggle_visibility():
	is_visible = !is_visible
	
	if is_visible:
		show()
		toggle_button.text = "Hide"
		add_log("👁️ Console shown", "info")
	else:
		hide()
		toggle_button.text = "Show"

func set_auto_scroll(enabled: bool):
	auto_scroll = enabled

func get_log_history() -> Array:
	return log_entries.duplicate(true)

func export_logs() -> String:
	var export_text = "=== JavaScript Console Export ===\n"
	export_text += "Generated: " + Time.get_datetime_string_from_system() + "\n\n"
	
	for log in log_entries:
		export_text += "[" + log.timestamp + "] " + log.type.to_upper() + ": " + log.message + "\n"
	
	return export_text

func add_separator(text: String = ""):
	var separator_container = VBoxContainer.new()
	
	var line = HSeparator.new()
	line.modulate = Color.CYAN
	separator_container.add_child(line)
	
	if text != "":
		var label = Label.new()
		label.text = "─── " + text + " ───"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.modulate = Color.CYAN
		label.add_theme_font_size_override("font_size", console_font_size)
		separator_container.add_child(label)
	
	log_container.add_child(separator_container)

# Predefined log functions for common types
func log_info(message: String):
	add_log("ℹ️ " + message, "info")

func log_success(message: String):
	add_log("✅ " + message, "success")

func log_error(message: String):
	add_log("❌ " + message, "error")

func log_warning(message: String):
	add_log("⚠️ " + message, "warning")

func log_debug(message: String):
	add_log("🔍 " + message, "debug")

# Special logging for card effects
func log_card_effect(card_name: String, effect: String):
	add_separator("CARD EFFECT")
	add_log("🎴 " + card_name + ": " + effect, "info")

func log_code_execution(code: String, result: String):
	add_log("💻 Code: " + code, "debug")
	add_log("📤 Result: " + result, "success")

func log_dom_change(element: String, property: String, value: String):
	add_log("🔧 DOM Update: " + element + "." + property + " = " + value, "debug")