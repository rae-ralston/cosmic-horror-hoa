extends Node
class_name Items

const ICON_ATLAS: Texture2D = preload("res://assets/sprites/icons/Other_Icons_Outline.png") 
const WORLD_ATLAS: Texture2D = preload("res://assets/sprites/decor/Flowers.png")

const ITEMS_BY_ID := {
	"flower_pot": {
		"id": "flower_pot",
		"display_name": "Flower Pot",
		"pickupable": true,
		"size_class": "small",
		"icon_region": Rect2(0, 0, 16, 16),
		"world_region": Rect2(80, 144, 16, 16),
	},
	"yard_flamingo": {
		"id": "yard_flamingo",
		"display_name": "Yard Flamingo",
		"pickupable": true,
		"size_class": "medium",
		"icon_region": Rect2(16, 0, 16, 16),
		"world_region": Rect2(80, 128, 16, 16)
	},
	"welcome_mat": {
		"id": "welcome_mat",
		"display_name": "Welcome Mat",
		"pickupable": true,
		"size_class": "flat",
		"icon_region": Rect2(32, 0, 16, 16),
		"world_region": Rect2(80, 0, 16, 16)
	}
}

static func get_world_texture(item_id: String) -> Texture2D:
	var def: Dictionary = ITEMS_BY_ID.get(item_id, {})
	var region = def.get("world_region", null)
	if region == null:
		return null
	
	var texture := AtlasTexture.new()
	texture.atlas = WORLD_ATLAS
	texture.region = region
	
	return texture

static func get_icon_texture(item_id: String) -> Texture2D:
	var key := item_id.strip_edges()
	var def: Dictionary = ITEMS_BY_ID.get(key, {})
	var region = def.get("icon_region", null)
	if region == null:
		return null

	var texture := AtlasTexture.new()
	texture.atlas = ICON_ATLAS
	texture.region = region
	
	return texture
