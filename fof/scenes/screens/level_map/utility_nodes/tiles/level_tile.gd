class_name TileGD
extends Node3D

@onready var ModelManager: Node3D = $ModelManager
@onready var Effects: Node3D = $Effects

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

var Unit: UnitGD
var Tiles: TilesGD

func getSolidState() -> bool: 
	return Unit != null or solid_status > 0

func getUnitState() -> String:
	for state in tile_state:
		if state in Tiles.unit_states:
			return state
	return ""

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

func setCollisionState(state: bool) -> void:
	for model in ModelManager.get_children():
		model.body.collision_layer = 0 if !state else (10 if model.type == "Tile" else 8)

func _ready() -> void:
	for point in collision_points:
		var t = preload("res://assets/models/collision_point.tscn").instantiate()
		add_child(t)
		t.global_position = point
			
