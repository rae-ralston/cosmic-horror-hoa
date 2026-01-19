extends CharacterBody2D

# Movement variables
@export var speed: float = 200.0
@export var crawl_speed: float = 80.0
@export var acceleration: float = 1000.0
@export var friction: float = 1000.0

# Sprite sheet configuration
const FRAME_WIDTH: int = 64
const FRAME_HEIGHT: int = 64
const COLUMNS: int = 6

# Animation tracking
var current_direction: String = "down"
var is_moving: bool = false
var is_crawling: bool = false
var is_plowing: bool = false
var is_watering: bool = false
var is_digging: bool = false

# Inventory system
var inventory: Array[String] = []
var held_item: Texture2D = null  # Currently held/carried item texture
var held_item_name: String = ""

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Setup animations from sprite sheet
	_setup_animations()
	
	# Hide held item initially (will be shown when item is picked up)
	var held_item_node = get_node_or_null("held_item")
	if held_item_node:
		held_item_node.visible = false
	# Connect to pickup items in the scene
	_connect_to_pickup_items()
	
	# Start with idle animation
	animated_sprite.play("idle_down")
	
	# Connect animation finished signal for actions like plow
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _setup_animations() -> void:
	var sprite_sheet = preload("res://assets/sprites/main_character.png")
	var sprite_frames = SpriteFrames.new()
	
	# Remove default animation if it exists
	if sprite_frames.has_animation("default"):
		sprite_frames.remove_animation("default")
	
	# Define animations: name -> [row, frame_count]
	# Based on the sprite sheet layout:
	# Row 0: Walk down (6 frames)
	# Row 1: Walk right (6 frames)  
	# Row 2: Walk up (6 frames)
	# Row 5: Walk left (6 frames)
	var walk_animations = {
		"walk_down": [0, 6],
		"walk_right": [1, 6],
		"walk_up": [2, 6],
		"walk_left": [5, 6]
	}
	
	# Idle animations use first frame of each walk direction
	var idle_animations = {
		"idle_down": [0, 0],   # Row 0, frame 0
		"idle_right": [1, 0],  # Row 1, frame 0
		"idle_up": [2, 0],     # Row 2, frame 0
		"idle_left": [5, 0]    # Row 5, frame 0
	}
	
	# Crawl animations (row 6 based on sprite sheet)
	var crawl_animations = {
		"crawl_down": [6, 4],    # Row 6, 4 frames
		"crawl_right": [6, 4],   # Row 6, 4 frames
		"crawl_up": [6, 4],      # Row 6, 4 frames
		"crawl_left": [6, 4]     # Row 6, 4 frames (flipped)
	}
	
	# Crawl idle animations
	var crawl_idle_animations = {
		"crawl_idle_down": [6, 0],
		"crawl_idle_right": [6, 0],
		"crawl_idle_up": [6, 0],
		"crawl_idle_left": [6, 0]
	}
	
	# Plow animation (row 7)
	var plow_animations = {
		"plow_down": [7, 6],    # Row 7, 6 frames
		"plow_right": [7, 6],   # Row 7, 6 frames
		"plow_up": [7, 6],      # Row 7, 6 frames
		"plow_left": [7, 6]     # Row 7, 6 frames (flipped)
	}
	
	# Watering animations (rows 10-12)
	# Row 10: water down, Row 11: water right, Row 12: water up
	var water_animations = {
		"water_down": [10, 6],   # Row 10, 6 frames
		"water_right": [11, 6],  # Row 11, 6 frames
		"water_up": [12, 6],     # Row 12, 6 frames
		"water_left": [11, 6]    # Row 11, 6 frames (flipped for left)
	}
	
	# Digging animations (rows 8-9)
	# Row 8: dig down/right, Row 9: dig up
	var dig_animations = {
		"dig_down": [8, 6],     # Row 8, 6 frames
		"dig_right": [8, 6],    # Row 8, 6 frames
		"dig_up": [9, 6],       # Row 9, 6 frames
		"dig_left": [8, 6]      # Row 8, 6 frames (flipped for left)
	}
	
	# Create walk animations
	for anim_name in walk_animations:
		var row = walk_animations[anim_name][0]
		var frame_count = walk_animations[anim_name][1]
		
		sprite_frames.add_animation(anim_name)
		sprite_frames.set_animation_speed(anim_name, 10.0)
		sprite_frames.set_animation_loop(anim_name, true)
		
		for i in range(frame_count):
			var atlas_texture = AtlasTexture.new()
			atlas_texture.atlas = sprite_sheet
			atlas_texture.region = Rect2(i * FRAME_WIDTH, row * FRAME_HEIGHT, FRAME_WIDTH, FRAME_HEIGHT)
			sprite_frames.add_frame(anim_name, atlas_texture)
	
	# Create idle animations (single frame)
	for anim_name in idle_animations:
		var row = idle_animations[anim_name][0]
		var frame = idle_animations[anim_name][1]
		
		sprite_frames.add_animation(anim_name)
		sprite_frames.set_animation_speed(anim_name, 5.0)
		sprite_frames.set_animation_loop(anim_name, true)
		
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = sprite_sheet
		atlas_texture.region = Rect2(frame * FRAME_WIDTH, row * FRAME_HEIGHT, FRAME_WIDTH, FRAME_HEIGHT)
		sprite_frames.add_frame(anim_name, atlas_texture)
	
	# Create crawl animations
	for anim_name in crawl_animations:
		var row = crawl_animations[anim_name][0]
		var frame_count = crawl_animations[anim_name][1]
		
		sprite_frames.add_animation(anim_name)
		sprite_frames.set_animation_speed(anim_name, 8.0)
		sprite_frames.set_animation_loop(anim_name, true)
		
		for i in range(frame_count):
			var atlas_texture = AtlasTexture.new()
			atlas_texture.atlas = sprite_sheet
			atlas_texture.region = Rect2(i * FRAME_WIDTH, row * FRAME_HEIGHT, FRAME_WIDTH, FRAME_HEIGHT)
			sprite_frames.add_frame(anim_name, atlas_texture)
	
	# Create crawl idle animations (single frame)
	for anim_name in crawl_idle_animations:
		var row = crawl_idle_animations[anim_name][0]
		var frame = crawl_idle_animations[anim_name][1]
		
		sprite_frames.add_animation(anim_name)
		sprite_frames.set_animation_speed(anim_name, 5.0)
		sprite_frames.set_animation_loop(anim_name, true)
		
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = sprite_sheet
		atlas_texture.region = Rect2(frame * FRAME_WIDTH, row * FRAME_HEIGHT, FRAME_WIDTH, FRAME_HEIGHT)
		sprite_frames.add_frame(anim_name, atlas_texture)
	
	# Create plow animations (non-looping action)
	for anim_name in plow_animations:
		var row = plow_animations[anim_name][0]
		var frame_count = plow_animations[anim_name][1]
		
		sprite_frames.add_animation(anim_name)
		sprite_frames.set_animation_speed(anim_name, 10.0)
		sprite_frames.set_animation_loop(anim_name, false)  # Don't loop - play once
		
		for i in range(frame_count):
			var atlas_texture = AtlasTexture.new()
			atlas_texture.atlas = sprite_sheet
			atlas_texture.region = Rect2(i * FRAME_WIDTH, row * FRAME_HEIGHT, FRAME_WIDTH, FRAME_HEIGHT)
			sprite_frames.add_frame(anim_name, atlas_texture)
	
	# Create watering animations (non-looping action)
	for anim_name in water_animations:
		var row = water_animations[anim_name][0]
		var frame_count = water_animations[anim_name][1]
		
		sprite_frames.add_animation(anim_name)
		sprite_frames.set_animation_speed(anim_name, 8.0)
		sprite_frames.set_animation_loop(anim_name, false)  # Don't loop - play once
		
		for i in range(frame_count):
			var atlas_texture = AtlasTexture.new()
			atlas_texture.atlas = sprite_sheet
			atlas_texture.region = Rect2(i * FRAME_WIDTH, row * FRAME_HEIGHT, FRAME_WIDTH, FRAME_HEIGHT)
			sprite_frames.add_frame(anim_name, atlas_texture)
	
	# Create digging animations (non-looping action)
	for anim_name in dig_animations:
		var row = dig_animations[anim_name][0]
		var frame_count = dig_animations[anim_name][1]
		
		sprite_frames.add_animation(anim_name)
		sprite_frames.set_animation_speed(anim_name, 10.0)
		sprite_frames.set_animation_loop(anim_name, false)  # Don't loop - play once
		
		for i in range(frame_count):
			var atlas_texture = AtlasTexture.new()
			atlas_texture.atlas = sprite_sheet
			atlas_texture.region = Rect2(i * FRAME_WIDTH, row * FRAME_HEIGHT, FRAME_WIDTH, FRAME_HEIGHT)
			sprite_frames.add_frame(anim_name, atlas_texture)
	
	animated_sprite.sprite_frames = sprite_frames

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
	# Don't process movement while performing actions
	if is_plowing or is_watering or is_digging:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# Check for plow action (press E or Space to plow)
	if Input.is_action_just_pressed("plow"):
		_start_plow()
		return
	
	# Check for water action (press W to water)
	if Input.is_action_just_pressed("water"):
		_start_water()
		return
	
	# Check for dig action (press D to dig)
	if Input.is_action_just_pressed("dig"):
		_start_dig()
		return
	
	# Check if crawling (hold Shift or Ctrl to crawl)
	is_crawling = Input.is_action_pressed("crawl")
	
	# Get input direction
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	
	# Determine current speed based on crawling state
	var current_speed = crawl_speed if is_crawling else speed
	
	# Normalize diagonal movement
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		# Apply acceleration
		velocity = velocity.move_toward(input_vector * current_speed, acceleration * delta)
		is_moving = true
		
		# Determine direction based on input (prioritize horizontal)
		if abs(input_vector.x) > abs(input_vector.y):
			if input_vector.x > 0:
				current_direction = "right"
			else:
				current_direction = "left"
		else:
			if input_vector.y > 0:
				current_direction = "down"
			else:
				current_direction = "up"
	else:
		# Apply friction when no input
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		is_moving = false
	
	# Update animation
	_update_animation()
	
	# Move the character
	move_and_slide()

