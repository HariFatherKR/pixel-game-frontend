extends Node

# Signals
signal request_completed(response)
signal request_failed(error)

# API configuration
var base_url: String = "http://localhost:8080"
var auth_token: String = ""
var refresh_token: String = ""

func _ready():
	print("APIClient initialized")

# System endpoints
func get_health():
	_make_request("/health", HTTPClient.METHOD_GET, null, false)

# Auth endpoints
func register(username: String, email: String, password: String, platform: String = "web"):
	var body = {
		"username": username,
		"email": email,
		"password": password,
		"platform": platform
	}
	_make_request("/auth/register", HTTPClient.METHOD_POST, body, false)

func login(username: String, password: String):
	var body = {"username": username, "password": password}
	_make_request("/auth/login", HTTPClient.METHOD_POST, body, false)

# Card endpoints
func get_cards(type: String = "", rarity: String = "", page: int = 1, limit: int = 20):
	var query_params = []
	if type != "":
		query_params.append("type=" + type)
	if rarity != "":
		query_params.append("rarity=" + rarity)
	query_params.append("page=" + str(page))
	query_params.append("limit=" + str(limit))
	
	var query_string = "?" + "&".join(query_params) if query_params.size() > 0 else ""
	_make_request("/cards" + query_string, HTTPClient.METHOD_GET)

func get_my_collection():
	_make_request("/cards/my-collection", HTTPClient.METHOD_GET)

# Deck endpoints
func get_decks():
	_make_request("/cards/decks", HTTPClient.METHOD_GET)

func create_deck(name: String, card_ids: Array):
	# Ensure we have 10-30 cards
	if card_ids.size() < 10 or card_ids.size() > 30:
		emit_signal("request_failed", "Deck must have between 10 and 30 cards")
		return
		
	var body = {"name": name, "card_ids": card_ids}
	_make_request("/cards/decks", HTTPClient.METHOD_POST, body)

# Game session endpoints
func start_game(game_mode: String = "STORY", deck_id: int = -1):
	var body = {"game_mode": game_mode}
	if deck_id >= 0:
		body["deck_id"] = deck_id
	_make_request("/games/start", HTTPClient.METHOD_POST, body)

func get_current_game():
	_make_request("/games/current", HTTPClient.METHOD_GET)

func get_game(game_id: int):
	_make_request("/games/" + str(game_id), HTTPClient.METHOD_GET)

func play_action(game_id: int, action_type: String, card_id: int = -1, target_id: int = -1, action_data = null):
	var body = {"action_type": action_type}
	if card_id >= 0:
		body["card_id"] = card_id
	if target_id >= 0:
		body["target_id"] = target_id
	if action_data != null:
		body["action_data"] = action_data
	_make_request("/games/" + str(game_id) + "/actions", HTTPClient.METHOD_POST, body)

func end_turn(game_id: int):
	_make_request("/games/" + str(game_id) + "/end-turn", HTTPClient.METHOD_POST, {})

func surrender_game(game_id: int):
	_make_request("/games/" + str(game_id) + "/surrender", HTTPClient.METHOD_POST, {})

func get_game_stats():
	_make_request("/games/stats", HTTPClient.METHOD_GET)

# Helper function to make HTTP requests
func _make_request(endpoint: String, method: int, body = null, requires_auth: bool = true):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed.bind(http_request))
	
	var headers = ["Content-Type: application/json"]
	if requires_auth and auth_token != "":
		headers.append("Authorization: Bearer " + auth_token)
	
	var url = base_url + endpoint
	
	if body != null:
		var json_body = JSON.stringify(body)
		http_request.request(url, headers, method, json_body)
	else:
		http_request.request(url, headers, method)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http_request: HTTPRequest):
	http_request.queue_free()
	
	if response_code >= 200 and response_code < 300:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		if parse_result == OK:
			emit_signal("request_completed", json.data)
		else:
			emit_signal("request_failed", "Failed to parse response")
	else:
		var error_msg = "HTTP error: " + str(response_code)
		
		# Try to parse error response
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		if parse_result == OK and json.data.has("error"):
			error_msg = json.data.error
		
		emit_signal("request_failed", error_msg)

# Store tokens after successful login/register
func set_auth_tokens(token: String, refresh: String = ""):
	auth_token = token
	refresh_token = refresh
	print("Auth tokens set")

# Clear tokens on logout
func clear_auth_tokens():
	auth_token = ""
	refresh_token = ""
	print("Auth tokens cleared")