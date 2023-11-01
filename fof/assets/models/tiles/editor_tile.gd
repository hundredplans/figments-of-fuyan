extends Node
@export var Tile: Node3D
@export var TileObject: Node3D
@export var TileDecoration: Node3D
@export var TileWallDecoration: Node3D
@export var TileWall: Node3D
@export var DetectMouse: Area3D

signal load_obj_get_area
signal load_wall_get_area
signal load_tile_get_area
signal active_tile

signal exit_mouse
signal hover_tile

var can_press: bool = false
var info: Dictionary = {}

func load_wall(id: int) -> void:
	for child in TileWall.get_children(): child.queue_free()
	info.wall.id = id
	if id > 0: load_wall_get_area.emit(id, self)
	
func on_load_wall_get_area(id: int, area: int) -> void:
	var p: int = -1 if info.wall.tile_wall else 0
	
	var wall_short: PackedScene = load("res://assets/models/walls/" + Helper.wid_to(id, area, info.wall.type) + ".glb")
	if info.wall.height == 0: p = 2
	else: p += info.wall.height * 4
	for n in range(p):
		var wall: Node3D = create_wall(wall_short)
		wall.position.y = (n * 0.3)
	
func create_wall(wall_scene: PackedScene) -> Node3D:
	var wall: Node3D = wall_scene.instantiate()
	TileWall.add_child(wall)
	TileWall.rotation_degrees.y = info.wall.rotation * 60
	return wall
	
func load_tdeco(id: int) -> void:
	for child in TileDecoration.get_children(): child.queue_free()
	info.tdeco.id = id
	if id > 0:
		var decoration: Node3D = load("res://assets/models/decorations/tiles/" + Helper.editor_id_to(3, id, info.tdeco.type) + ".glb").instantiate()
		TileDecoration.add_child(decoration)
		TileDecoration.rotation_degrees.y = info.tdeco.rotation * 60
	
func load_wdeco(id: int) -> void:
	for child in TileWallDecoration.get_children(): child.queue_free()
	info.wdeco.id = id
	if id > 0:
		var decoration: Node3D = load("res://assets/models/decorations/walls/" + Helper.editor_id_to(4, id, info.wdeco.type) + ".glb").instantiate()
		TileWallDecoration.add_child(decoration)
		TileWallDecoration.rotation_degrees.y = info.wdeco.rotation * 60

func load_obj(id: int) -> void:
	for child in TileObject.get_children(): child.queue_free()
	info.obj.id = id
	if id > 0:
		if info.obj.loaded <= 0:
			var object: Node3D = load("res://assets/models/objects/" + Helper.editor_id_to(1, id, info.obj.type) + ".glb").instantiate()
			TileObject.add_child(object)
			TileObject.rotation_degrees.y = info.obj.rotation * 60
		else:
			load_obj_get_area.emit(id, self)
	
func on_load_obj_get_area(id: int, area: Dictionary) -> void:
	if info.obj.loaded in area.cards:
		var card: Dictionary = Helper.id_to_dict(info.obj.loaded, "Card")
		var model_path: String = "res://assets/base_game/cards/card/default_model.glb"
		var card_model_path: String = "res://assets/base_game/cards/" + card.bgfn + "/model.glb"
		if FileAccess.file_exists(card_model_path):
			model_path = card_model_path
		TileObject.add_child(load(model_path).instantiate())
		TileObject.rotation_degrees.y = info.obj.rotation * 60
	else:
		info.obj.loaded = 0
		load_obj(id)
	
	
func load_tile(id: int) -> void:
	for child in Tile.get_children(): child.queue_free()
	if id > 0: load_tile_get_area.emit(id, self)
	if id != 2: info.tile.id = id
	
func on_load_tile_get_area(id: int, area: int) -> void:
	var tile: Node3D = load("res://assets/models/tiles/" + Helper.tid_to(id, area, info.tile.type) + ".glb").instantiate()
	Tile.add_child(tile)
	Tile.rotation_degrees.y = info.tile.rotation * 60
	
func on_mouse_entered_check_mblockers(mblockers: Array) -> void:
	if !(mblockers.filter(func(x: Rect2i): return x.has_point(get_viewport().get_mouse_position()))):
		on_mouse_entered()
	else: active_tile.emit(self)

func on_mouse_entered() -> void:
	hover_tile.emit(self)
	active_tile.emit(self)
	can_press = true

func on_mouse_exited() -> void:
	can_press = false
	exit_mouse.emit(self)
