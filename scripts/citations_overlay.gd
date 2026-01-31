extends Control
signal closed

var close_btn: Button
var list_root: VBoxContainer

var _pending_rows: Array = []
const _OVERLAY_FONT := "res://assets/fonts/CutiveMono-Regular.ttf"
const _CITATION_PADDING_TOP := 12
const _CITATION_PADDING_BOTTOM := 12

func _ready() -> void:
	close_btn = get_node_or_null("Panel/MarginContainer/VBoxContainer/Header/CloseButton")
	list_root = get_node_or_null("Panel/MarginContainer/VBoxContainer/Scroll/BigList")
	if list_root == null:
		list_root = _find_big_list(self)
	if list_root == null:
		push_warning("[OVERLAY] BigList not found by path or by name")
	if list_root:
		list_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		list_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if close_btn:
		close_btn.pressed.connect(_on_close)
	mouse_filter = Control.MOUSE_FILTER_STOP

	# If someone called set_citations before ready, render now
	if _pending_rows.size() > 0:
		_render(_pending_rows)
		_pending_rows.clear()

func _find_big_list(node: Node) -> VBoxContainer:
	if node.get_class() == "VBoxContainer" and node.name == "BigList":
		return node as VBoxContainer
	for c in node.get_children():
		var found := _find_big_list(c)
		if found:
			return found
	return null

func set_citations(citations: Array) -> void:
	# ALWAYS log first, even if we early return later
	print("[OVERLAY] set_citations called count=", citations.size())

	# If not ready yet, store and render in _ready()
	if not is_node_ready():
		_pending_rows = citations
		return

	_render(citations)

func _render(citations: Array) -> void:
	if list_root == null:
		return
	for c in list_root.get_children():
		c.queue_free()

	var font = load(_OVERLAY_FONT)
	# Ensure list has width so ScrollContainer shows content; use parent width if available
	var scroll := list_root.get_parent()
	if scroll and scroll is ScrollContainer:
		list_root.custom_minimum_size.x = scroll.size.x if scroll.size.x > 0 else 800

	if citations.is_empty():
		var empty := Label.new()
		empty.text = "(No citations)"
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty.add_theme_font_size_override("font_size", 18)
		empty.add_theme_color_override("font_color", Color.WHITE)
		if font:
			empty.add_theme_font_override("font", font)
		list_root.add_child(empty)
		return

	for cit in citations:
		var d := cit as Dictionary if cit is Dictionary else {}
		var is_resolved := bool(d.get("is_resolved", false))
		var is_new := bool(d.get("is_new", false))
		var is_reopened := bool(d.get("is_reopened", false))

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_top", _CITATION_PADDING_TOP)
		margin.add_theme_constant_override("margin_bottom", _CITATION_PADDING_BOTTOM)

		var wrapper := VBoxContainer.new()
		wrapper.add_theme_constant_override("separation", 6)

		# Top row: completion indicator + title + tag (like CitationListUI)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		var check := Label.new()
		check.text = "[x]" if is_resolved else "[ ]"
		check.add_theme_font_size_override("font_size", 22)
		check.add_theme_color_override("font_color", Color.WHITE)
		if font:
			check.add_theme_font_override("font", font)
		row.add_child(check)

		var right_col := VBoxContainer.new()
		right_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		right_col.add_theme_constant_override("separation", 2)

		var title := Label.new()
		title.text = str(d.get("title", "Citation"))
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title.add_theme_font_size_override("font_size", 22)
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title.custom_minimum_size.x = 200
		title.add_theme_color_override("font_color", Color.WHITE)
		if font:
			title.add_theme_font_override("font", font)
		right_col.add_child(title)

		var tag := Label.new()
		if is_new:
			tag.text = "NEW"
		elif is_reopened:
			tag.text = "REOPENED"
		else:
			tag.text = ""
		tag.add_theme_font_size_override("font_size", 14)
		tag.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
		if font:
			tag.add_theme_font_override("font", font)
		right_col.add_child(tag)

		row.add_child(right_col)
		wrapper.add_child(row)

		var detail := Label.new()
		detail.text = str(d.get("detail", ""))
		detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		detail.add_theme_font_size_override("font_size", 16)
		detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		detail.custom_minimum_size.x = 200
		detail.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		if font:
			detail.add_theme_font_override("font", font)
		wrapper.add_child(detail)

		margin.add_child(wrapper)
		list_root.add_child(margin)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_close()

func _on_close() -> void:
	visible = false
	closed.emit()
