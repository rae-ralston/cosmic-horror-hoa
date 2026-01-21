extends Area2D
class_name Item

@export var item_id: String = ""

var state: Dictionary = {}

func get_item_def() -> Dictionary:
	return Items.ITEMS_BY_ID.get(item_id, {})

func get_display_name() -> String:
	var def = get_item_def()
	return def.get("display_name", "")

func get_icon_texture() -> Texture2D:
	var def = get_item_def()
	return def.get("icon_texture", null)

func _ready() -> void:
	ItemRegistry.register(self)
	add_to_group("pickup_items")
