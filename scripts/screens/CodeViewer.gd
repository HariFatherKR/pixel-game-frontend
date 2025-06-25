extends Control

# Code Viewer for displaying and editing JavaScript code
# Shows the generated vibe coding for cards

signal code_executed(code: String)
signal code_modified(new_code: String)

var code_editor
var execute_button
var reset_button
var close_button
var card_name_label
var current_card_data = {}
var original_code = ""

func _ready():
	name = "CodeViewer"
	_setup_ui()
	_setup_styling()
	_connect_signals()

func _setup_ui():
	# Main container
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	size = Vector2(600, 400)
	
	# Background panel
	var background = Panel.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	
	# Header
	var header = HBoxContainer.new()
	header.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	header.size.y = 40
	add_child(header)
	
	# Card name label
	card_name_label = Label.new()
	card_name_label.text = "Card Code Viewer"
	card_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_name_label.add_theme_font_size_override("font_size", 16)
	header.add_child(card_name_label)
	
	# Close button
	close_button = Button.new()
	close_button.text = "✕"
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	header.add_child(close_button)
	
	# Code editor
	code_editor = TextEdit.new()
	code_editor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	code_editor.offset_top = 45
	code_editor.offset_bottom = -45
	code_editor.placeholder_text = "// JavaScript code will appear here..."
	code_editor.syntax_highlighter = preload("res://scripts/ui/JavaScriptHighlighter.gd").new()
	add_child(code_editor)
	
	# Footer with buttons
	var footer = HBoxContainer.new()
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer.size.y = 40
	add_child(footer)
	
	# Reset button
	reset_button = Button.new()
	reset_button.text = "Reset Code"
	reset_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(reset_button)
	
	# Execute button
	execute_button = Button.new()
	execute_button.text = "▶ Execute Code"
	execute_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(execute_button)

func _setup_styling():
	# Apply cyberpunk theme
	var theme = load("res://themes/cyberpunk_theme.tres")
	if theme:
		set_theme(theme)
	
	# Initially hidden
	visible = false
	modulate = Color(1, 1, 1, 0.95)

func _connect_signals():
	if execute_button:
		execute_button.pressed.connect(_on_execute_pressed)
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	if code_editor:
		code_editor.text_changed.connect(_on_code_changed)

func show_card_code(card_data: Dictionary):
	current_card_data = card_data
	var card_name = card_data.get("name", "Unknown Card")
	var code = card_data.get("code", "")
	
	card_name_label.text = "📝 " + card_name + " - JavaScript Code"
	code_editor.text = code
	original_code = code
	
	# Show with animation
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3).from(Vector2(0.8, 0.8))

func hide_viewer():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.2)
	tween.tween_callback(func(): visible = false)

func _on_execute_pressed():
	var code = code_editor.text
	print("Executing code: ", code)
	emit_signal("code_executed", code)
	
	# Visual feedback
	execute_button.text = "✓ Executed"
	execute_button.disabled = true
	
	await get_tree().create_timer(1.0).timeout
	execute_button.text = "▶ Execute Code"
	execute_button.disabled = false

func _on_reset_pressed():
	code_editor.text = original_code
	
	# Visual feedback
	reset_button.text = "✓ Reset"
	await get_tree().create_timer(0.5).timeout
	reset_button.text = "Reset Code"

func _on_close_pressed():
	hide_viewer()

func _on_code_changed():
	var new_code = code_editor.text
	if new_code != original_code:
		emit_signal("code_modified", new_code)
		# Update card data
		current_card_data.code = new_code

func get_current_code() -> String:
	return code_editor.text

func is_code_modified() -> bool:
	return code_editor.text != original_code

# Add syntax highlighting and code completion hints
func add_code_hint(hint: String):
	var current_text = code_editor.text
	var cursor_pos = code_editor.caret_column
	var line = code_editor.caret_line
	
	# Insert hint at cursor position
	var lines = current_text.split("\n")
	if line < lines.size():
		var current_line = lines[line]
		var new_line = current_line.insert(cursor_pos, hint)
		lines[line] = new_line
		code_editor.text = "\n".join(lines)
		
		# Move cursor after hint
		code_editor.caret_line = line
		code_editor.caret_column = cursor_pos + hint.length()

# Predefined code snippets for quick insertion
func get_code_snippets() -> Dictionary:
	return {
		"damage": "enemy.takeDamage(8);",
		"heal": "player.heal(5);",
		"shield": "player.gainShield(3);",
		"energy": "player.gainEnergy(1);",
		"debug": "system.debug(); console.log('Debug mode active');",
		"hack": "enemy.exploit(); console.log('System compromised');",
		"firewall": "player.activateFirewall(); console.log('Firewall active');",
		"loop": "for(let i = 0; i < 3; i++) {\n    // Repeat effect\n}",
		"condition": "if(enemy.health < 20) {\n    // Low health effect\n}",
		"console": "console.log('Effect triggered');"
	}

func insert_snippet(snippet_key: String):
	var snippets = get_code_snippets()
	if snippets.has(snippet_key):
		add_code_hint(snippets[snippet_key])

# Format code with basic indentation
func format_code():
	var lines = code_editor.text.split("\n")
	var formatted_lines = []
	var indent_level = 0
	
	for line in lines:
		var trimmed = line.strip_edges()
		
		# Decrease indent for closing braces
		if trimmed.ends_with("}"):
			indent_level = max(0, indent_level - 1)
		
		# Add indentation
		var indented_line = ""
		for i in range(indent_level):
			indented_line += "    "
		indented_line += trimmed
		
		formatted_lines.append(indented_line)
		
		# Increase indent for opening braces
		if trimmed.ends_with("{"):
			indent_level += 1
	
	code_editor.text = "\n".join(formatted_lines)