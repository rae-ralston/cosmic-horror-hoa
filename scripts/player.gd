extends CharacterBody2D

# Movement variables
@export var speed: float = 200.0
@export var acceleration: float = 1000.0
@export var friction: float = 1000.0

# Inventory system
var inventory: Array[String] = []
var held_item: Texture2D = null  # Currently held/carried item texture
var held_item_name: String = ""

func _ready() -> void:
	# Hide held item initially (will be shown when item is picked up)
	var held_item_node = get_node_or_null("held_item")
	if held_item_node:
		held_item_node.visible = false
	# Connect to pickup items in the scene
	_connect_to_pickup_items()

func _connect_to_pickup_items() -> void:
	# Wait a frame for all nodes to be ready
	await get_tree().process_frame
	# Find all pickup items in the scene and connect to their signals
	var pickup_items = get_tree().get_nodes_in_group("pickup_items")
	for item in pickup_items:
		if item.has_signal("item_picked_up"):
			if not item.item_picked_up.is_connected(_on_item_picked_up):
				item.item_picked_up.connect(_on_item_picked_up)

func _physics_process(delta: float) -> void:
	# Get input direction
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	
	# Normalize diagonal movement
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		# Apply acceleration
		velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
	else:
		# Apply friction when no input
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	# Move the character
	move_and_slide()

func _on_item_picked_up(item: Area2D, item_texture: Texture2D, item_name: String) -> void:
	# If already holding something, add it to inventory first
	if held_item_name != "":
		inventory.append(held_item_name)
		print("Dropped from hand to inventory: ", held_item_name)
	
	# Pick up new item and display it
	held_item = item_texture
	held_item_name = item_name
	
	# Show the held item sprite
	var held_item_node = get_node_or_null("held_item")
	if held_item_node and held_item:
		held_item_node.texture = held_item
		held_item_node.visible = true
	
	inventory.append(item_name)
	print("Picked up and now carrying: ", item_name)
	print("Inventory: ", inventory)

func drop_held_item() -> void:
	# Drop the currently held item back to inventory
	if held_item_name != "":
		print("Dropped: ", held_item_name)
		held_item = null
		held_item_name = ""
		var held_item_node = get_node_or_null("held_item")
		if held_item_node:
			held_item_node.visible = false

func get_inventory() -> Array[String]:
	return inventory

func get_held_item() -> String:
	return held_item_name
