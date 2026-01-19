extends Control
@onready var CitationsManager: Node = $CitationsManager
@onready var danger_overlay: ColorRect = $DangerOverlayLayer/DangerOverlay

# Tween for smooth overlay transitions
var overlay_tween: Tween = null

func _ready() -> void:
	CitationsManager.start_day()

	# Connect to PhaseManager signals
	PhaseManager.phase_changed.connect(_on_phase_changed)
	PhaseManager.danger_started.connect(_on_danger_started)
	PhaseManager.normal_resumed.connect(_on_normal_resumed)
	PhaseManager.warning_started.connect(_on_warning_started)

	# Initialize overlay as transparent
	if danger_overlay:
		danger_overlay.modulate.a = 0.0

func _process(delta: float) -> void:
	pass

func _on_citations_manager_citations_changed() -> void:
	pass

func _on_phase_changed(new_phase: int) -> void:
	print("Phase changed to: %d" % new_phase)

func _on_warning_started() -> void:
	print("Warning phase started - Eye approaching!")

func _on_danger_started() -> void:
	print("Danger phase started - Eye is watching!")
	_fade_overlay_in()

func _on_normal_resumed() -> void:
	print("Normal phase resumed - Eye has left")
	_fade_overlay_out()

func _fade_overlay_in() -> void:
	if not danger_overlay:
		print("ERROR: danger_overlay is null!")
		return

	print("Fade in - overlay exists: ", danger_overlay != null)
	print("Fade in - overlay visible: ", danger_overlay.visible)
	print("Fade in - overlay size: ", danger_overlay.size)
	print("Fade in - overlay position: ", danger_overlay.position)
	print("Fade in - overlay modulate before: ", danger_overlay.modulate)

	# Kill existing tween if any
	if overlay_tween:
		overlay_tween.kill()

	# Create new tween
	overlay_tween = create_tween()
	overlay_tween.set_ease(Tween.EASE_IN_OUT)
	overlay_tween.set_trans(Tween.TRANS_CUBIC)

	# Fade overlay to 35% opacity (red tint)
	overlay_tween.tween_property(danger_overlay, "modulate:a", 0.35, 0.5)
	print("Fade in - tween created, target alpha: 0.35")

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
	overlay_tween.tween_property(danger_overlay, "modulate:a", 0.0, 0.5)
