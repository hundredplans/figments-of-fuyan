extends Node3D

var _LightTester: PackedScene = preload("res://assets/base_game/levels/level/light_tester.tscn")
func _ready() -> void:
	var LightTester: Node3D = _LightTester.instantiate()
	add_child(LightTester)
	
	var sfp: String = scene_file_path
	var level_info: Dictionary = Helper.id_to_dict(int(sfp.get_slice("/", sfp.get_slice_count("/") - 2).split("-")[0]), "Level")
	var area_info: Dictionary = Helper.id_to_dict(level_info.area, "Area")
	
	LightTester.get_node("WorldEnvironment").environment = load("res://assets/base_game/areas/" + area_info.bgfn + "/env.tres")
