class_name TileGD
extends Node3D

@onready var tile: Node3D = $Tile
@onready var wall: Node3D = $Wall
@onready var obj: Node3D = $Object
@onready var wdeco: Node3D = $WallDecoration
@onready var tdeco: Node3D = $TileDecoration

var area: int = 0
@export var info: Dictionary
func on_load_info(type: String) -> void:
	type = type.to_lower()
	match type:
		"tile", "wall", "obj": get(type).on_load_info(info[type], area)
		"tdeco", "wdeco": get(type).on_load_info(info[type], Helper.TYPE_TO_BTAB[type])