func _start_plow() -> void:
	is_plowing = true
	var anim_name = "plow_" + current_direction
	animated_sprite.flip_h = (current_direction == "left")
	animated_sprite.play(anim_name)

func _start_water() -> void:
	is_watering = true
	var anim_name = "water_" + current_direction
	animated_sprite.flip_h = (current_direction == "left")
	animated_sprite.play(anim_name)

func _start_dig() -> void:
	is_digging = true
	var anim_name = "dig_" + current_direction
	animated_sprite.flip_h = (current_direction == "left")
	animated_sprite.play(anim_name)

func _on_animation_finished() -> void:
	# When action animation finishes, return to normal state
	if is_plowing:
		is_plowing = false
		_update_animation()
	elif is_watering:
		is_watering = false
		_update_animation()
	elif is_digging:
		is_digging = false
		_update_animation()

func _update_animation() -> void:
	var anim_name: String
	
	if is_crawling:
		if is_moving:
			anim_name = "crawl_" + current_direction
		else:
			anim_name = "crawl_idle_" + current_direction
		# Flip sprite for left crawl (since we use same row as right)
		animated_sprite.flip_h = (current_direction == "left")
	else:
		if is_moving:
			anim_name = "walk_" + current_direction
		else:
			anim_name = "idle_" + current_direction
		# Reset flip for normal walking
		animated_sprite.flip_h = false
	
	# Only change animation if different from current
	if animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)

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
