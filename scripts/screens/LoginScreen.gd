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
	
	# Temporary demo logic (remove when server endpoints are ready)
	if username == "demo" and password == "demo123":
		_show_status("Login successful! (Demo mode)")
		await get_tree().create_timer(1.0).timeout
		emit_signal("login_success", username, "demo_token_123")
	else:
		# Real API call (uncomment when server is ready)
		# api_client.login(username, password)
		_show_status("Login failed! (Server not available, try demo/demo123)", true)

func _on_register_button_pressed():
	var username = register_username.text.strip_edges()
	var password = register_password.text
	var confirm = register_confirm.text
	
	# Validation
	if username.length() < 3:
		_show_status("Username must be at least 3 characters", true)
		return
	
	if password.length() < 6:
		_show_status("Password must be at least 6 characters", true)
		return
	
	if password != confirm:
		_show_status("Passwords do not match", true)
		return
	
	_show_status("Registering...")
	
	# Temporary demo logic
	_show_status("Registration successful! (Demo mode)")
	await get_tree().create_timer(1.0).timeout
	# Switch to login tab
	tab_container.current_tab = 0
	login_username.text = username
	login_password.text = ""
	_show_status("Please login with your new account")
	
	# Real API call (uncomment when server is ready)
	# api_client.register(username, password)

func _on_api_request_completed(response):
	print("Auth API response: ", response)
	
	if response.has("token"):
		# Login successful
		var username = response.get("username", login_username.text)
		var token = response.get("token", "")
		api_client.auth_token = token
		_show_status("Login successful!")
		await get_tree().create_timer(1.0).timeout
		emit_signal("login_success", username, token)
	elif response.has("message"):
		# Registration successful
		_show_status("Registration successful! Please login.")
		tab_container.current_tab = 0
	else:
		_show_status("Unexpected response", true)

func _on_api_request_failed(error):
	print("Auth API error: ", error)
	_show_status("Error: " + str(error), true)

func _on_back_button_pressed():
	print("Back button pressed")
	emit_signal("back_pressed")