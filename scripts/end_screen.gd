extends Control
class_name EndScreen

@onready var title_label: Label = $Panel/VBox/Title
@onready var subtitle_label: Label = $Panel/VBox/Subtitle
@onready var restart_button: Button = $Panel/VBox/Buttons/RestartButton
@onready var quit_button: Button = $Panel/VBox/Buttons/QuitButton

var _wired := false

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	if not DayManager.day_ended.is_connected(_on_day_ended):
		DayManager.day_ended.connect(_on_day_ended)

func _wire_buttons_once() -> void:
	if _wired:
		return
	_wired = true

	print("[END] wiring buttons path=", get_path(), " restart_null=", restart_button == null)

	if restart_button and not restart_button.pressed.is_connected(_on_restart_pressed):
		restart_button.pressed.connect(_on_restart_pressed)

	if quit_button and not quit_button.pressed.is_connected(_on_quit_pressed):
		quit_button.pressed.connect(_on_quit_pressed)

func show_result(win: bool) -> void:
	_wire_buttons_once()

	print("[END] SHOW path=", get_path(), " time_scale=", Engine.time_scale)

	visible = true

	if win:
		title_label.text = "CITATIONS COMPLETE"
		subtitle_label.text = "You survived the HOA. For now."
	else:
		title_label.text = "CITED INTO OBLIVION"
		subtitle_label.text = "You've been overcome with insanity and will never be the same."

	if restart_button:
		restart_button.grab_focus()

func _on_day_ended(win: bool) -> void:
	show_result(win)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		_on_restart_pressed()

func _on_restart_pressed() -> void:
	print("[END] restart pressed")
	visible = false
	call_deferred("_do_restart")

func _do_restart() -> void:
	print("[END] do restart")
	Engine.time_scale = 1.0

	DayManager.reset_for_new_run()
	PhaseManager.reset_for_new_run()
	CitationsManager.reset_for_new_run()
	ZoneRegistry.reset_for_new_run()
	ItemRegistry.reset_for_new_run()
	get_tree().reload_current_scene()
	Input.flush_buffered_events()

func _on_quit_pressed() -> void:
	print("[END] quit pressed")
	get_tree().quit()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("[END] EndScreen got click: ", event.button_index, " at ", event.position)
