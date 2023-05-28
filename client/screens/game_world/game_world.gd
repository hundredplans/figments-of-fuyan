extends Node3D

func load_map(map_name: String) -> void:
	add_child(load("res://screens/%s/%s.tscn" % [map_name, map_name]).instantiate())
