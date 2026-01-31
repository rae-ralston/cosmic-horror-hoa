extends Control
class_name StartLetterUI

signal dismissed

@onready var body: RichTextLabel = $Panel/Margin/VBox/Body
@onready var continue_button: Button = $Panel/Margin/VBox/Buttons/ContinueButton

const LETTER_TEXT := """Resident,

During routine observation of your property (standard procedure), The Association has identified multiple Compliance Violations requiring your immediate attention.

Your Daily Citations are now active.

- All items must be resolved by end of day.
- Additional citations may be issued as new concerns are observed.
- Previously resolved matters may be reopened if found noncompliant.

You may notice periods of increased oversight. This is normal. Do not interfere with observation. Do not be concerned.

We appreciate your prompt cooperation. 

Regards,
Your Beloved HOA Compliance Committee
Preserving standards. Enforcing harmony.
"""
func _ready() -> void:
	print("[LETTER] ready path=", get_path())

	var dim := get_node_or_null("Dim")
	if dim and dim is Control:
		dim.mouse_filter = Control.MOUSE_FILTER_IGNORE

	body.text = LETTER_TEXT

	if continue_button == null:
		push_error("[LETTER] ContinueButton path wrong - node is null")
		return

	continue_button.mouse_filter = Control.MOUSE_FILTER_STOP
	continue_button.pressed.connect(_dismiss)
	continue_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		_dismiss()

func _dismiss() -> void:
	print("[LETTER] dismiss pressed")
	#emit_signal("dismissed")
	dismissed.emit()
	queue_free()
