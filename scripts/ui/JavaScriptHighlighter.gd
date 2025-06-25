extends SyntaxHighlighter

# JavaScript syntax highlighter for the code editor
# Provides basic syntax highlighting for vibe coding

var keywords = [
	"function", "var", "let", "const", "if", "else", "for", "while", 
	"return", "true", "false", "null", "undefined", "new", "this",
	"class", "extends", "import", "export", "async", "await"
]

var methods = [
	"console.log", "console.error", "console.warn",
	"takeDamage", "heal", "gainShield", "gainEnergy",
	"debug", "exploit", "activateFirewall"
]

var operators = ["+", "-", "*", "/", "=", "==", "===", "!=", "!==", "<", ">", "<=", ">="]

func _get_line_syntax_highlighting(line: int) -> Dictionary:
	var text = get_text_edit().get_line(line)
	var result = {}
	
	if text.is_empty():
		return result
	
	var i = 0
	while i < text.length():
		var char = text[i]
		
		# Comments
		if i < text.length() - 1 and text.substr(i, 2) == "//":
			_add_color_region(result, i, text.length(), Color.GRAY)
			break
		
		# Strings
		elif char == '"' or char == "'":
			var end_pos = _find_string_end(text, i, char)
			_add_color_region(result, i, end_pos + 1, Color.GREEN)
			i = end_pos + 1
			continue
		
		# Numbers
		elif char.is_valid_int():
			var end_pos = _find_number_end(text, i)
			_add_color_region(result, i, end_pos, Color.ORANGE)
			i = end_pos
			continue
		
		# Keywords and identifiers
		elif char.is_valid_identifier():
			var word_end = _find_word_end(text, i)
			var word = text.substr(i, word_end - i)
			
			if word in keywords:
				_add_color_region(result, i, word_end, Color.CYAN)
			elif _is_method_call(text, i, word):
				_add_color_region(result, i, word_end, Color.YELLOW)
			
			i = word_end
			continue
		
		# Operators
		elif char in "+-*/=<>!":
			_add_color_region(result, i, i + 1, Color.RED)
		
		# Brackets and braces
		elif char in "(){}[]":
			_add_color_region(result, i, i + 1, Color.WHITE)
		
		i += 1
	
	return result

func _add_color_region(result: Dictionary, start: int, end: int, color: Color):
	for pos in range(start, end):
		result[pos] = {"color": color}

func _find_string_end(text: String, start: int, quote_char: String) -> int:
	var i = start + 1
	while i < text.length():
		if text[i] == quote_char:
			return i
		elif text[i] == "\\" and i + 1 < text.length():
			i += 2  # Skip escaped character
		else:
			i += 1
	return text.length() - 1

func _find_number_end(text: String, start: int) -> int:
	var i = start
	var has_dot = false
	
	while i < text.length():
		var char = text[i]
		if char.is_valid_int():
			i += 1
		elif char == "." and not has_dot:
			has_dot = true
			i += 1
		else:
			break
	
	return i

func _find_word_end(text: String, start: int) -> int:
	var i = start
	while i < text.length() and (text[i].is_valid_identifier() or text[i].is_valid_int()):
		i += 1
	return i

func _is_method_call(text: String, start: int, word: String) -> bool:
	var end_pos = start + word.length()
	
	# Check if followed by dot notation (object.method)
	if end_pos < text.length() and text[end_pos] == ".":
		return true
	
	# Check if followed by parentheses (function call)
	var i = end_pos
	while i < text.length() and text[i] == " ":
		i += 1
	
	if i < text.length() and text[i] == "(":
		return true
	
	# Check predefined methods
	for method in methods:
		if method.begins_with(word):
			return true
	
	return false