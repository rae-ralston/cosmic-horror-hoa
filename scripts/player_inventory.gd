extends Node
class_name PlayerInventory

signal held_item_changed (held_item) # held_item: Item or null

var held_item: Item = null

@export var held_items_parent_path: NodePath
@onready var held_items_parent: Node = get_node_or_null(held_items_parent_path)

func has_item() -> bool:
	return held_item != null

func get_held_item() -> Item:
	return held_item

func pickup(item: Item) -> bool:
	if item == null:
		return false
	
	if held_item != null:
		#TODO: implement item swapping. If you have something in inventory you can't pick anything else up
		return false 
	
	held_item = item
	
	# moves under held parent in tree
	if held_items_parent:
		item.reparent(held_items_parent, true)
	
	#makes non-interactable while held
	_set_item_held_state(item, true)
	
	emit_signal("held_item_changed", held_item)
	return true

func drop(drop_global_pos: Vector2, world_parent: Node = null) -> bool:
	if held_item == null:
		return false
	
	var item := held_item
	held_item = null
	
	# Reparent/give item back to world instead of player
	if world_parent:
		item.reparent(world_parent)
		# IMPORTANT: After reparenting, we need to set global_position
		# because reparenting can change the global position calculation
		item.global_position = drop_global_pos
	else:
		# If no world_parent, just set position relative to current parent
		item.global_position = drop_global_pos
	
	# In player_inventory.gd, in the drop() function, after _set_item_held_state:
	_set_item_held_state(item, false)
	return true

func _set_item_held_state(item: Item, is_held: bool) -> void:
	item.visible = not is_held
	#disables item collisions when held
	item.monitoring = not is_held
	item.monitorable = not is_held
	
	#disables children collision shapes when held
	var col := item.get_node_or_null("CollisionShape2D")
	if col:
		col.disabled = is_held

func get_item_def() -> Dictionary:
	if held_item == null:
		return {}
	return held_item.get_item_def()

func get_held_item_name() -> String:
	if held_item == null:
		return ""
	return held_item.get_display_name()

func get_held_item_icon() -> Texture2D:
	if held_item == null:
		return null
	return held_item.get_icon_texture()
