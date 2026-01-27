extends Node

# Music manager singleton that handles phase-based music playback
# Integrates with PhaseManager to play appropriate music for each phase

# Audio player for music
@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

# Music streams for each phase
var normal_music: AudioStream
var warning_music: AudioStream  # TODO: Add when asset is available
var danger_music: AudioStream   # TODO: Add when asset is available

func _ready() -> void:
	# Add the AudioStreamPlayer as a child
	add_child(music_player)

	# Load music assets
	normal_music = load("res://assets/music/main_theme_normal.ogg")

	# Configure the audio stream for looping
	if normal_music is AudioStreamOggVorbis:
		normal_music.loop = true

	# Connect to PhaseManager signals
	if PhaseManager:
		PhaseManager.normal_resumed.connect(_on_normal_phase)
		PhaseManager.warning_started.connect(_on_warning_phase)
		PhaseManager.danger_started.connect(_on_danger_phase)

	# Start with normal music
	_play_music(normal_music)

func _on_normal_phase() -> void:
	"""Called when Normal phase begins"""
	_play_music(normal_music)

func _on_warning_phase() -> void:
	"""Called when Warning phase begins"""
	# TODO: Implement warning music when asset is available
	# For now, continue playing normal music
	pass

func _on_danger_phase() -> void:
	"""Called when Danger phase begins"""
	# TODO: Implement danger music when asset is available
	# For now, continue playing normal music
	pass

func _play_music(stream: AudioStream) -> void:
	"""Switches to the specified music stream"""
	if not stream:
		return

	# Only change if it's different music
	if music_player.stream != stream:
		music_player.stream = stream
		music_player.play()
	elif not music_player.playing:
		music_player.play()

func stop_music() -> void:
	"""Stops music playback"""
	music_player.stop()

func set_volume_db(volume: float) -> void:
	"""Sets music volume in decibels"""
	music_player.volume_db = volume
