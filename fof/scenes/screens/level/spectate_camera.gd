extends Camera3D

var central_point: Vector3
func on_camera_start_spectate(pos: Vector3) -> void:
	central_point = pos
	position = Vector3(pos.x, pos.y + 2, pos.z)
	on_set_camera_point_along_circle(180)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(Helper.interact_button(true)):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	elif Input.is_action_just_released(Helper.interact_button(true)):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		on_set_camera_point_along_circle(cam_rot + event.relative.x)

var cam_rot: float = 0.0
func on_set_camera_point_along_circle(rot: float) -> void:
	cam_rot = rot
	position.x = (deg_to_rad(rot) * PI)
	position.z = (deg_to_rad(rot) * PI)
	look_at(central_point)
