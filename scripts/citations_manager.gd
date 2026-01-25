extends Node

signal citations_changed

var citation_pool = []
var active_citations = ["flowerpot_missing"] # sorted in display order
var resolved_citations = {} #"welcome_mat_zone": false
var new_citations = {} #same shape ^
var reopened_citations = {} #same shape ^
var data = load_json("res://data/citations_by_id.json")

func load_json(path: String) -> Variant:
	var file = FileAccess.open(path, FileAccess.READ)
	
	if file == null:
		push_error("failed to load JSON at %s" % path)
		return null
	
	var stringified_data = file.get_as_text()
	var structured_data = JSON.parse_string(stringified_data)
	
	if structured_data == null:
		push_error("failed to get data from %s" % path)
		return null
	
	return structured_data

func get_active_list_for_ui() -> Array:
	var rows: Array = []
	for id in active_citations:
		if not data.has(id):
			push_warning("get_active_list_for_ui: missing definition for id '%s'" % id)
			continue
		
		var citation: Dictionary = data[id]
		#runtime state defaults
		var is_resolved := bool(resolved_citations.get(id, false))
		var is_new := bool(new_citations.get(id, false))
		var is_reopened := bool(reopened_citations.get(id, false))
		
		#definition defaults
		var title := str(citation.get("title", id))
		var detail := str(citation.get("detail"), "")
		var priority := int(citation.get("priority", 0))

		rows.append({
			"id": id,
			"title": title,
			"detail": detail,
			"is_resolved": is_resolved,
			"is_new": is_new,
			"is_reopened": is_reopened,
			"priority": priority
		})
	
	var order_index: Dictionary = {}

	for i in range(active_citations.size()):
		order_index[active_citations[i]] = i

	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a["is_resolved"] != b["is_resolved"]:
			return a["is_resolved"] == false

		if a["priority"] != b["priority"]:
			return int(a["priority"]) > int(b["priority"])

		return int(order_index.get(a["id"], 999999)) < int(order_index.get(b["id"], 999999))
	)

	return rows

func start_day():
	emit_signal("citations_changed")

func _ready() -> void:
	# wait for scene nodes to register
	await get_tree().process_frame
	
	# Connect to zone occupancy changes for all registered zones
	for zone_id in ZoneRegistry.by_id:
		var zone: PlacementZone = ZoneRegistry.by_id[zone_id]
		if zone and not zone.occupancy_changed.is_connected(_on_zone_occupancy_changed):
			zone.occupancy_changed.connect(_on_zone_occupancy_changed)
	
	evaluate_all()

func _on_zone_occupancy_changed(_zone: PlacementZone) -> void:
	evaluate_all()

func evaluate_all() -> void:
	var _changed := false
	
	for id in data.keys():
		var def: Dictionary = data[id]
		var now_resolved := _is_citation_resolved(def)
		
		var prev := bool(resolved_citations.get(id, false))
		if now_resolved != prev:
			resolved_citations[id] = now_resolved
			_changed = true
			print("[CIT] %s resolved=%s" % [id, now_resolved])
		
		if _changed:
			print("[CIT] emitting citations_changed")
			emit_signal("citations_changed")
		
		if now_resolved:
			emit_signal("citations_changed")

func _is_citation_resolved(def: Dictionary) -> bool:
	var conditions: Array = def.get("conditions", [])
	if conditions.is_empty():
		return false
	
	for cond in conditions:
		if not _eval_condition(cond):
			return false
	
	return true

func _eval_condition(cond: Dictionary) -> bool:
	var type := str(cond.get("type", ""))
	var params: Dictionary = cond.get("params", {})
	
	match type:
		"ITEM_IN_ZONE":
			var zone_id := str(params.get("zone_id", ""))
			var item_id := str(params.get("item_id", ""))
			
			var zone: PlacementZone = ZoneRegistry.get_zone(zone_id)
			if zone == null:
				push_warning("[CIT] ITEM_IN_ZONE: missing zone '%s'" % zone_id)
				return false
			
			return zone.occupied_item_id == item_id
		_:
			push_warning("[CIT] Unknown condition type '%s'" % type)
			return false
