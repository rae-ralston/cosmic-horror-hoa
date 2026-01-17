extends Area2D

# Item properties
@export var item_name: String = "Item"
@export var auto_pickup: bool = false  # If true, picks up automatically when player enters area
@export var pickup_distance: float = 50.0  # Distance for manual pickup
@export var item_texture: Texture2D  # The texture/sprite to show when carrying this item

signal item_picked_up(item, item_texture, item_name)

var player: Node2D = null

func _ready() -> void:
	# Add to pickup_items group for easy finding
	add_to_group("pickup_items")
	# Connect to area entered signal
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player = body
		if auto_pickup:
			pickup(body)

func _on_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player = null

func _process(_delta: float) -> void:
	# Manual pickup: check if player is nearby and pressing interact key
	if player and not auto_pickup:
		if Input.is_action_just_pressed("ui_accept"):  # Space/Enter key
			var distance = global_position.distance_to(player.global_position)
			if distance <= pickup_distance:
				pickup(player)

func pickup(picker: Node2D) -> void:
	# Get the texture from the sprite if not set manually
	if not item_texture:
		var sprite = get_node_or_null("Sprite2D")
		if sprite and sprite.texture:
			item_texture = sprite.texture
	
	# Emit signal with texture data so player can display it
	item_picked_up.emit(self, item_texture, item_name)
	# Remove the item from the scene (it's now carried by player)
	queue_free()
