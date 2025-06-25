extends Control

signal login_success(username: String, token: String)
signal back_pressed()

var api_client

@onready var tab_container = $LoginContainer/VBoxContainer/TabContainer
@onready var status_label = $LoginContainer/VBoxContainer/StatusLabel

# Login form
@onready var login_username = $LoginContainer/VBoxContainer/TabContainer/Login/LoginForm/UsernameInput
@onready var login_password = $LoginContainer/VBoxContainer/TabContainer/Login/LoginForm/PasswordInput

# Register form
@onready var register_username = $LoginContainer/VBoxContainer/TabContainer/Register/RegisterForm/UsernameInput
@onready var register_email = $LoginContainer/VBoxContainer/TabContainer/Register/RegisterForm/EmailInput
@onready var register_password = $LoginContainer/VBoxContainer/TabContainer/Register/RegisterForm/PasswordInput
@onready var register_confirm = $LoginContainer/VBoxContainer/TabContainer/Register/RegisterForm/ConfirmInput

func _ready():
	print("LoginScreen ready")
	_setup_api_client()
	_clear_status()

func _setup_api_client():
	api_client = preload("res://scripts/network/APIClient.gd").new()
	api_client.name = "APIClient"
	add_child(api_client)
	
	if api_client.has_signal("request_completed"):
		api_client.request_completed.connect(_on_api_request_completed)
	if api_client.has_signal("request_failed"):
		api_client.request_failed.connect(_on_api_request_failed)

func _clear_status():
	status_label.text = ""
	status_label.modulate = Color.WHITE

func _show_status(message: String, is_error: bool = false):
	status_label.text = message
	status_label.modulate = Color.RED if is_error else Color.GREEN

func _on_login_button_pressed():
	var username = login_username.text.strip_edges()
	var password = login_password.text
	
	# Validation
	if username.length() < 3:
		_show_status("Username must be at least 3 characters", true)
		return
	
	if password.length() < 6:
		_show_status("Password must be at least 6 characters", true)
		return
	
	_show_status("Logging in...")
	
	# Real API call
	api_client.login(username, password)

func _on_register_button_pressed():
	var username = register_username.text.strip_edges()
	var email = register_email.text.strip_edges()
	var password = register_password.text
	var confirm = register_confirm.text
	
	# Validation
	if username.length() < 3:
		_show_status("Username must be at least 3 characters", true)
		return
	
	if not _is_valid_email(email):
		_show_status("Please enter a valid email", true)
		return
	
	if password.length() < 6:
		_show_status("Password must be at least 6 characters", true)
		return
	
	if password != confirm:
		_show_status("Passwords do not match", true)
		return
	
	_show_status("Registering...")
	
	# Real API call
	api_client.register(username, email, password)

func _is_valid_email(email: String) -> bool:
	# Basic email validation
	var regex = RegEx.new()
	regex.compile("^[^@]+@[^@]+\\.[^@]+$")
	return regex.search(email) != null

func _on_api_request_completed(response):
	print("Auth API response: ", response)
	
	if response.has("token"):
		# Login/Register successful
		var token = response.get("token", "")
		var refresh_token = response.get("refresh_token", "")
		api_client.set_auth_tokens(token, refresh_token)
		
		if response.has("user"):
			var username = response.user.get("username", "")
			_show_status("Welcome, " + username + "!")
			await get_tree().create_timer(1.0).timeout
			emit_signal("login_success", username, token)
		else:
			_show_status("Authentication successful!")
			await get_tree().create_timer(1.0).timeout
			emit_signal("login_success", "", token)
	else:
		_show_status("Unexpected response", true)

func _on_api_request_failed(error):
	print("Auth API error: ", error)
	_show_status("Error: " + str(error), true)

func _on_back_button_pressed():
	print("Back button pressed")
	emit_signal("back_pressed")