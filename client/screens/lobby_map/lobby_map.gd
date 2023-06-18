extends Node3D

signal change_animation_status
signal add_to_back_history
var on_lobby_step_back_finished: Callable
var at_item: bool = false
var lobby_can_select_item: int = 0
var lobby_current_camera_travel_item_selected: int = 0
var lobby_current_item_selected: int = 0
var moving_lobby_camera_initial_position: Vector3
var path_point_array: Array = []

const lobby_camera_posrot_path := "res://static_data/lobby_camera_posrot.json"
@onready var lcps = Helper.load_json(lobby_camera_posrot_path)

const lobby_camera_travel_info_json := "res://static_data/lobby_camera_travel_info.json"
@onready var lobby_camera_travel_info_dict: Dictionary = Helper.load_json(lobby_camera_travel_info_json)

@onready var camera: Camera3D = $Camera3D

func _ready():
	for child in $LobbyAreas.get_children():
		child.mouse_entered.connect(func(): if child.name.is_valid_int() \
		and !lobby_current_item_selected: lobby_can_select_item = child.name.to_int())
		child.mouse_exited.connect(func(): if !lobby_current_item_selected: lobby_can_select_item = 0)
func _process(delta: float) -> void:
	
	if lobby_can_select_item and !lobby_current_camera_travel_item_selected and Input.is_action_just_pressed("InputA"):
		at_item = true
		move_camera_to_or_from_lobby_item_position()

	elif lobby_current_camera_travel_item_selected:
		var movement: Vector3 = (path_point_array[0][2] * lobby_camera_travel_info_dict[str(lobby_current_camera_travel_item_selected)].speed * delta)
		camera.position += movement
		if moving_lobby_camera_initial_position.distance_to(camera.position) > moving_lobby_camera_initial_position.distance_to(path_point_array[0][0]):
			path_point_array.remove_at(0)
			if path_point_array.size():
				path_point_array[0].append((path_point_array[0][0] - camera.position).normalized())
				moving_lobby_camera_initial_position = camera.position
			else:
				lobby_camera_travel_finished()
func lobby_camera_travel_finished() -> void:
	if at_item:
		lobby_current_item_selected = lobby_current_camera_travel_item_selected
		add_to_back_history.emit([on_lobby_camera_step_back, 0])
	else:
		on_lobby_step_back_finished.call()
		lobby_current_item_selected = 0
	
	change_animation_status.emit(0)
	lobby_current_camera_travel_item_selected = 0
func move_camera_to_or_from_lobby_item_position():
	
	moving_lobby_camera_initial_position = camera.position
	for item in [lobby_can_select_item, lobby_current_item_selected]:
		if item:
			lobby_current_camera_travel_item_selected = item
		
	lobby_can_select_item = 0
	lobby_current_item_selected = 0
		
	var path: Curve3D = load("res://screens/lobby_map/paths/%slobby-item-path.tres" % lobby_current_camera_travel_item_selected)
	if at_item:
		for i in range(1, path.point_count):
			var last_rotation: Vector3
			if i > 1:
				last_rotation = path_point_array[i - 2][1]
			else:
				last_rotation = camera.rotation_degrees
			path_point_array.append([path.get_point_position(i), tilt_to_rotation_degrees(path.get_point_tilt(i), last_rotation)])
	else:
		var max_count: int = path.point_count - 2
		var c: int = 0
		for i in range(max_count, -1, -1):
			var last_rotation: Vector3
			if i < max_count:
				last_rotation = path_point_array[c - 1][1]
			else:
				last_rotation = camera.rotation_degrees
				
			path_point_array.append([path.get_point_position(i), tilt_to_rotation_degrees(path.get_point_tilt(i), last_rotation)])
			c += 1
	
	path_point_array[0].append((path_point_array[0][0] - camera.position).normalized())
	change_animation_status.emit(1)
func tilt_to_rotation_degrees(tilt: float, lr: Vector3) -> Vector3:
	
	var code: String = str(tilt)
	var cr: Vector3 = Vector3.ZERO
	if code.length() <= 1:
		return lr

	elif code.length() == 7:
		var c: int = 1
		for i in ["x", "y", "z"]:
			cr[i] = int("%s%s" % [code[c], code[c + 1]])
			c += 2
		
		match code[0]:
			1: cr.x *= -1
			2: cr.y *= -1
			3:
				cr.x *= -1
				cr.y *= -1
			4: cr.z *= -1
			5: 
				cr.x *= -1
				cr.z *= -1
			6: 
				cr.y *= -1
				cr.z *= -1
			7: cr *= -1
			8: cr *= (lr / lr)
			
		match cr.x:
			91: cr.x = lr.x
			92: cr.y = lr.y
			93: 
				cr.x = lr.x
				cr.y = lr.y
			94:
				cr.z = lr.z
			95:
				cr.x = lr.x
				cr.z = lr.z
			96:
				cr.y = lr.y
				cr.z = lr.z
			97: cr = lr
			
	return cr
func on_lobby_camera_step_back(info: Array): # location in enum [0], stepping back changer func [1]
	at_item = false
	move_camera_to_or_from_lobby_item_position()
	on_lobby_step_back_finished = info[1]
