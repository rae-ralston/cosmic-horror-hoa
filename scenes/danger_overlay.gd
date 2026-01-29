extends Control

@export var danger_alpha: float = 0.35
@export var fade_time: float = 0.15

@onready var danger_color: ColorRect = $DangerColor
@onready var evil_eye: AnimatedSprite2D = $EvilAnchor/EvilEye

var _tween: Tween

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	$DangerColor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	danger_color.visible = false
	_set_color_alpha(0.0)
	evil_eye.visible = false
	evil_eye.stop()
	
	PhaseManager.phase_changed.connect(_on_phase_changed)
	_on_phase_changed(PhaseManager.get_current_phase())

func _on_phase_changed(new_phase: int) -> void:
	var is_danger := (new_phase == PhaseManager.Phase.DANGER)
	
	if is_danger: 
		_enter_danger()
	else:
		_exit_danger()

func _enter_danger() -> void:
	danger_color.visible = true
	_fade_to(danger_alpha)
	
	evil_eye.visible = true
	evil_eye.play()

func _exit_danger() -> void:
	_fade_to(0.0, true)
	
	evil_eye.stop()
	evil_eye.visible = false

func _fade_to(a: float, hide_when_done: bool = false) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_set_color_alpha, danger_color.color.a, a, fade_time)
	if hide_when_done:
		_tween.tween_callback(func():
			danger_color.visible = false)

func _set_color_alpha(a: float) -> void:
	var c := danger_color.color
	c.a = clampf(a, 0.0, 1.0)
	danger_color.color = c
