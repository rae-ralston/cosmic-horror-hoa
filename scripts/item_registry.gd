extends Node

var by_id: Dictionary = {}

func register(item: Item) -> void:
	by_id[item.item_id] = item

func get_item(id: String) -> Item:
	return by_id.get(id)

func unregister(id: String) -> void:
	by_id.erase(id)
