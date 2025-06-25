extends Node

# Signals
signal request_completed(response)
signal request_failed(error)

# API configuration
var base_url: String = "http://localhost:8080/api/v1"
var health_url: String = "http://localhost:8080/health"
var version_url: String = "http://localhost:8080/v1/version"
var auth_token: String = ""

func _ready():
	print("APIClient initialized")

# System endpoints
func get_health():
	_make_direct_request(health_url, HTTPClient.METHOD_GET)

func get_version():
	_make_direct_request(version_url, HTTPClient.METHOD_GET)

# Auth endpoints (not yet implemented on server)
func register(username: String, password: String):
	var body = {"username": username, "password": password}
	_make_request("/auth/register", HTTPClient.METHOD_POST, body)

func login(username: String, password: String):
	var body = {"username": username, "password": password}
	_make_request("/auth/login", HTTPClient.METHOD_POST, body)

# Card endpoints
func get_cards():
	_make_request("/cards", HTTPClient.METHOD_GET)

func get_card(card_id: int):
	_make_request("/cards/" + str(card_id), HTTPClient.METHOD_GET)

# Deck endpoints
func get_decks():
	_make_request("/decks", HTTPClient.METHOD_GET)

func create_deck(name: String, card_ids: Array):
	var body = {"name": name, "cards": card_ids}
	_make_request("/decks", HTTPClient.METHOD_POST, body)

# Helper function to make HTTP requests to base_url
func _make_request(endpoint: String, method: int, body = null):
	var url = base_url + endpoint
	_make_direct_request(url, method, body)

# Helper function to make direct HTTP requests
func _make_direct_request(url: String, method: int, body = null):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed.bind(http_request))
	
	var headers = ["Content-Type: application/json"]
	if auth_token != "":
		headers.append("Authorization: Bearer " + auth_token)
	
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
		emit_signal("request_failed", "HTTP error: " + str(response_code))