extends Area2D
class_name Item

@export var item_id: String = ""


var state: Dictionary = {}

#func _normalize_id(raw: String) -> String:
	#var key := raw.strip_edges()
	#key = key.trim_prefix("\"").trim_suffix("\"")
	#key = key.trim_prefix("'").trim_suffix("'")
	#return key

func _normalize_id(raw: String) -> String:
	var key := raw.strip_edges()
	key = key.trim_prefix("\"").trim_suffix("\"")
	key = key.trim_prefix("'").trim_suffix("'")
	return key

func get_item_def() -> Dictionary:
	var key := _normalize_id(item_id)
	var def: Dictionary = Items.ITEMS_BY_ID.get(key, {})
	if def.is_empty():
		push_warning("Missing item def for '%s'. Known: %s" % [key, Items.ITEMS_BY_ID.keys()])
	
	return def

func get_display_name() -> String:
	var def = get_item_def()
	return str(def.get("display_name", _normalize_id(item_id)))

func get_icon_texture() -> Texture2D:
	return Items.get_icon_texture(item_id)

func _ready() -> void:
	ItemRegistry.register(self)
	add_to_group("pickup_items")
