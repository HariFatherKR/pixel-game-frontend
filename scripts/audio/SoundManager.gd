extends Node

# Sound Manager for handling all audio effects
# This is a placeholder implementation that can be expanded with actual audio files

signal sound_played(sound_name: String)

var audio_players = {}
var sound_enabled = true
var master_volume = 1.0

func _ready():
	print("SoundManager initialized")
	_setup_audio_players()

func _setup_audio_players():
	# Create audio stream players for different sound categories
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	add_child(sfx_player)
	audio_players["sfx"] = sfx_player
	
	var music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	add_child(music_player)
	audio_players["music"] = music_player
	
	var ui_player = AudioStreamPlayer.new()
	ui_player.name = "UIPlayer"
	add_child(ui_player)
	audio_players["ui"] = ui_player

func play_sound(sound_name: String, category: String = "sfx"):
	if not sound_enabled:
		return
	
	print("Playing sound: ", sound_name, " (", category, ")")
	
	# TODO: Load actual audio files based on sound_name
	# For now, just emit signal for debugging
	emit_signal("sound_played", sound_name)
	
	# Example of how to play actual audio when files are available:
	# var player = audio_players.get(category)
	# if player:
	#     var audio_stream = load("res://audio/" + category + "/" + sound_name + ".ogg")
	#     if audio_stream:
	#         player.stream = audio_stream
	#         player.volume_db = linear_to_db(master_volume)
	#         player.play()

func play_ui_sound(sound_name: String):
	play_sound(sound_name, "ui")

func play_sfx(sound_name: String):
	play_sound(sound_name, "sfx")

func play_music(track_name: String, loop: bool = true):
	var music_player = audio_players.get("music")
	if music_player and sound_enabled:
		print("Playing music: ", track_name)
		# TODO: Implement actual music loading and playback
		emit_signal("sound_played", "music_" + track_name)

func stop_all_sounds():
	for player in audio_players.values():
		if player.is_playing():
			player.stop()

func set_master_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)
	for player in audio_players.values():
		player.volume_db = linear_to_db(master_volume)

func toggle_sound():
	sound_enabled = not sound_enabled
	if not sound_enabled:
		stop_all_sounds()

# Cyberpunk-themed sound effect mappings
func get_cyberpunk_sound(action: String) -> String:
	var sound_map = {
		"card_play": "cyber_card_activate",
		"victory": "system_victory",
		"defeat": "system_compromised",
		"error": "access_denied",
		"turn_end": "data_transfer",
		"hover": "interface_hover",
		"click": "terminal_click",
		"damage": "neural_damage",
		"heal": "system_repair",
		"shield": "firewall_up",
		"buff": "enhancement_active",
		"debuff": "virus_detected"
	}
	
	return sound_map.get(action, action)