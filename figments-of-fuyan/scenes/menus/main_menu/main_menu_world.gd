extends Node3D

func _on_main_menu_environment_mesh_pressed(mesh_name: String):
	match mesh_name:
		"Gate": get_tree().quit()
