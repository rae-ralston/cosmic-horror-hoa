extends Node

@export var shove_distance: float = 24.0

func run_once() -> void:
	var occupied_zones: Array[PlacementZone] = []
	
	for zone_id in ZoneRegistry.by_id.keys():
		var z: PlacementZone = ZoneRegistry.by_id[zone_id]
		if z and z.occupied_item_id != "":
			occupied_zones.append(z)
	
	if occupied_zones.is_empty():
		print("[SAB] No occupied zones to sabotage.")
		return
	
	var zone := occupied_zones[randi() % occupied_zones.size()]
	var item_id := zone.occupied_item_id
	var item: Item = ItemRegistry.get_item(item_id)
	
	print("[SAB] Target zone=%s item_id=%s item=%s" % [zone.name, item_id, str(item)])
	
	zone.clear_occupancy()

	if item:
		item.state.erase("placed_zone")
		item.global_position = zone.get_snap_global_position() + Vector2(shove_distance, 0)
		print("[SAB] Shoved item to:", item.global_position)
	
	CitationsManager.evaluate_all()
