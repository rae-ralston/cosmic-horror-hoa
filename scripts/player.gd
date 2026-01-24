extends CharacterBody2D

# Movement variables
@export var speed: float = 200.0
@export var acceleration: float = 1000.0
@export var friction: float = 1000.0

# Sprite sheet configuration
const FRAME_WIDTH: int = 64
const FRAME_HEIGHT: int = 64
const COLUMNS: int = 6

# Animation tracking
var current_direction: String = "down"
var is_moving: bool = false
var is_plowing: bool = false
var is_watering: bool = false

# Inventory system
@onready var inventory: PlayerInventory = $Inventory
@onready var world: Node2D = get_parent() # World node is the player's parent
@onready var interact_area: Area2D = $InteractArea
var nearby_items: Array[Item] = []

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var placement_area: Area2D = $PlacementDetectionArea
var nearby_zones: Array[PlacementZone] = []

# Footstep audio
@onready var footstep_player: AudioStreamPlayer = $FootstepPlayer
var footstep_timer: float = 0.0
const WALK_STEP_INTERVAL: float = 0.27  # seconds between steps

func _ready() -> void:
	#player interact area for picking up items
	interact_area.area_entered.connect(_on_interact_area_entered)
	interact_area.area_exited.connect(_on_interact_area_exited)
	
	#placement zones for solving puzzles
	placement_area.area_entered.connect(_on_placement_zone_entered)
	placement_area.area_exited.connect(_on_placement_zone_exited)
	
	# Setup animations from sprite sheet
	_setup_animations()
	
	# Hide held item initially (will be shown when item is picked up)
	var held_item_node = get_node_or_null("held_item")
	if held_item_node:
		held_item_node.visible = false
	
	# Start with idle animation
	animated_sprite.play("idle_down")
	
	# Connect animation finished signal for actions like plow
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _on_interact_area_entered(area: Area2D) -> void:
	if area is Item:
		var item := area as Item
		nearby_items.append(item)

func _on_interact_area_exited(area: Area2D) -> void:
	if area is Item:
		var item:= area as Item
		nearby_items.erase(item)

func _on_placement_zone_entered(area: Area2D) -> void:
	if area is PlacementZone:
		nearby_zones.append(area as PlacementZone)

func _on_placement_zone_exited(area: Area2D) -> void:
	if area is PlacementZone:
		nearby_zones.erase(area as PlacementZone)

func _add_anim(frames: SpriteFrames, sheet: Texture2D, animName: String, row: int, start: int, count: int, fps: float, loop: bool) -> void:
	frames.add_animation(animName)
	frames.set_animation_speed(animName, fps)
	frames.set_animation_loop(animName, loop)
	
	for i in range(count):
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2((start + i) * FRAME_WIDTH, row * FRAME_HEIGHT, FRAME_WIDTH, FRAME_HEIGHT)
		frames.add_frame(animName, atlas)

func _setup_animations() -> void:
	var sprite_sheet = preload("res://assets/sprites/main_character.png")
	var sprite_frames = SpriteFrames.new()
	
	# Remove default animation if it exists
	if sprite_frames.has_animation("default"):
		sprite_frames.remove_animation("default")
	
	# Define animations: name -> [row, start_frame, frame_count, fps, loop]
	
	var walk_animations = {
		"walk_down":  [3, 0, 6, 6.0, true],
		"walk_right": [4, 0, 6, 6.0, true],
		"walk_up":    [5, 0, 6, 6.0, true],
		"walk_left":  [4, 0, 6, 6.0, true] 
	}
	
	var idle_animations = {
		"idle_down":  [0, 0, 6, 6.0, true],
		"idle_right": [1, 0, 6, 6.0, true],
		"idle_up":    [2, 0, 6, 6.0, true],
		"idle_left":  [1, 0, 6, 6.0, true] # uses right row; flip_h handles left
	}
	
	# Plow animation (row 7)
	var plow_animations = {
		"plow_down":  [8, 0, 6, 6.0, false],  
		"plow_right": [7, 0, 6, 6.0, false], 
		"plow_up":    [9, 0, 6, 6.0, false],    
		"plow_left":  [7, 0, 6, 6.0, false]  #flips
	}
	
	# Watering animations (rows 10-12)
	# Row 10: water down, Row 11: water right, Row 12: water up
	var water_animations = {
		"water_down":  [11, 0, 6, 6.0, false],   
		"water_right": [10, 0, 6, 6.0, false],  
		"water_up":    [12, 0, 6, 6.0, false],     
		"water_left":  [10, 0, 6, 6.0, false]    #flipped
	}
	
	# Create walk animations
	for anim_name in walk_animations:
		var spec = walk_animations[anim_name]
		_add_anim(sprite_frames, sprite_sheet, anim_name, spec[0], spec[1], spec[2], spec[3], spec[4])
		
	
	# Create idle animations (single frame)
	for anim_name in idle_animations:
		var spec = idle_animations[anim_name]
		_add_anim(sprite_frames, sprite_sheet, anim_name, spec[0], spec[1], spec[2], spec[3], spec[4])
	
	# Create plow animations (non-looping action)
	for anim_name in plow_animations:
		var spec = plow_animations[anim_name]
		_add_anim(sprite_frames, sprite_sheet, anim_name, spec[0], spec[1], spec[2], spec[3], spec[4])
	
	# Create watering animations (non-looping action)
	for anim_name in water_animations:
		var spec = water_animations[anim_name]
		_add_anim(sprite_frames, sprite_sheet, anim_name, spec[0], spec[1], spec[2], spec[3], spec[4])
	
	animated_sprite.sprite_frames = sprite_frames

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_try_interact()

