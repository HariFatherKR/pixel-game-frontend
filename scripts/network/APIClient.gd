extends Node
class_name APIClient

signal request_completed(response)
signal request_failed(error)

const BASE_URL = "http://localhost:8080/api"
var http_request: HTTPRequest
var auth_token: String = ""

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

func set_auth_token(token: String):
	auth_token = token

func _get_headers() -> PackedStringArray:
	var headers = PackedStringArray()
	headers.append("Content-Type: application/json")
	if auth_token != "":
		headers.append("Authorization: Bearer " + auth_token)
	return headers

func login(username: String, password: String):
	var body = JSON.stringify({
		"username": username,
		"password": password
	})
	_make_request("/auth/login", HTTPClient.METHOD_POST, body)

func register(username: String, password: String, email: String):
	var body = JSON.stringify({
		"username": username,
		"password": password,
		"email": email
	})
	_make_request("/auth/register", HTTPClient.METHOD_POST, body)

func get_cards():
	_make_request("/cards", HTTPClient.METHOD_GET)

func get_player_collection():
	_make_request("/player/collection", HTTPClient.METHOD_GET)

func get_player_decks():
	_make_request("/player/decks", HTTPClient.METHOD_GET)

func create_deck(deck_name: String, card_ids: Array):
	var body = JSON.stringify({
		"name": deck_name,
		"card_ids": card_ids
	})
	_make_request("/player/decks", HTTPClient.METHOD_POST, body)

func update_deck(deck_id: String, deck_data: Dictionary):
	var body = JSON.stringify(deck_data)
	_make_request("/player/decks/" + deck_id, HTTPClient.METHOD_PUT, body)

func delete_deck(deck_id: String):
	_make_request("/player/decks/" + deck_id, HTTPClient.METHOD_DELETE)

func start_match(deck_id: String):
	var body = JSON.stringify({
		"deck_id": deck_id
	})
	_make_request("/match/start", HTTPClient.METHOD_POST, body)

func get_leaderboard(limit: int = 100):
	_make_request("/leaderboard?limit=" + str(limit), HTTPClient.METHOD_GET)

func _make_request(endpoint: String, method: HTTPClient.Method, body: String = ""):
	var url = BASE_URL + endpoint
	var headers = _get_headers()
	
	if method == HTTPClient.METHOD_GET or method == HTTPClient.METHOD_DELETE:
		http_request.request(url, headers, method)
	else:
		http_request.request(url, headers, method, body)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if response_code >= 200 and response_code < 300:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		if parse_result == OK:
			request_completed.emit(json.data)
		else:
			request_failed.emit("Failed to parse response")
	else:
		var error_message = "Request failed with code: " + str(response_code)
		if body.size() > 0:
			var error_json = JSON.new()
			if error_json.parse(body.get_string_from_utf8()) == OK:
				error_message = error_json.data.get("message", error_message)
		request_failed.emit(error_message)