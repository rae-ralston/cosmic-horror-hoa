extends Node

signal day_started(day_length_sec: float)
signal day_tick(time_left: float)
signal day_ended(win: bool)

@export var day_length_sec: float = 180.0
@export var test_mode: bool = true
@export var test_day_length_sec: float = 30.0

var _time_left: float = 0.0
var _timer: Timer

func _ready() -> void:
	if test_mode:
		day_length_sec = test_day_length_sec
	
	_timer = Timer.new()
	_timer.one_shot = false
	_timer.wait_time = 0.25 # tick 4x/sec, smoother UI
	_timer.timeout.connect(_on_tick)
	add_child(_timer)

func start_day() -> void:
	_time_left = day_length_sec
	_timer.start()
	day_started.emit(day_length_sec)
	day_tick.emit(_time_left)

func stop_day() -> void:
	if _timer:
		_timer.stop()

func get_time_left() -> float:
	return _time_left

func _on_tick() -> void:
	_time_left -= _timer.wait_time
	if _time_left < 0:
		_time_left = 0
	
	day_tick.emit(_time_left)

	if _time_left <= 0:
		_timer.stop()
		var win := CitationsManager.are_all_active_resolved()
		day_ended.emit(win)
