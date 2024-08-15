extends Node3D

var is_camera_moving: bool = false
@onready var ani_player: AnimationPlayer = $AnimationPlayer
func _on_main_menu_environment_mesh_pressed(mesh_name: String):
	if !is_camera_moving:
		is_camera_moving = true
		ani_player.play(mesh_name)
		await ani_player.animation_finished
		match mesh_name:
			"Gate":
				get_tree().quit()
			"SettingsDoor":
				pass
			"PlayTable":
				pass
		is_camera_moving = false
