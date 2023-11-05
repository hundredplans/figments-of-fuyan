extends Control

var World: Node3D = preload("res://scenes/world/item_editor_world/item_editor_world.tscn").instantiate()
var Model: Node3D
var Tile: Node3D
var Tiles: Node3D
var Ray: RayCast3D

var active_tile: Node3D

var blockers: Array
@onready var ItemName: Label = $ItemName
@onready var ItemSettings: Control = $ItemSettings
@onready var Items: Control = $AvailableItems/Items
@onready var ElevationSettings: Control = $ElevationSettings
@onready var ElevationButtons: Control = $ElevationSettings/Buttons

var item_settings: Dictionary
var selected_item: Vector2i
var id_to: Array = Helper._id_to

signal load_world

func _ready():
	for child in ElevationButtons.get_children(): child.pressed.connect(on_set_elevation.bind(int(str(child.name))))
	blockers = $DetectMouse.get_children().map(func(x: CollisionShape2D): return Rect2(x.position - (x.shape.size / 2), x.shape.size))
	load_world.emit(World)
	Model = World.get_node("Model")
	Tile = World.get_node("Tile")
	Tiles = World.get_node("Tiles")
	Ray = World.get_node("RayCast3D")
	_on_item_type_item_selected(0)

func _on_item_type_item_selected(i: int) -> void:
	_on_save_button_pressed()
	for child in Tile.get_children(): child.queue_free()
	for child in Model.get_children(): child.queue_free()
	for child in Tiles.get_children(): child.queue_free()
	for child in ItemSettings.get_children(): child.queue_free()
	for child in Items.get_children(): child.queue_free()
	on_set_tile_queued()
	ItemName.text = ""
	item_settings = {}
	selected_item = Vector2i.ZERO
	ElevationSettings.visible = false
	
	var y: int = 0
	for n in range(id_to[i + 1].size()):
		if n > 0:
			var btn := Button.new()
			Items.add_child(btn)
			btn.size.x = Items.size.x
			btn.text = convert_item_name(id_to[i + 1][n])
			btn.position.y = y
			btn.pressed.connect(on_item_selected.bind(Vector2(i + 1, n)))
			y += 31

func convert_item_name(n: String) -> String:
	return n.split("/")[n.get_slice_count("/") - 1]

const SELECTED_ITEM_X: Dictionary = {
	1: ["Visibility", "Solidity", "MultiTile"],
	2: ["Visibility", "Solidity"],
	3: ["Visibility", "Solidity", "MultiTile"],
	4: ["MultiTile"],
}

func on_item_selected(nm: Vector2) -> void:
	on_set_tile_queued()
	ElevationSettings.visible = false
	_on_save_button_pressed()
	ItemName.text = convert_item_name(id_to[nm.x][nm.y])
	selected_item = nm
	load_item_settings()
	item_settings.id = [selected_item.x, selected_item.y]
	add_option_buttons(SELECTED_ITEM_X[int(selected_item.x)])

func load_item_settings() -> void:
	var items: Array = Array(Helper.return_file_contents("res://static/game_info/item_properties.txt").split("\n", false)).map(func(x: String): return str_to_var(x))
	var has_broke: bool = false
	for item in items:
		if Vector2i(item.id[0], item.id[1]) == selected_item:
			has_broke = true
			item_settings = item
			break
			
	if !has_broke:
		item_settings = items[0]
		for i in ["Visibility", "Solidity"]:
			if i not in SELECTED_ITEM_X[selected_item.x]:
				item_settings["0|0|0"].erase(i.to_lower())
	load_multi_tile()
	
const OPTION_BUTTON_POSITIONS: Array = [200, 580, 880]
func add_option_buttons(arr: Array) -> void:
	for child in ItemSettings.get_children(): child.queue_free()
	
	var x: int = 0
	for i in arr:
		var btn: Control
		match i:
			"Visibility":
				btn = preload("res://scenes/ui_general/op_button/op_button.tscn").instantiate()
				btn.options = ["Full-Vision", "Half-Vision", "Over-Vision", "Block"]
			"Solidity", "MultiTile":
				btn = preload("res://scenes/ui_general/binary_button/binary_button.tscn").instantiate()
		
		if i != "MultiTile": btn.default = item_settings["0|0|0"][i.to_lower()]
		else: btn.default = item_settings.multi_tile
		
		btn.item_selected.connect(get("on_" + i.to_lower() + "_set"))
		
		btn.label_text = i
		btn.position.x = OPTION_BUTTON_POSITIONS[x]
		
		ItemSettings.add_child(btn)
		x += 1
		
func on_solidity_set(i: int) -> void:
	item_settings["0|0|0"].solidity = i

func on_visibility_set(i: int) -> void:
	item_settings["0|0|0"].visibility = i

