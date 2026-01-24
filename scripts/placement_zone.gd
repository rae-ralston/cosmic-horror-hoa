extends Area2D
class_name PlacementZone

@export var allowed_item_ids: Array[String] = []
@export var snap_point_path: NodePath
@export var preview_sprite_path: NodePath = "PreviewSprite"
@export var highlight_path: NodePath = "ZoneHighlight"

@onready var snap_point: Node2D = get_node_or_null(snap_point_path)
@onready var preview_sprite: Sprite2D = get_node_or_null(preview_sprite_path)
@onready var highlight: Sprite2D = get_node_or_null(highlight_path)

signal occupancy_changed(zone: PlacementZone)
var occupied_item_id: String = ""

var pulse_time := 0.0

func _process(delta: float) -> void:
	if highlight and highlight.visible:
		pulse_time += delta
		var alpha := 0.25 + 0.15 * (0.5 + 0.5 * sin(pulse_time * 6.0))
		highlight.modulate.a = alpha

func accepts(item_id: String) -> bool:
	return allowed_item_ids.is_empty() or allowed_item_ids.has(item_id)

func get_snap_global_position() -> Vector2:
	if snap_point:
		return snap_point.global_position
	
	push_warning("PlacementZone '%s' missing snap_point_path" % name)
	return global_position

func show_preview(item_id: String) -> void:
	if preview_sprite == null:
		return
	
	var texture := Items.get_world_texture(item_id)
	if texture == null:
		preview_sprite.visible = false
		return
	
	preview_sprite.texture = texture
	preview_sprite.global_position = get_snap_global_position()
	preview_sprite.visible = true

func hide_preview() -> void:
	if preview_sprite:
		preview_sprite.visible = false
		
func set_highlight (on: bool) -> void:
	if highlight == null:
		return
	
	highlight.visible = on

func is_occupied() -> bool:
	return occupied_item_id != ""

func can_place(item_id: String) -> bool:
	var ok := accepts(item_id) and not is_occupied()
	return ok

func occupy(item_id: String) -> void:
	occupied_item_id = item_id
	emit_signal("occupancy_changed", self)

func clear_occupancy() -> void:
	if occupied_item_id == "":
		return
	occupied_item_id = ""
	emit_signal("occupancy_changed", self)
