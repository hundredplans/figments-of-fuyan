extends Node3D

signal change_animation_status
signal add_to_back_history

var on_lobby_step_back_finished: Callable

var lobby_can_select_item: int = 0
var lobby_current_camera_travel_item_selected: int = 0
var lobby_current_item_selected: int = 0

var path_point_array: Array = []
var path_rotation_array: Array = []

var camera_current_time: float = 0

var camera_travelled_distance: float
var camera_total_distance: float

var camera_total_time: float
var camera_point_distance: float

var camera_move_forward: bool = true

var camera_rotations_index: int = 0
var camera_points_index: int = 0

const lobby_camera_posrot_path := "res://static_data/lobby_camera_posrot.json"
@onready var lcps = Helper.load_json(lobby_camera_posrot_path)
const lobby_camera_travel_info_json := "res://static_data/lobby_camera_travel_info.json"
@onready var lobby_camera_travel_info_dict: Dictionary = Helper.load_json(lobby_camera_travel_info_json)
@onready var camera: Camera3D = $Camera3D
		
func _ready():
	
	for child in $LobbyAreas.get_children():
		if child.name.is_valid_int():
			var int_name: int = child.name.to_int()
			child.mouse_entered.connect(item_mouse_entered.bind(int_name))
			child.mouse_exited.connect(item_mouse_exited.bind(int_name))
		else:
			print("Lobby item name is not a valid integer")
			
	for child in $LobbyGlows.get_children():
		child.visible = false
			
func item_mouse_entered(int_name: int) -> void:
	if !lobby_current_camera_travel_item_selected and !lobby_current_item_selected and !lobby_can_select_item:
		lobby_can_select_item = int_name
		$LobbyGlows.get_node("%s" % int_name).visible = true
		
func item_mouse_exited(int_name: int) -> void:
	if lobby_can_select_item:
		lobby_can_select_item = 0
		$LobbyGlows.get_node("%s" % int_name).visible = false
	
func _process(delta: float) -> void:
	
	if lobby_can_select_item and !lobby_current_camera_travel_item_selected and Input.is_action_just_pressed("InputA"):
		camera_move_forward = true
		create_camera_rotation_point_array()
		lobby_can_select_item = 1
		item_mouse_exited(lobby_current_camera_travel_item_selected)
		
	elif lobby_current_camera_travel_item_selected:
		var lerp_factor: float = ease_item(min(camera_current_time / camera_total_time, 1), lobby_current_camera_travel_item_selected)
		var new_position: Vector3 = path_point_array[camera_points_index - 1].lerp(path_point_array[camera_points_index], lerp_factor)
		process_camera_lerp_rotation(lerp_factor, new_position.distance_to(camera.position))
		camera.position = new_position
			
		camera.position = path_point_array[camera_points_index - 1].lerp(path_point_array[camera_points_index], lerp_factor)
		if camera.position.is_equal_approx(path_point_array[camera_points_index]):
			camera_points_index += 1
			camera_current_time = 0
			if camera_points_index != path_point_array.size():
				camera_point_distance = path_point_array[camera_points_index - 1].distance_to(path_point_array[camera_points_index])
				camera_total_time = camera_point_distance / lobby_camera_travel_info_dict[str(lobby_current_camera_travel_item_selected)].speed
			else:
				lobby_camera_travel_finished()
				
			if lobby_current_camera_travel_item_selected:
				if camera.rotation_degrees.is_equal_approx(path_rotation_array[camera_rotations_index][0]):
					camera_rotations_index += 1
					camera_travelled_distance = 0
					if path_rotation_array[camera_rotations_index].size() > 1:
						for i in range(path_rotation_array[camera_rotations_index][2], path_rotation_array[camera_rotations_index][3]):
							camera_total_distance += path_point_array[i].distance_to(path_point_array[i + 1])

		camera_current_time += delta

func process_camera_lerp_rotation(lerp_factor: float, current_travel_distance: float):
	
	if path_rotation_array[camera_rotations_index].size() > 1:
		camera_travelled_distance += current_travel_distance
		var rotation_lerp_factor: float = min(camera_travelled_distance / camera_total_distance, 1)
		camera.rotation_degrees = path_rotation_array[camera_rotations_index][1].lerp(path_rotation_array[camera_rotations_index][0], rotation_lerp_factor)
	else:
		camera.rotation_degrees = camera.rotation_degrees.lerp(path_rotation_array[camera_rotations_index][0], lerp_factor)

func lobby_camera_travel_finished() -> void:
	if camera_move_forward:
		lobby_current_item_selected = lobby_current_camera_travel_item_selected
		add_to_back_history.emit([on_lobby_camera_step_back, 0])
	else:
		on_lobby_step_back_finished.call()
		lobby_current_item_selected = 0
		
	lobby_current_camera_travel_item_selected = 0
	change_animation_status.emit(0)
	
