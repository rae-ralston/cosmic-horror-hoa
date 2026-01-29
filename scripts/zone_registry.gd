extends Node

signal zone_occupancy_changed(zone: PlacementZone)

var by_id: Dictionary = {}

func register(zone: PlacementZone) -> void:
	by_id[zone.name] = zone  # or zone.zone_id, see note below

func unregister(zone: PlacementZone) -> void:
	by_id.erase(zone.name)

func get_zone(id: String) -> PlacementZone:
	return by_id.get(id)

func notify_occupancy_changed(zone: PlacementZone) -> void:
	print("[ZONE] notify occupancy:", zone.name, " occupied=", zone.occupied_item_id)
	zone_occupancy_changed.emit(zone)

func reset_for_new_run() -> void:
	by_id.clear()
