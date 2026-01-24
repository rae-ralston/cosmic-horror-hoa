extends Area2D
class_name PlacementZone

@export var allowed_item_ids: Array[String] = []
@export var snap_point_path: NodePath

@onready var snap_point: Node2D = get_node_or_null(snap_point_path)

func accepts(item_id: String) -> bool:
	return allowed_item_ids.is_empty() or allowed_item_ids.has(item_id)

func get_snap_global_position() -> Vector2:
	if snap_point:
		return snap_point.global_position
	
	push_warning("PlacementZone '%s' missing snap_point_path" % name)
	return global_position