func create_camera_rotation_point_array() -> void:
	
	var local_path_rotation_array: Array = []
	path_rotation_array.clear()
	path_point_array.clear()
	
	for item in [lobby_can_select_item, lobby_current_item_selected]:
		if item:
			lobby_current_camera_travel_item_selected = item
		
	lobby_can_select_item = 0
	lobby_current_item_selected = 0
	var path: Curve3D = load("res://screens/lobby_map/paths/%slobby-item-path.tres" % lobby_current_camera_travel_item_selected)
	
	if camera_move_forward:
		local_path_rotation_array.append(tilt_to_rotation_degrees(path.get_point_tilt(0), camera.rotation_degrees))
		for i in range(path.point_count):
			path_point_array.append(path.get_point_position(i))
			if i > 0:
				local_path_rotation_array.append(tilt_to_rotation_degrees(path.get_point_tilt(i), local_path_rotation_array[i - 1]))
	else:
		local_path_rotation_array.append(tilt_to_rotation_degrees(path.get_point_tilt(path.point_count - 1), camera.rotation_degrees))
		var c: int = 0
		for i in range(path.point_count - 1, -1, -1):
			path_point_array.append(path.get_point_position(i))
			if i < path.point_count - 1:
				local_path_rotation_array.append(tilt_to_rotation_degrees(path.get_point_tilt(i), local_path_rotation_array[c - 1]))
			c += 1
			
	convert_vector_one_to_interpolate(local_path_rotation_array)
	camera_rotations_index = 1
	camera_points_index = 1
	
	camera_travelled_distance = 0
	camera_total_distance = 0
	camera_current_time = 0
	
	camera_point_distance = path_point_array[camera_points_index - 1].distance_to(path_point_array[camera_points_index])
	camera_total_time = camera_point_distance / lobby_camera_travel_info_dict[str(lobby_current_camera_travel_item_selected)].speed
	
	if path_rotation_array[camera_rotations_index][0].is_equal_approx(path_rotation_array[0][0]):
		if path_rotation_array[camera_rotations_index + 1].size() > 1:
			path_rotation_array[camera_rotations_index + 1][2] -= 1
			path_rotation_array.remove_at(camera_rotations_index)
	
	if path_rotation_array[camera_rotations_index].size() > 1:
		for i in range(path_rotation_array[camera_rotations_index][2], path_rotation_array[camera_rotations_index][3]):
			camera_total_distance += path_point_array[i].distance_to(path_point_array[i + 1])
	
	change_animation_status.emit(1)
	
func tilt_to_rotation_degrees(tilt: float, lr: Vector3) -> Vector3:
	
	var code: String = str(tilt)
	var cr: Vector3 = Vector3.ZERO
	if code.length() == 1:
		match code[0]:
			"0": return lr
			"1": return Vector3(1, 1, 1)
	
	elif code.length() == 7:
		var c: int = 1
		for i in ["x", "y", "z"]:
			cr[i] = int("%s%s" % [code[c], code[c + 1]])
			c += 2
		
		match code[0]:
			"1": cr.x *= -1
			"2": cr.y *= -1
			"3":
				cr.x *= -1
				cr.y *= -1
			"4": cr.z *= -1
			"5": 
				cr.x *= -1
				cr.z *= -1
			"6": 
				cr.y *= -1
				cr.z *= -1
			"7": cr *= -1
			"8": cr *= (lr / lr)
			
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

func convert_vector_one_to_interpolate(rotations: Array):
	
	var skip_to: int = -1
	for i in range(rotations.size()):
		if i > skip_to:
			if rotations[i] != Vector3(1, 1, 1):
				path_rotation_array.append([rotations[i]])
			else:
				for j in range(i, rotations.size()):
					if rotations[j] != Vector3(1, 1, 1):
						path_rotation_array.append([rotations[i - 1]])
						path_rotation_array.append([rotations[j], rotations[i - 1], i, j])
						skip_to = j

func on_lobby_camera_step_back(info: Array): # location in enum [0], stepping back changer func [1]
	camera_move_forward = false
	create_camera_rotation_point_array()
	on_lobby_step_back_finished = info[1]

func ease_item(x: float, item_id: int) -> float:
	if x < 0: return 0
	elif x > 1: return 1
	match lobby_camera_travel_info_dict[str(item_id)].ease:
		"EaseInSine": return  1.0 - cos((x * PI) / 2)
		"EaseInOutSine": return -(cos(x * PI) - 1) / 2
		"EaseInCirc": return 1.0 - sqrt(1 - pow(x, 2))
	return 1
