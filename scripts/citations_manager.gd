extends Node

signal citations_changed

#TODO generate active_citations, resolved_citations, new_citation
var citation_pool = []
var active_citations = ["trash_align_north", "welcome_mat_zone"] # sorted in display order
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
	pass