func on_multitile_set(i: int) -> void:
	item_settings.multi_tile = bool(i)
	load_multi_tile()

func _on_save_button_pressed():
	if item_settings:
		var contents: Array = Array(Helper.return_file_contents("res://static/game_info/item_properties.txt").split("\n", false)).map(func(x: String): return str_to_var(x))
		var has_broke: bool = false
		for i in range(contents.size()):
			if Vector2i(contents[i].id[0], contents[i].id[1]) == selected_item:
				contents[i] = item_settings
			
				for tile in Tiles.get_children():
					var solidity: int = tile.tile.solidity if tile.tile.has("solidity") else 0
					var visibility: int = tile.tile.visibility if tile.tile.has("visibility") else 0
					if solidity or visibility > 0: print(solidity, visibility)
					if !(solidity == 0 and visibility == 0):
						contents[i].merge({"%s|%s|%s" % [tile.tile.position.x, tile.tile.position.y, tile.tile.position.z]: {"solidity": solidity, "visibility": visibility}})
					
				has_broke = true
				break
				
		if !has_broke: contents.append(item_settings)
		var scontents: String = ""
		for i in contents: scontents += var_to_str(i).replace("\n", "") + "\n"
		Helper.write_to_file("res://static/game_info/", "item_properties", ".txt", scontents)
	
const MODEL_BASE_PATHS: Dictionary = {
	1: "res://assets/models/objects/",
	2: "res://assets/models/walls/",
	3: "res://assets/models/decorations/tiles/",
	4: "res://assets/models/decorations/walls/",
}

const MULTI_TILE_SIZE: int = 6
func load_single_tile() -> void:
	if selected_item:
		for child in Model.get_children(): child.queue_free()
		for child in Tile.get_children(): child.queue_free()
		var single_item: Node3D = default_tile.instantiate()
		var mdl_name: String = id_to[selected_item.x][selected_item.y]
		match mdl_name:
			"wall": mdl_name = "1wall"
		var mdl: Node3D = load(MODEL_BASE_PATHS[selected_item.x] + mdl_name + ".glb").instantiate()
		Model.add_child(mdl)
		Tile.add_child(single_item)
	
func load_multi_tile() -> void:
	load_single_tile()
	ElevationSettings.visible = item_settings.multi_tile
	for child in Tiles.get_children(): child.queue_free()
	if item_settings.multi_tile:
		for child in Tile.get_children(): child.queue_free()
		for w in range(6):
			for x in range(-MULTI_TILE_SIZE, (MULTI_TILE_SIZE + 1)):
				for y in range(max(-MULTI_TILE_SIZE, -x - MULTI_TILE_SIZE), min(MULTI_TILE_SIZE, -x + MULTI_TILE_SIZE) + 1):
					create_tile(Vector3(x, y, w))
		on_set_elevation(0)

var hover_tile: PackedScene = preload("res://assets/models/tiles/_hover.glb")
var default_tile: PackedScene = preload("res://assets/models/tiles/_default_tile.glb")
func create_tile(xy: Vector3) -> void:
	var tile: Node3D = preload("res://scenes/screens/item_editor/item_editor_tile.tscn").instantiate()
	tile.position = Vector3((sqrt(3) * xy.x + sqrt(3) * xy.y * 0.5),
	xy.z * 1.2,
	xy.y * 3 / 2)
	
	Tiles.add_child(tile)
	tile.tile.position = xy
	if (xy.x == 0 and xy.y == 0 and xy.z == 0): tile.get_node("Tile").add_child(default_tile.instantiate())
	tile.get_node("DetectMouse").mouse_entered.connect(on_tile_mouse_entered.bind(tile))
	tile.get_node("DetectMouse").mouse_exited.connect(on_tile_mouse_exited.bind(tile))

func on_tile_mouse_entered(tile: Node3D) -> void:
	if !(tile.tile.position.x == 0 and tile.tile.position.y == 0 and tile.tile.position.z == 0) and SelectionBox == null and !selected_tiles:
		if !blockers.any(func(x: Rect2): return x.has_point(get_viewport().get_mouse_position())):
			if tile not in enabled_tiles:
				tile.get_node("Tile").add_child(default_tile.instantiate())
			active_tile = tile
	
func on_tile_mouse_exited(tile: Node3D) -> void:
	if !(tile.tile.position.x == 0 and tile.tile.position.y == 0 and tile.tile.position.z == 0) and SelectionBox == null and !selected_tiles:
		if tile not in enabled_tiles:
			for child in tile.get_node("Tile").get_children(): child.queue_free()
		active_tile = null
func _queue_free() -> void:
	_on_save_button_pressed()
	load_world.emit(null)

