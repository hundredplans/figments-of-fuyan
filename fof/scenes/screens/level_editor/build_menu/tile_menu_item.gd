extends Control

var parent: Control
var ItemButton: Control
var RotateButton: Control
var rotate_item_index: int = 0
var tiles: Array

var item: int
var item_dictionary: Dictionary = {
	0: "General",
	1: "Tile",
	2: "Obj",
	3: "Wall",
	4: "TDeco",
	5: "WDeco",
}

var item_colors: Dictionary = {
	0: "999999",
	1: "9a88e8",
	2: "5aa0d6",
	3: "40aca6",
	4: "62ad69",
	5: "ab9856",
}

var item_name: String
signal update_tile_menu

func _ready():
	item_name = item_dictionary[item]
	$ItemColor.color = item_colors[item]
	$Label.text = item_name
	var tile_menu_item: Control = load("res://scenes/screens/level_editor/build_menu/tile_menu_items/tile_menu_" + item_name.to_lower() + ".tscn").instantiate()
	update_tile_menu.connect(tile_menu_item.on_update_tile_menu)
	tile_menu_item.parent = self
	add_child(tile_menu_item)
	
	parent.update_item_rotations.connect(on_update_item_rotation)
	var flip_button := Button.new()
	flip_button.text = "|"
	flip_button.size.y = 20
	flip_button.pressed.connect(on_flip_button_pressed.bind(tile_menu_item,))
	add_child(flip_button)
	add_rotate_button.call_deferred(tile_menu_item)
	(func(): flip_button.position = Vector2($Label.position.x + $Label.size.x + 215, 5)).call_deferred()
	
	add_item_btn.call_deferred()
	
	var base_pos: Array[Vector2i] = [Vector2i(10, 55), Vector2i(10, 95), Vector2(100, 55), Vector2i(100, 95)]
	var base_btns: Array[String] = ["Copy", "Bucket", "Delete", "Move"]
	for i in range(base_btns.size()):
		var btn := Button.new()
		btn.text = base_btns[i]
		btn.position = base_pos[i]
		btn.size.x = 80
		btn.pressed.connect(func(): parent[base_btns[i].to_lower()].emit(item, tiles))
		tile_menu_item.add_child(btn)

func add_item_btn() -> void:
	if item_name != "General":
		var item_btn: Control = preload("res://scenes/ui_general/scale_button/scale_button.tscn").instantiate()
		ItemButton = item_btn
		item_btn.scale = Vector2(0.5, 0.5)
		item_btn.name = "Item_Type"
		item_btn.steps = Vector2(1, 2)
		item_btn.position = Vector2(6, 136)
		item_btn.label_text = "Item Type"
		item_btn.snap_mode = true

func on_set_item_btn() -> void:
	if item_name != "General":
		var first_time: bool = !ItemButton.is_inside_tree()
		var area: Dictionary = parent.get_parent().loaded_area
		if tiles.size() == 1 and area:
			var variances: Array = range(1, 10)
			var tile: Node3D = tiles[0]
			var path: String = "res://assets/models/"
			match item:
				1: 
					path += "tiles/"
					path += Helper.tid_to(tile.info.tile.id, area.id, 0)
				2: 
					path += "objects/"
					path += Helper.editor_id_to(item - 1, tile.info.obj.id, 0)
				3: 
					path += "walls/"
					path += Helper.wid_to(tile.info.wall.id, area.id, 0)
				4:
					path += "decorations/tiles/"
					path += Helper.editor_id_to(item - 1, tile.info.obj.id, 0)
				5:
					path += "decorations/walls/"
					path += Helper.editor_id_to(item - 1, tile.info.obj.id, 0)
			
			variances = variances.filter(func(i: int): return FileAccess.file_exists(path + str(i) + ".glb"))
			if variances.size() > 0:
				ItemButton.default = tile.info[item_name.to_lower()].type
				ItemButton.min_max = Vector2(0, variances.size())
				ItemButton.visible = true
				if !first_time: ItemButton.recalibrate_min_max()
			else: ItemButton.visible = false
		else: ItemButton.visible = false
		
		if first_time: 
			add_child(ItemButton)
			ItemButton.item_selected.connect(func(i: int): parent.item_type.emit(i, item, tiles))

func on_flip_button_pressed(tmi: Control) -> void:
	rotate_item_index = abs(rotate_item_index - 1)
	RotateButton.queue_free()
	add_rotate_button(tmi)

func add_rotate_button(tmi: Control) -> void:
	match rotate_item_index:
		0:
			var rotate_btn: Control = preload("res://scenes/ui_general/scale_button/scale_button.tscn").instantiate()
			rotate_btn.scale = Vector2(0.5, 0.5)
			rotate_btn.min_max = Vector2(0, 5)
			rotate_btn.steps = Vector2(1, 6)
			rotate_btn.label_text = "Rotate"
			rotate_btn.snap_mode = true
			rotate_btn.position = Vector2($Label.position.x + $Label.size.x + 10, 5)
			tmi.add_child(rotate_btn)
			rotate_btn.item_selected.connect(func(i: int): parent.rotate_full.emit(item, i, tiles))
			RotateButton = rotate_btn
			
			if tiles.size() == 1:
				if item_name != "General": on_update_item_rotation()
				else: rotate_btn.item_selected.connect(func(__: int): parent.update_item_rotations.emit())
			
		1: 
			var cnt := Control.new()
			RotateButton = cnt
			tmi.add_child(cnt)
			cnt.size = Vector2.ZERO
			
			var x: int = $Label.position.x + $Label.size.x + 15
			for i in [["<", -1], [">", 1]]:
				var btn := Button.new()
				btn.text = i[0]
				cnt.add_child(btn)
				btn.size = Vector2(95, 10)
				btn.position = Vector2(x, 5)
				btn.pressed.connect(func(): parent.rotate_direction.emit(item, i[1], tiles))
				
				if tiles.size() == 1 and item_name == "General":
					btn.pressed.connect(func(): parent.update_item_rotations.emit())
				
				x += 100

func on_update_item_rotation() -> void:
	if tiles.size() == 1 and item_name != "General" and RotateButton != null and !(RotateButton is Button):
		RotateButton.default = tiles[0].info[item_name.to_lower()].rotation
		RotateButton.set_grabber_position()

func on_update_tile_menu() -> void: 
	update_tile_menu.emit()
	on_set_item_btn.call_deferred()
