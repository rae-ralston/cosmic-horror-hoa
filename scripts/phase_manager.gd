extends Node

# Phase enum
enum Phase { NORMAL, WARNING, DANGER }

signal phase_changed(new_phase: Phase)
signal warning_started()
signal danger_started()
signal normal_resumed()

@export var normal_duration: float = 90.0
@export var warning_duration: float = 15.0
@export var danger_duration: float = 25.0

@export var test_mode: bool = true
@export var test_normal_duration: float = 10.0
@export var test_warning_duration: float = 5.0
@export var test_danger_duration: float = 5.0

@export var sabotages_enabled := true
@export var sabotage_on_danger_start := true

var current_phase: Phase = Phase.NORMAL
var phase_timer: Timer = null

func _ready() -> void:
	# Use test durations if test mode is enabled
	if test_mode:
		normal_duration = test_normal_duration
		warning_duration = test_warning_duration
		danger_duration = test_danger_duration

	_setup_timer()
	
	if not danger_started.is_connected(_on_danger_started):
		danger_started.connect(_on_danger_started)
	
	_start_phase(Phase.NORMAL)

func _on_danger_started() -> void:
	var id := CitationsManager.activate_random_citation(true)
	print("[PHASE] Danger started -> added citation:", id)
	
	if not sabotages_enabled:
		return
	if sabotage_on_danger_start:
		var reopened := CitationsManager.reopen_random_resolved(true)
		SabotageManager.run_once()
		print("[PHASE] Danger started -> reopened citation:", reopened)

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
			normal_resumed.emit()
		Phase.WARNING:
			duration = warning_duration
			warning_started.emit()
		Phase.DANGER:
			duration = danger_duration
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