var elevation: int = 0
func on_set_elevation(i: int) -> void:
	if active_tile: on_tile_mouse_exited(active_tile)
	elevation = i
	for child in ElevationButtons.get_children():
		match int(str(child.name)):
			i: child.modulate = Helper.RED
			_: child.modulate = Helper.BASE 
			
	for child in Tiles.get_children():
		child.get_node("DetectMouse").collision_layer = 2 if child.tile.position.z == elevation and child.tile.position != Vector3.ZERO else 0

func _on_detect_mouse_mouse_entered(): if active_tile: on_tile_mouse_exited(active_tile)
func _on_detect_mouse_mouse_exited(): if active_tile: on_tile_mouse_entered(active_tile)

var selected_tiles: Array
var SelectionBox: Node2D

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(Helper.interact_button()) and active_tile:
		on_selected_tiles([active_tile])
	
	if Input.is_action_pressed("LeftClick") and !selected_tiles and item_settings and item_settings.multi_tile:
		match SelectionBox:
			null: on_create_selection_box()
			_: on_resize_selection_box()
		
	if Input.is_action_just_released("LeftClick"):
		on_clear_selection_box()

func on_create_selection_box() -> void:
	if active_tile: on_tile_mouse_exited(active_tile)
	SelectionBox = Polygon2D.new()
	SelectionBox.position = Vector2(0, 0)
	SelectionBox.polygon = [get_viewport().get_mouse_position()]
	add_child(SelectionBox)
	SelectionBox.color = "2fffff87"
	
func on_resize_selection_box() -> void:
	if get_viewport().get_mouse_position() not in SelectionBox.polygon:
		SelectionBox.polygon = Array(SelectionBox.polygon) + [get_viewport().get_mouse_position()]

func on_clear_selection_box() -> void:
	if SelectionBox:
		if item_settings and item_settings.multi_tile:
			var tiles: Array = []
			Ray.position = World.get_node("Camera3D").position
			for tile in Tiles.get_children():
				Ray.target_position = tile.position - Ray.position
				Ray.force_raycast_update()
				if Ray.get_collider() == tile.get_node("DetectMouse"):
					if Geometry2D.is_point_in_polygon(World.get_node("Camera3D").unproject_position(Ray.get_collision_point()), SelectionBox.polygon):
						tiles.append(tile)
						
			if tiles:
				on_selected_tiles(tiles)
		
		SelectionBox.queue_free()
		SelectionBox = null


var SetTile: Control
func on_selected_tiles(tiles: Array) -> void:
	if active_tile: on_tile_mouse_exited(active_tile)
	selected_tiles = tiles
	for child in selected_tiles: on_tile_selected(child, true)
	
	var _SetTile: Control = preload("res://scenes/screens/item_editor/set_tile.tscn").instantiate()
	SetTile = _SetTile
	SetTile.position = Vector2(960, 540)
	SetTile.queued.connect(on_set_tile_queued)
	add_child(SetTile)
	SetTile.get_node("RemoveButton").pressed.connect(on_set_tile_queued)
	
	on_change_enabled(1)
	var y: int = 30
	for i in SELECTED_ITEM_X[selected_item.x] + ["Enabled"]:
		var btn: Control
		match i:
			"Visibility":
				btn = preload("res://scenes/ui_general/op_button/op_button.tscn").instantiate()
				btn.options = ["Full-Vision", "Half-Vision", "Over-Vision", "Block"]
			"Solidity":
				btn = preload("res://scenes/ui_general/binary_button/binary_button.tscn").instantiate()
				btn.ignore_repeat = false
			"Enabled":
				btn = preload("res://scenes/ui_general/binary_button/binary_button.tscn").instantiate()
				btn.default = 1
				btn.item_selected.connect(on_change_enabled)

		if btn:
			btn.label_text = i
			SetTile.get_node("Buttons").add_child(btn)
			if i != "Enabled":
				btn.item_selected.connect(on_selected_tiles_set.bind(i))
			btn.position = Vector2(30, y)
			y += 80

var enabled_tiles: Array = []
func on_change_enabled(i: int) -> void:
	for tile in selected_tiles:
		if i == 0 and tile in enabled_tiles: enabled_tiles.erase(tile)
		elif tile not in enabled_tiles: enabled_tiles.append(tile)

func on_selected_tiles_set(val: int, i: String) -> void:
	for tile in selected_tiles:
		tile.tile[i.to_lower()] = val
		
func on_set_tile_queued() -> void:
	if SetTile != null and !SetTile.is_queued_for_deletion():
		SetTile.queue_free()
	
	for child in selected_tiles: on_tile_selected(child, false)
	selected_tiles = []

func on_tile_selected(tile: Node3D, is_selected: bool) -> void:
	if tile not in enabled_tiles: for child in tile.get_node("Tile").get_children(): child.queue_free()
	if is_selected: tile.get_node("Tile").add_child(hover_tile.instantiate())
