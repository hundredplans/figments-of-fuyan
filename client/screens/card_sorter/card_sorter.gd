extends Node3D
var lifecycle: Array = []

func on_receive_sort_cards(cards: Array, sort: Dictionary):
	var node_master := Node3D.new(); node_master.name = sort.location; add_child(node_master)
	node_master.position.z = -0.2
	for child in cards: node_master.add_child(child); child.location = sort.location
	if sort.sort_type == "DoubleColumnsMaxEight": on_DoubleColumnsMaxEight(cards, sort)
	if sort.has("lifecycle"): lifecycle.append([sort.lifecycle, node_master])
	
func on_DoubleColumnsMaxEight(cards: Array, _sort: Dictionary) -> void:
	pass

func _process(_delta):
	for i in range(lifecycle.size()-1,-1,-1):
		if lifecycle[i][0] == null: lifecycle[i][1].queue_free(); lifecycle.remove_at(i)

