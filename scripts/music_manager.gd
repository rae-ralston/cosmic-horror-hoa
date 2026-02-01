extends Node

# Music manager singleton that handles phase-based music playback
# Integrates with PhaseManager to play appropriate music for each phase

# Testing toggle - disable music for SFX testing
@export var music_enabled: bool = true

# Audio player for continuous music
@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

# Audio player for one-shot sound effects (warning tick-tock)
@onready var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()

# Music streams for each phase
var normal_music: AudioStream
var warning_sfx: AudioStream  # One-shot tick-tock sound that plays over normal music
var danger_music: AudioStream

func _ready() -> void:
	# Add the AudioStreamPlayers as children
	add_child(music_player)
	add_child(sfx_player)

	# Load music assets
	normal_music = load("res://assets/music/main_theme_normal.ogg")
	warning_sfx = load("res://assets/music/warning_tick_tock.wav")
	danger_music = load("res://assets/music/danger_guitar_v1.ogg")

	# Configure the normal music for looping
	if normal_music is AudioStreamOggVorbis:
		normal_music.loop = true

	# Configure the danger music for looping
	if danger_music is AudioStreamOggVorbis:
		danger_music.loop = true

	# Warning SFX should not loop (one-shot sound)

	# Connect to PhaseManager signals
	if PhaseManager:
		PhaseManager.normal_resumed.connect(_on_normal_phase)
		PhaseManager.warning_started.connect(_on_warning_phase)
		PhaseManager.danger_started.connect(_on_danger_phase)

	# Start with normal music
	_play_music(normal_music)

func _input(event: InputEvent) -> void:
	"""Handle input for music toggle (M key for testing)"""
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_M:
			music_enabled = !music_enabled
			if music_enabled:
				# Resume music based on current phase
				if PhaseManager.current_phase == PhaseManager.Phase.NORMAL:
					_play_music(normal_music)
				elif PhaseManager.current_phase == PhaseManager.Phase.DANGER:
					_play_music(danger_music)
			else:
				# Stop music immediately
				music_player.stop()

func _on_normal_phase() -> void:
	"""Called when Normal phase begins"""
	_play_music(normal_music)

func _on_warning_phase() -> void:
	"""Called when Warning phase begins"""
	# Keep playing normal music, but play tick-tock SFX over it
	if warning_sfx:
		sfx_player.stream = warning_sfx
		sfx_player.play()

func _on_danger_phase() -> void:
	"""Called when Danger phase begins"""
	# Stop the warning tick-tock if it's still playing
	if sfx_player.playing and sfx_player.stream == warning_sfx:
		sfx_player.stop()

	# Switch to danger music
	_play_music(danger_music)

func _play_music(stream: AudioStream) -> void:
	"""Switches to the specified music stream"""
	if not stream:
		return

	# Check if music is disabled for testing
	if not music_enabled:
		music_player.stop()
		return

	# Only change if it's different music
	if music_player.stream != stream:
		music_player.stream = stream
		music_player.play()
	elif not music_player.playing:
		music_player.play()

func stop_music() -> void:
	"""Stops all music and SFX playback"""
	music_player.stop()
	sfx_player.stop()

func set_volume_db(volume: float) -> void:
	"""Sets music volume in decibels"""
	music_player.volume_db = volume
