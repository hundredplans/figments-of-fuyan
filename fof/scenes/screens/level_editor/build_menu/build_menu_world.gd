extends Node3D
@onready var Items = $Items
var items: Array = []
var ipos: int = 0
var jj: Array = [Vector4.ZERO, Vector4.ZERO]

func clear_items() -> void:
	for child in Items.get_children(): child.queue_free()
	items.clear()
	ipos = 0
			
func on_load_sliders() -> void:
	var n: int = 0
	var pp: int = 0
	for i in range(8):
		var l = preload("res://scenes/ui_general/scale_button/scale_button.tscn").instantiate()
		get_parent().get_parent().get_parent().get_parent().get_parent().add_child.call_deferred(l)
		l.min_max = Vector2(-200, 200)
		l.position += Vector2(20, i * 100 + 200)
		l.item_selected.connect((func(x, p): x = x * 0.2; jj[n][p] = x; ipos = 0; for k in range(2): for j in range(6):
			if !(j == 0 and k == 0):
				position_item(Vector2(j * 200, k * 150))).bind(pp))
		pp += 1
		if i == 3:
			n = 1
			pp = 0
			
func add_item(path: String) -> void:
	var item: Node3D = load(path).instantiate()
	Items.add_child(item)
	items.append(item)
	
func replace_item(i: int, path: String) -> void:
	if i < items.size():
		var j: int = 0
		for child in Items.get_children():
			if !child.is_queued_for_deletion():
				if i == j:
					var cindex: int = child.get_index()
					var pos: Vector3 = child.position
					child.queue_free()
					var item: Node3D = load(path).instantiate()
					item.position = pos
					Items.add_child(item)
					Items.move_child(item, cindex)
					items[i] = item
					break
				j += 1
	
func position_item(pos: Vector2i) -> void:
	if pos.y == 150: items[ipos].position = Vector3(_remap(pos.x, -22.6, 14.6), 0, _remap(pos.x, 14.6, -22.6))
	else: items[ipos].position = Vector3(_remap(pos.x, -30.8, 6.6), 0, _remap(pos.x, 6.6, -30.8))
	ipos += 1
	
func _remap(pos: float, n: float, m: float) -> float:
	return remap(pos, 0, 1000, n, m)
