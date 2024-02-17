class_name TileGD
extends Node3D

@export var tile: Node3D
@export var wall: Node3D
@export var obj: Node3D
@export var tdeco: Node3D
@export var wdeco: Node3D

var area: int = 0
@export var info: Dictionary
@export var vision_status: int = 0
@export var solid_status: int = 0
var original_solid_status: int = 0
var tile_state: Array

func on_load_info(type: String) -> void:
	type = type.to_lower()
	match type:
		"tile", "wall": get(type).on_load_info(info[type], area)
		"tdeco", "wdeco", "obj": get(type).on_load_info(info[type])
		
func set_material(mat: Material, btab: int = -1) -> void:
	for type in Helper.BTAB_TO_TYPE[btab]:
		get(type).set_material(mat)

func unit_state() -> String:
	for _unit_state in tile_state:
		if _unit_state in Helper.unit_states:
			return _unit_state
	return ""
