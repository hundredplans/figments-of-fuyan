extends Control

signal delete
signal copy
signal paste
signal bucket
signal move

signal rotate_direction
signal rotate_full

var RotateButton: Control
var rotate_item_index: int = 0
var tiles: Array

var item: int
var item_dictionary: Dictionary = {
	0: "General",
	1: "Tile",
	2: "Obj",
	3: "Wall",
	4: "Deco",
}

func _ready():
	var item_name: String = item_dictionary[item]
	$Label.text = item_name
	var tile_menu_item: Control = load("res://scenes/screens/level_editor/build_menu/tile_menu_items/tile_menu_" + item_name.to_lower() + ".tscn").instantiate()
	tile_menu_item.position = Vector2(0, 50)
	add_child(tile_menu_item)
	
	var flip_button := Button.new()
	flip_button.text = "|"
	flip_button.position = Vector2(213, 55)
	flip_button.size.y = 20
	flip_button.pressed.connect(on_flip_button_pressed.bind(tile_menu_item))
	add_child(flip_button)
	add_rotate_button(tile_menu_item)
	
	var base_pos: Array[Vector2i] = [Vector2i(10, 55), Vector2i(10, 95), Vector2(100, 55), Vector2i(233, 5), Vector2(100, 95)]
	var base_btns: Array[String] = ["Copy", "Paste","Bucket", "Delete", "Move"]
#	if tiles.size() == 1: base_btns.insert(1, "Paste")
	for i in range(base_btns.size()):
		var btn := Button.new()
		btn.text = base_btns[i]
		btn.position = base_pos[i]
		btn.size.x = 80
		btn.pressed.connect((func(b: String): get(b).emit(item)).bind(base_btns[i].to_lower()))
		tile_menu_item.add_child(btn)

func on_flip_button_pressed(tmi: Control) -> void:
	rotate_item_index = abs(rotate_item_index - 1)
	RotateButton.queue_free()
	add_rotate_button(tmi)

func add_rotate_button(tmi: Control) -> void:
	match rotate_item_index:
		0:
			var rotate_btn: Control = preload("res://scenes/ui_general/scale_button/scale_button.tscn").instantiate()
			rotate_btn.scale = Vector2(0.5, 0.5)
			rotate_btn.min_max = Vector2(1, 6)
			rotate_btn.steps = Vector2(1, 6)
			rotate_btn.label_text = "Rotate"
			rotate_btn.snap_mode = true
			rotate_btn.position = Vector2(10, 10)
			tmi.add_child(rotate_btn)
			rotate_btn.item_selected.connect(func(i: int): rotate_full.emit(item, i))
			RotateButton = rotate_btn
		1: 
			var cnt := Control.new()
			RotateButton = cnt
			tmi.add_child(cnt)
			cnt.size = Vector2(210, 50)
			
			var x: int = 25
			for i in [["<", -1], [">", 1]]:
				var btn := Button.new()
				btn.text = i[0]
				cnt.add_child(btn)
				btn.size = Vector2(50, 40)
				btn.position = Vector2(x, 5)
				btn.pressed.connect(func(): rotate_direction.emit(item, i[1]))
				x += 95
