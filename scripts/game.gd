extends Control
#@onready var sprite : Sprite2D = $Player_sprite
@onready var CitationsManager: Node = $CitationsManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CitationsManager.start_day()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_citations_manager_citations_changed() -> void:
	pass # Replace with function body.
