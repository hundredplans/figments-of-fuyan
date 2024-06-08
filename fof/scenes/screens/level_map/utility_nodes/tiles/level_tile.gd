class_name TileGD
extends Node3D

@onready var ModelManager: Node3D = $ModelManager
@onready var Effects: Node3D = $Effects

var tile_outlines: Array
var tile_state: Array
var top_of_cliff_wall: Array
@export var collision_points: PackedVector3Array
@onready var types: Array = [tile, obj, wall, tdeco, wdeco]

@export var tile: Dictionary
@export var wdeco: Dictionary
@export var tdeco: Dictionary
@export var obj: Dictionary
@export var wall: Dictionary

@export var solid_status: int = 0
@export var w: int
@export var tpos: Vector3
@export var unit_height: float
@export var fneighbours: Array
@export var id: int

var Unit: UnitGD
var Tiles: TilesGD

func onTTpos(_w: int = w) -> Vector4:
	return Vector4(tpos.x, tpos.y, tpos.z, _w)

func setMaterial(mat: Material, btab: int = -1) -> void:
	match btab:
		-2: for i in range(1, 5): setMaterial(mat, i)
		-1: for i in range(5): setMaterial(mat, i)
		2: 
			if !(wall.model.is_empty()):
				for model in wall.model:
					model.mesh.set_surface_override_material(0, mat)
		_:
			if !types[btab].model == null:
				types[btab].model.mesh.set_surface_override_material(0, mat)

func setOutline(mat: Material) -> void:
	if !types[0].model == null:
		types[0].model.mesh.set_surface_override_material(1, mat)
	
func getTrueHeight() -> float:
	return 0.3 + (w * 1.2) + (0.6 if tile.type in [1, 2] else 0.0)
