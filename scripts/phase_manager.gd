extends Node

# Phase enum
enum Phase { NORMAL, WARNING, DANGER }

signal phase_changed(new_phase: Phase)
signal warning_started()
signal danger_started()
signal normal_resumed()

# Music timing: 120 BPM = 2 seconds per bar (4 beats per bar)
const SECONDS_PER_BAR = 2.0

@export var normal_bars := 44
@export var warning_bars := 8
@export var danger_bars := 12

@export var test_mode: bool = true
@export var test_normal_bars := 5
@export var test_warning_bars := 2
@export var test_danger_bars := 3

@export var sabotages_enabled := true
@export var sabotage_on_danger_start := true

var current_phase: Phase = Phase.NORMAL
var phase_timer: Timer = null

# Actual durations in seconds (calculated from bars)
var normal_duration: float
var warning_duration: float
var danger_duration: float

func _ready() -> void:
	# Calculate durations from bars (use test bars if test mode is enabled)
	if test_mode:
		normal_duration = test_normal_bars * SECONDS_PER_BAR
		warning_duration = test_warning_bars * SECONDS_PER_BAR
		danger_duration = test_danger_bars * SECONDS_PER_BAR
	else:
		normal_duration = normal_bars * SECONDS_PER_BAR
		warning_duration = warning_bars * SECONDS_PER_BAR
		danger_duration = danger_bars * SECONDS_PER_BAR

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
