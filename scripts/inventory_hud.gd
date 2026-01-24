extends Control

@export var player_path: NodePath

@onready var held_icon: TextureRect = $HeldIcon
@onready var held_label: Label = $HeldLabel

var player: Node = null
var inventory: PlayerInventory = null

func _ready() -> void:
	player = get_node_or_null(player_path)
	if player == null:
		push_error("Inventory HUD: player_path not set")
		return
	
	inventory = player.get_node_or_null("Inventory")
	if (inventory == null):
		push_error("InventoryHUD: Player has not Inventory node")
		return
	
	inventory.held_item_changed.connect(_on_held_item_changed)
	
	_on_held_item_changed(inventory.get_held_item())

func _on_held_item_changed(item) -> void:
	if (item == null):
		held_icon.texture = null
		held_icon.visible = false
		held_label.text = "hands: empty"
		return
	

	print("HUD name=", item.get_display_name())
	var icon: Texture2D = item.get_icon_texture()
	print("HUD icon=", icon)
	
	held_icon.texture = icon
	held_icon.visible = true
	held_icon.custom_minimum_size = Vector2(32, 32)
	held_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	held_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	held_icon.texture = icon
	held_icon.visible = icon != null
	held_label.text = "holding: %s" % item.get_display_name()
