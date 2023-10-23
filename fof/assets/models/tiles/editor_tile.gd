extends Node
@export var Tile: Node3D
@export var TileObject: Node3D
@export var TileDecoration: Node3D
@export var TileWall: Node3D
@export var DetectMouse: Area3D

signal load_wall_get_area
signal load_tile_get_area
signal active_tile

signal tile_select
signal tile_interact
signal tile_remove
signal tile_rotate

var can_press: bool = false
var info: Dictionary = {}

func load_wall(id: int) -> void:
	for child in TileWall.get_children(): child.queue_free()
	info.wall.id = id
	if info.tile.id > 0 and id > 0: load_wall_get_area.emit(id, self)
	
func on_load_wall_get_area(id: int, area: int) -> void:
	var wall: Node3D = load("res://assets/models/walls/" + Helper.wid_to(id, area, info.wall.type) + ".glb").instantiate()
	TileWall.add_child(wall)
	TileWall.rotation_degrees.y = info.wall.rotation * 60
	
func load_deco(id: int) -> void:
	for child in TileDecoration.get_children(): child.queue_free()
	info.deco.id = id
	if info.tile.id > 0 and id > 0:
		var decoration: Node3D = load("res://assets/models/decorations/" + Helper.editor_id_to(3, id, info.deco.type) + ".glb").instantiate()
		TileDecoration.add_child(decoration)
		TileDecoration.rotation_degrees.y = info.deco.rotation * 60

func load_obj(id: int) -> void:
	for child in TileObject.get_children(): child.queue_free()
	info.obj.id = id
	if info.tile.id > 0 and id > 0:
		var object: Node3D = load("res://assets/models/objects/" + Helper.editor_id_to(1, id, info.obj.type) + ".glb").instantiate()
		TileObject.add_child(object)
		TileObject.rotation_degrees.y = info.obj.rotation * 60
	
func load_tile(id: int) -> void:
	for child in Tile.get_children(): child.queue_free()
	if id > 0 and !(info.tile.id == 0 and id == 2):
		load_tile_get_area.emit(id, self)
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
	if !info.tile.type > 0: load_tile(2)
	active_tile.emit(self)
	can_press = true

func on_mouse_exited() -> void:
	can_press = false
	if info.tile.id > 0 and info.tile.type == 0:
		load_tile(info.tile.id)
