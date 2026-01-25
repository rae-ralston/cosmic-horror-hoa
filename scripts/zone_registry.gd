extends Node

var by_id: Dictionary = {} #zone_id -> PlacementZone

func register(zone: PlacementZone) -> void:
	by_id[zone.name] = zone

func get_zone(zone_id: String) -> PlacementZone:
	return by_id.get(zone_id)

func unregister(zone: PlacementZone) -> void:
	if by_id.get(zone.name) == zone:
		by_id.erase(zone.name)
