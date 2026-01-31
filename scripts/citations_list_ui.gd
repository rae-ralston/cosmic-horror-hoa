extends Control

@onready var rows_container: VBoxContainer = $MarginContainer/Panel/MarginContainer/Rows
@onready var expand_button: Button = $ExpandButton
const CITATION_ROW_SCENE: PackedScene = preload("res://scenes/citation_row.tscn")
const CITATIONS_OVERLAY_SCENE := preload("res://scenes/citations_overlay.tscn")

func _ready() -> void:
	print("[CIT UI] ready path=", get_path())
	await get_tree().process_frame

	if expand_button:
		if not expand_button.pressed.is_connected(_on_citations_expand_pressed):
			expand_button.pressed.connect(_on_citations_expand_pressed)
	else:
		push_warning("[CIT UI] ExpandButton not found at $ExpandButton")

	if not CitationsManager.citations_changed.is_connected(_on_citations_changed):
		CitationsManager.citations_changed.connect(_on_citations_changed)

	_refresh()

func _on_citations_changed() -> void:
	_refresh()

func _refresh() -> void:
	for child in rows_container.get_children():
		child.queue_free()
	
	var rows = CitationsManager.get_active_list_for_ui()
	
	if rows.is_empty():
		var empty := Label.new()
		empty.text = "(No citations yet)"
		rows_container.add_child(empty)
		return

	for row_data in rows:
		var row_node = CITATION_ROW_SCENE.instantiate()
		rows_container.add_child(row_node)
		row_node.set_data(row_data)

func _on_citations_expand_pressed() -> void:
	print("[CIT UI] expand pressed")

	var rows := CitationsManager.get_active_list_for_ui()
	print("[CIT UI] rows=", rows.size())

	var overlay := get_node_or_null("../CitationsOverlay")
	if overlay == null:
		push_warning("[CIT UI] overlay not found at ../CitationsOverlay")
		return

	overlay.visible = true
	overlay.set_citations(rows)
