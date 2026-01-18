extends Control

@onready var rows_container: VBoxContainer = $MarginContainer/Panel/MarginContainer/Rows

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
	# TODO: clear + rebuild rows_container from rows

	if rows.is_empty():
		var empty := Label.new()
		empty.text = "(No citations yet)"
		rows_container.add_child(empty)
		return

	for row in rows:
		var line := Label.new()
		line.text = ("[x] " if row["is_resolved"] else "[ ] ") + str(row["title"])
		rows_container.add_child(line)
		

func _process(delta: float) -> void:
	pass
