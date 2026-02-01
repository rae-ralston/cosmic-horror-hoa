extends Area2D
class_name Item

@export var item_id: String = "": set = set_item_id
@export var world_texture_override: Texture2D
@export var item_z: int = 2

var _can_pickup: bool = false
var _pulse_t: float = 0.0

var _can_pickup: bool = false
var _pulse_t: float = 0.0

func set_item_id(value: String) -> void:
	item_id = value
	if is_node_ready():
		_apply_visuals()

var state: Dictionary = {}

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
	
	_apply_visuals()

func _process(delta: float) -> void:
	if not _can_pickup:
		return

	var s := get_node_or_null("ItemSprite") as Sprite2D
	if not s:
		return

	_pulse_t += delta
	var bump := 1.0 + 0.06 * (0.5 + 0.5 * sin(_pulse_t * 6.0))  # subtle
	s.scale = Vector2(bump, bump)

	# Slight brighten (optional)
	s.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _apply_visuals() -> void:
	var item_sprite := get_node_or_null("ItemSprite") as Sprite2D
	if not item_sprite:
		return

	var texture: Texture2D = world_texture_override
	if texture == null:
		texture = Items.get_world_texture(_normalize_id(item_id))

	if texture != null:
		item_sprite.texture = texture
		item_sprite.region_enabled = false
		item_sprite.z_index = item_z
	else:
		push_warning("Item '%s' has no world texture (and no override)" % item_id)

func set_pickup_highlight(on: bool) -> void:
	_can_pickup = on
	_pulse_t = 0.0
	var s := get_node_or_null("ItemSprite") as Sprite2D
	if s:
		s.modulate = Color(1.1,1.1,1.1,1)  # reset
		s.scale = Vector2.ONE
