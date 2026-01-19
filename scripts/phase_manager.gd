extends Node

# Phase enumeration
enum Phase { NORMAL, WARNING, DANGER }

# Signals for phase transitions
signal phase_changed(new_phase: Phase)
signal warning_started()
signal danger_started()
signal normal_resumed()

# Configuration
@export var normal_duration: float = 90.0
@export var warning_duration: float = 15.0
@export var danger_duration: float = 25.0

# Test mode - use shorter durations for rapid testing
@export var test_mode: bool = false
@export var test_normal_duration: float = 10.0
@export var test_warning_duration: float = 5.0
@export var test_danger_duration: float = 5.0

# State
var current_phase: Phase = Phase.NORMAL
var phase_timer: Timer = null

func _ready() -> void:
	# Use test durations if test mode is enabled
	if test_mode:
		normal_duration = test_normal_duration
		warning_duration = test_warning_duration
		danger_duration = test_danger_duration
		print("PhaseManager: Test mode enabled - using shortened durations (Normal: %ds, Warning: %ds, Danger: %ds)" % [normal_duration, warning_duration, danger_duration])

	_setup_timer()
	_start_phase(Phase.NORMAL)
	print("PhaseManager initialized - starting Normal phase")

func _setup_timer() -> void:
	phase_timer = Timer.new()
	phase_timer.one_shot = true
	phase_timer.timeout.connect(_on_phase_timer_timeout)
	add_child(phase_timer)

func _start_phase(phase: Phase) -> void:
	current_phase = phase

	# Set timer duration based on phase
	var duration: float
	match phase:
		Phase.NORMAL:
			duration = normal_duration
			print("Starting Normal phase (%d seconds)" % duration)
			normal_resumed.emit()
		Phase.WARNING:
			duration = warning_duration
			print("Starting Warning phase (%d seconds)" % duration)
			warning_started.emit()
		Phase.DANGER:
			duration = danger_duration
			print("Starting Danger phase (%d seconds)" % duration)
			danger_started.emit()

	phase_changed.emit(phase)
	phase_timer.start(duration)

func _on_phase_timer_timeout() -> void:
	# Cycle to next phase
	match current_phase:
		Phase.NORMAL:
			_start_phase(Phase.WARNING)
		Phase.WARNING:
			_start_phase(Phase.DANGER)
		Phase.DANGER:
			_start_phase(Phase.NORMAL)

func get_current_phase() -> Phase:
	return current_phase

func get_time_remaining() -> float:
	if phase_timer:
		return phase_timer.time_left
	return 0.0
