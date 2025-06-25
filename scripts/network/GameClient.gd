extends Node

# Signals
signal connected_to_server()
signal disconnected_from_server()
signal error_received(error)
signal message_received(message)

# WebSocket configuration
var websocket_url: String = "ws://localhost:8080/ws"
var websocket: WebSocketPeer

func _ready():
	print("GameClient initialized")
	websocket = WebSocketPeer.new()

func connect_to_game_server():
	print("Connecting to game server at: ", websocket_url)
	var error = websocket.connect_to_url(websocket_url)
	if error != OK:
		print("Failed to connect: ", error)
		emit_signal("error_received", "Failed to connect to server")
	else:
		set_process(true)

func disconnect_from_server():
	if websocket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		websocket.close()
	set_process(false)

func send_message(message: Dictionary):
	if websocket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var json_message = JSON.stringify(message)
		websocket.send_text(json_message)
	else:
		print("WebSocket is not connected")

func _process(_delta):
	websocket.poll()
	
	var state = websocket.get_ready_state()
	
	if state == WebSocketPeer.STATE_OPEN:
		while websocket.get_available_packet_count():
			var packet = websocket.get_packet()
			if websocket.was_string_packet():
				var message = packet.get_string_from_utf8()
				_handle_message(message)
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling until closed
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = websocket.get_close_code()
		var reason = websocket.get_close_reason()
		print("WebSocket closed with code: %d, reason: %s" % [code, reason])
		emit_signal("disconnected_from_server")
		set_process(false)

func _handle_message(message: String):
	var json = JSON.new()
	var parse_result = json.parse(message)
	
	if parse_result == OK:
		var data = json.data
		emit_signal("message_received", data)
		
		# Handle specific message types
		if data.has("type"):
			match data.type:
				"connected":
					emit_signal("connected_to_server")
				"error":
					emit_signal("error_received", data.get("message", "Unknown error"))
				"game_state":
					_handle_game_state(data.get("state", {}))
				_:
					print("Unknown message type: ", data.type)
	else:
		print("Failed to parse message: ", message)

func _handle_game_state(state: Dictionary):
	# Handle game state updates
	print("Game state updated: ", state)