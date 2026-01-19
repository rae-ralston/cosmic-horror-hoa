extends Control

@onready var rows_container: VBoxContainer = $MarginContainer/Panel/MarginContainer/Rows
const CITATION_ROW_SCENE: PackedScene = preload("res://scenes/citation_row.tscn")

func _ready() -> void:
	CitationsManager.citations_changed.connect(_on_citations_changed)
	_refresh()

func _on_citations_changed() -> void:
	print('UI received on citations changed')
	_refresh()

func _refresh() -> void:
	for child in rows_container.get_children():
		child.queue_free()
	
	var rows = CitationsManager.get_active_list_for_ui()
	print("UI refresh Rows: ", rows.size())

	if rows.is_empty():
		var empty := Label.new()
		empty.text = "(No citations yet)"
		rows_container.add_child(empty)
		return

	for row_data in rows:
		var row_node = CITATION_ROW_SCENE.instantiate()
		rows_container.add_child(row_node)
		row_node.set_data(row_data)
