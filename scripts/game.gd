extends Control
class_name World

const START_LETTER_SCENE := preload("res://scenes/start_letter_ui.tscn")

@onready var CitationsManager: Node = $CitationsManager
@onready var Player: Node = $GameView/GameViewport/World/player
@onready var danger_overlay: ColorRect = $HUD/DangerOverlay/DangerColor
var day_manager: DayManager = DayManager

var game_over := false

# Tween for smooth overlay transitions
var overlay_tween: Tween = null

# Overlay configuration constants
const DANGER_OVERLAY_ALPHA = 0.35
const FADE_DURATION = 0.5

func _ready() -> void:
	day_manager.day_ended.connect(_on_day_ended)

	PhaseManager.phase_changed.connect(_on_phase_changed)
	PhaseManager.danger_started.connect(_on_danger_started)
	PhaseManager.normal_resumed.connect(_on_normal_resumed)
	PhaseManager.warning_started.connect(_on_warning_started)

	# Initialize overlay as transparent
	if danger_overlay:
		danger_overlay.modulate.a = 0.0

	# Show intro letter FIRST, then start day on dismiss
	show_start_letter()

func _on_phase_changed(_new_phase: int) -> void:
	pass

func _on_citations_manager_citations_changed() -> void:
	pass

func _on_warning_started() -> void:
	pass

func _on_danger_started() -> void:
	_fade_overlay_in()

func _on_normal_resumed() -> void:
	_fade_overlay_out()

func _fade_overlay_in() -> void:
	if not danger_overlay:
		return

	# Kill existing tween if any
	if overlay_tween:
		overlay_tween.kill()

	# Create new tween
	overlay_tween = create_tween()
	overlay_tween.set_ease(Tween.EASE_IN_OUT)
	overlay_tween.set_trans(Tween.TRANS_CUBIC)

	# Fade overlay to danger opacity (red tint)
	overlay_tween.tween_property(danger_overlay, "modulate:a", DANGER_OVERLAY_ALPHA, FADE_DURATION)

func _fade_overlay_out() -> void:
	if not danger_overlay:
		return

	# Kill existing tween if any
	if overlay_tween:
		overlay_tween.kill()

	# Create new tween
	overlay_tween = create_tween()
	overlay_tween.set_ease(Tween.EASE_IN_OUT)
	overlay_tween.set_trans(Tween.TRANS_CUBIC)

	# Fade overlay to fully transparent
	overlay_tween.tween_property(danger_overlay, "modulate:a", 0.0, FADE_DURATION)
	
func _on_day_ended(win: bool) -> void:
	game_over = true
	print("[DAY] ended win=", win)
	#$EndScreen.show_result(win)


var _start_letter_showing := false

func show_start_letter() -> void:
	if _start_letter_showing:
		return

	_start_letter_showing = true

	var ui := $HUD.get_node_or_null("StartLetterUI")
	if ui == null:
		ui = START_LETTER_SCENE.instantiate()
		ui.name = "StartLetterUI"
		$HUD.add_child(ui)

	# Always ensure connection exists
	if not ui.dismissed.is_connected(_on_start_letter_dismissed):
		ui.dismissed.connect(_on_start_letter_dismissed)

	Player.set_process(false)
	Player.set_physics_process(false)

	print("[WORLD] start letter active. connected=", ui.dismissed.is_connected(_on_start_letter_dismissed))

func _on_start_letter_dismissed() -> void:
	_start_letter_showing = false
	call_deferred("_begin_run")

func _begin_run() -> void:
	Player.set_process(true)
	Player.set_physics_process(true)
	day_manager.start_day()
	CitationsManager.when_day_starts()
