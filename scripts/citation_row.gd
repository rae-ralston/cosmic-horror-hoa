extends HBoxContainer

var check: Label
var title: Label
var tag: Label

func _ready() -> void:
	# Try to get nodes from scene, or create them programmatically
	var left_col = get_node_or_null("LeftColumn")
	var right_col = get_node_or_null("RightColumn")
	
	if not left_col or not right_col:
		# Scene nodes not found - create them programmatically
		_create_nodes()
	else:
		check = left_col.get_node("Check")
		title = right_col.get_node("Title")
		tag = right_col.get_node("Tag")

func _create_nodes() -> void:
	# Load font to match scene file
	var font = load("res://assets/fonts/CutiveMono-Regular.ttf")
	
	# Create LeftColumn with Check
	var left_col = VBoxContainer.new()
	left_col.name = "LeftColumn"
	add_child(left_col)
	
	check = Label.new()
	check.name = "Check"
	check.text = "[ ]"
	if font:
		check.add_theme_font_override("font", font)
	left_col.add_child(check)
	
	# Create RightColumn with Title and Tag
	var right_col = VBoxContainer.new()
	right_col.name = "RightColumn"
	add_child(right_col)
	
	title = Label.new()
	title.name = "Title"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.custom_minimum_size.x = 200
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.text = "Title"
	if font:
		title.add_theme_font_override("font", font)
	right_col.add_child(title)
	
	tag = Label.new()
	tag.name = "Tag"
	tag.text = ""
	if font:
		tag.add_theme_font_override("font", font)
	right_col.add_child(tag)

func set_data(row: Dictionary) -> void:
	check.text = "[x]" if row["is_resolved"] else "[ ]"
	title.text = str(row["title"])
	
	if tag:
		if row.get("is_new", false):
			tag.text = "NEW"
		elif row.get("is_reopened", false):
			tag.text = "REOPENED"
		else:
			tag.text = ""
