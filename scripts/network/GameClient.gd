extends Node
class_name GameClient

signal connected_to_server()
signal disconnected_from_server()
signal match_started(match_data)
signal game_state_updated(state)
signal card_played(player_id, card_data)
signal turn_changed(active_player)
signal match_ended(result)
signal error_received(error)

const WS_URL = "ws://localhost:8080/ws"
var socket: WebSocketPeer
var is_connected: bool = false
var reconnect_timer: Timer

func _ready():
	socket = WebSocketPeer.new()
	set_process(false)
	
	# Setup reconnect timer
	reconnect_timer = Timer.new()
	reconnect_timer.wait_time = 5.0
	reconnect_timer.timeout.connect(_attempt_reconnect)
	add_child(reconnect_timer)

func connect_to_game_server(auth_token: String = ""):
	var url = WS_URL
	if auth_token != "":
		url += "?token=" + auth_token
	
	var error = socket.connect_to_url(url)
	if error == OK:
		set_process(true)
	else:
		print("Failed to connect to WebSocket server: ", error)
		error_received.emit("Failed to connect to server")

func disconnect_from_server():
	if socket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		socket.close()
	is_connected = false
	set_process(false)
	disconnected_from_server.emit()

func _process(_delta):
	socket.poll()
	
	var state = socket.get_ready_state()
	
	if state == WebSocketPeer.STATE_OPEN:
		if not is_connected:
			is_connected = true
			connected_to_server.emit()
			reconnect_timer.stop()
		
		while socket.get_available_packet_count() > 0:
			var packet = socket.get_packet()
			_handle_packet(packet)
			
	elif state == WebSocketPeer.STATE_CLOSED:
		if is_connected:
			is_connected = false
			set_process(false)
			disconnected_from_server.emit()
			reconnect_timer.start()

func _handle_packet(packet: PackedByteArray):
	var json = JSON.new()
	var parse_result = json.parse(packet.get_string_from_utf8())
	
	if parse_result != OK:
		print("Failed to parse WebSocket message")
		return
	
	var data = json.data
	if not data.has("type"):
		print("Invalid message format: missing type")
		return
	
	match data.type:
		"match_start":
			match_started.emit(data.get("data", {}))
		"game_state":
			game_state_updated.emit(data.get("data", {}))
		"card_played":
			card_played.emit(data.get("player_id", ""), data.get("card", {}))
		"turn_change":
			turn_changed.emit(data.get("active_player", ""))
		"match_end":
			match_ended.emit(data.get("result", {}))
		"error":
			error_received.emit(data.get("message", "Unknown error"))
		_:
			print("Unknown message type: ", data.type)

func send_message(message_type: String, data: Dictionary):
	if not is_connected:
		error_received.emit("Not connected to server")
		return
	
	var message = {
		"type": message_type,
		"data": data
	}
	
	var json_string = JSON.stringify(message)
	socket.send_text(json_string)

func play_card(card_id: String, target_id: String = ""):
	var data = {
		"card_id": card_id,
		"target_id": target_id
	}
	send_message("play_card", data)

func end_turn():
	send_message("end_turn", {})

func mulligan(card_ids: Array):
	send_message("mulligan", {"card_ids": card_ids})

func concede():
	send_message("concede", {})

func _attempt_reconnect():
	print("Attempting to reconnect to server...")
	connect_to_game_server()