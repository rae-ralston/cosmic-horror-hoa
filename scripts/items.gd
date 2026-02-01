extends Node
class_name Items

const ICON_ATLAS: Texture2D = preload("res://assets/sprites/icons/Other_Icons_Outline.png") 
const WORLD_ATLAS: Texture2D = preload("res://assets/sprites/decor/Flowers.png")

const ITEMS_BY_ID := {
	"flower_pot": {
		"id": "flower_pot",
		"display_name": "Flower Pot",
		"size_class": "small",
		"icon_region": Rect2(0, 0, 16, 16),
		"world_region": Rect2(80, 144, 16, 16),
	},
	"flamingo": {
		"id": "flamingo",
		"display_name": "Yard Flamingo",
		"icon_texture": preload("res://assets/sprites/Flamingo.png"),
		"world_texture": preload("res://assets/sprites/Flamingo.png")
	},
	"welcome_mat": {
		"id": "welcome_mat",
		"display_name": "Welcome Mat",
		"icon_texture": preload("res://assets/sprites/Rug.png"),
		"world_texture": preload("res://assets/sprites/Rug.png")
	},
	"garden_gnome": {
		"id": "garden_gnome",
		"display_name": "Garden Gnome",
		"icon_texture": preload("res://assets/sprites/Garden gnome.png"),
		"world_texture": preload("res://assets/sprites/Garden gnome.png")
	},
	"patio_chair": {
		"id": "patio_chair",
		"display_name": "Patio Chair",
		"icon_texture": preload("res://assets/sprites/Patio chair.png"),
		"world_texture": preload("res://assets/sprites/Patio chair.png")
	},
}

static func get_world_texture(item_id: String) -> Texture2D:
	var def: Dictionary = ITEMS_BY_ID.get(item_id, {})
	
	# Check for standalone texture first
	var standalone = def.get("world_texture", null)
	if standalone != null:
		return standalone
	
	# Fall back to atlas region
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
	
	# Check for standalone texture first
	var standalone = def.get("icon_texture", null)
	if standalone != null:
		return standalone
	
	# Fall back to atlas region
	var region = def.get("icon_region", null)
	if region == null:
		return null

	var texture := AtlasTexture.new()
	texture.atlas = ICON_ATLAS
	texture.region = region
	
	return texture