func _try_interact() -> void:
	# If holding something, drop it
	# if drop zone is close put it there
	if inventory.has_item():
		var held := inventory.get_held_item()
		var drop_pos := _get_drop_position()
		var zone := _get_best_zone_for(held.item_id)
		
		if zone != null:
			drop_pos = zone.get_snap_global_position()
			inventory.drop(drop_pos, get_parent())
			held.state["placed_zone"] = zone.name
		
		inventory.drop(drop_pos, world)
		return

	# Otherwise pick up nearest
	var item := _get_nearest_nearby_item()
	if item == null:
		return

	if inventory.pickup(item):
		nearby_items.erase(item)

func _get_nearest_nearby_item() -> Item:
	var best: Item = null
	var best_d := INF

	# Clean nulls, in case something was programaticaly freed
	for i in range(nearby_items.size() - 1, -1, -1):
		if nearby_items[i] == null:
			nearby_items.remove_at(i)

	for item in nearby_items:
		var d := global_position.distance_to(item.global_position)
		if d < best_d:
			best_d = d
			best = item
	
	return best

func _get_best_zone_for(item_id: String) -> PlacementZone:
	var best: PlacementZone = null
	var best_d := INF
	
	for i in range(nearby_zones.size() -1, -1, -1):
		if nearby_zones[i] == null:
			nearby_zones.remove_at(i)
	
	for z in nearby_zones:
		if not z.accepts(item_id):
			continue
		var d := global_position.distance_to(z.get_snap_global_position())
		if d < best_d:
			best_d = d
			best = z
	
	return best

func _get_drop_position() -> Vector2:
	var offset := Vector2.ZERO

	match current_direction:
		"up": offset = Vector2(0, -12)
		"down": offset = Vector2(0, 12)
		"left": offset = Vector2(-12, 0)
		"right": offset = Vector2(12, 0)
		_: offset = Vector2(0, 12)

	var drop_pos := global_position + offset
	return drop_pos

func _process_footsteps(delta: float) -> void:
	# Only play footsteps when actually moving (not during actions)
	# Check velocity instead of is_moving to account for friction/acceleration
	const MOVEMENT_THRESHOLD: float = 10.0  # pixels per second
	var actually_moving = velocity.length() > MOVEMENT_THRESHOLD

	if not actually_moving or is_plowing or is_watering:
		footstep_timer = 0.0
		return

	# Determine interval based on movement type
	var interval = WALK_STEP_INTERVAL

	# Accumulate time and play when interval reached
	footstep_timer += delta
	if footstep_timer >= interval:
		footstep_timer = 0.0
		if footstep_player:
			footstep_player.play()

func _get_current_surface() -> String:
	# MVP: Default to grass everywhere
	# Future enhancement: Detect sidewalk tiles and return "sidewalk" when applicable
	return "grass"

	# Future implementation for surface detection:
	# var environment = get_parent().get_node_or_null("Environment")
	# if not environment:
	# 	return "grass"
	#
	# var sidewalk_layer = environment.get_node_or_null("sidewalk")
	# if not sidewalk_layer:
	# 	return "grass"
	#
	# var local_pos = sidewalk_layer.to_local(global_position)
	# var cell_coords = sidewalk_layer.local_to_map(local_pos)
	# var source_id = sidewalk_layer.get_cell_source_id(cell_coords)
	#
	# if source_id != -1:
	# 	return "sidewalk"
	#
	# return "grass"

func _physics_process(delta: float) -> void:
	# Don't process movement while performing actions
	if is_plowing or is_watering:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# Check for plow action (Space to plow)
	if Input.is_action_just_pressed("plow"):
		_start_plow()
		return
	
	# Check for water action (press W to water)
	if Input.is_action_just_pressed("water"):
		_start_water()
		return
	
	# Get input direction
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	
	var current_speed = speed
	
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

	# Process footsteps
	_process_footsteps(delta)

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

func _on_animation_finished() -> void:
	# When action animation finishes, return to normal state
	if is_plowing:
		is_plowing = false
		_update_animation()
	elif is_watering:
		is_watering = false
		_update_animation()

func _update_animation() -> void:
	var anim_name: String
	
	if is_moving:
		anim_name = "walk_" + current_direction
	else:
		anim_name = "idle_" + current_direction

	animated_sprite.flip_h = (current_direction == "left")
	
	# Only change animation if different from current
	if animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)
