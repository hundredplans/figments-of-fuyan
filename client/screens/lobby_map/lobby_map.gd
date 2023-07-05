extends Node3D

signal change_animation_status
signal lobby_camera_travel_main_menu_finished
signal lobby_camera_travel_item_finished
signal lobby_camera_travel_item_started

const max_item_id: int = 13
const min_item_id: int = 0

var on_camera_distance_travelled: Callable

const exit_id: int = 99
const exit_door_open_time: float = 0.4
const exit_door_rotation_angle: float = 140
var exit_door_current_time: float = 0
var exit_door_start_interpolate: bool = false

var on_lobby_step_back_finished: Callable
var camera_travel_finished: Callable

var lobby_current_camera_travel_item_selected: int = 0
var lobby_current_item_selected: int = 0

var path_point_array: Array = []
var path_rotation_array: Array = []

var camera_current_time: float = 0
var camera_travelled_distance: float
var camera_total_distance: float
var camera_normalized_travelled_distance: float = 0

var camera_move_forward: bool = true
var camera_total_time: float
var camera_point_distance: float

var camera_rotations_index: int = 0
var camera_points_index: int = 0

const lobby_camera_posrot_path := "res://static_data/lobby_camera_posrot.json"
@onready var lcps = Helper.load_json(lobby_camera_posrot_path)
const lobby_camera_travel_info_json := "res://static_data/lobby_camera_item_info.json"
@onready var lobby_camera_travel_info_dict: Dictionary = Helper.load_json(lobby_camera_travel_info_json)
@onready var camera: Camera3D = $Camera3D
	
func _ready():
	for child in $LobbyItemEffects.get_children():
		child.visible = false
	
func _process(delta: float) -> void:
	if lobby_current_camera_travel_item_selected: interpolate_camera_movement(delta)
	if exit_door_start_interpolate: interpolate_exit_doors(delta)
	if on_camera_distance_travelled: on_camera_distance_travelled.call(camera_normalized_travelled_distance)
		
func interpolate_camera_movement(delta: float):
	var lerp_factor: float = ease_item(min(camera_current_time / camera_total_time, 1), lobby_current_camera_travel_item_selected)
	var new_position: Vector3 = path_point_array[camera_points_index - 1].lerp(path_point_array[camera_points_index], lerp_factor)
	process_camera_lerp_rotation(lerp_factor, new_position.distance_to(camera.position))
	camera.position = path_point_array[camera_points_index - 1].lerp(path_point_array[camera_points_index], lerp_factor)
	if camera.position.is_equal_approx(path_point_array[camera_points_index]):
		camera_points_index += 1
		camera_current_time = 0
		if camera_points_index != path_point_array.size():
			camera_point_distance = path_point_array[camera_points_index - 1].distance_to(path_point_array[camera_points_index])
			camera_total_time = camera_point_distance / lobby_camera_travel_info_dict[str(lobby_current_camera_travel_item_selected)].speed
		else:
			camera_travel_finished.call()
			
		if lobby_current_camera_travel_item_selected:
			if camera.rotation_degrees.is_equal_approx(path_rotation_array[camera_rotations_index][0]):
				camera_rotations_index += 1
				camera_travelled_distance = 0
				if path_rotation_array[camera_rotations_index].size() > 1:
					for i in range(path_rotation_array[camera_rotations_index][2], path_rotation_array[camera_rotations_index][3]):
						camera_total_distance += path_point_array[i].distance_to(path_point_array[i + 1])
						
	camera_current_time += delta
	camera_normalized_travelled_distance = camera_travelled_distance / camera_total_distance
	
func interpolate_exit_doors(delta: float):
	exit_door_current_time += delta
	var rotation_angles: Array = [exit_door_rotation_angle, exit_door_rotation_angle * -1]
	for i in range(rotation_angles.size()):
		var child: Node3D = $LobbyItems.get_node("1").get_child(i)
		child.rotation_degrees = child.rotation_degrees.lerp(Vector3(0, rotation_angles[i], 0), exit_door_current_time / exit_door_open_time)
	
func process_camera_lerp_rotation(lerp_factor: float, current_travel_distance: float):
	
	if path_rotation_array[camera_rotations_index].size() > 1:
		camera_travelled_distance += current_travel_distance
		var rotation_lerp_factor: float = min(camera_travelled_distance / camera_total_distance, 1)
		camera.rotation_degrees = path_rotation_array[camera_rotations_index][1].lerp(path_rotation_array[camera_rotations_index][0], rotation_lerp_factor)
	else:
		camera.rotation_degrees = camera.rotation_degrees.lerp(path_rotation_array[camera_rotations_index][0], lerp_factor)

func on_lobby_camera_exit_travel_finished() -> void: 
	get_tree().quit()
	on_lobby_camera_travel_finished()
func on_lobby_camera_item_travel_finished() -> void:
	lobby_current_item_selected = lobby_current_camera_travel_item_selected
	lobby_camera_travel_item_finished.emit([on_lobby_camera_step_back, 0, lobby_camera_travel_info_dict[str(lobby_current_item_selected)].init])
	on_lobby_camera_travel_finished()
func on_lobby_camera_main_menu_travel_finished() -> void:
	on_lobby_step_back_finished.call()
	lobby_camera_travel_main_menu_finished.emit()
	lobby_current_item_selected = 0
	on_lobby_camera_travel_finished()
func on_lobby_camera_travel_finished():
	
	on_camera_distance_travelled = Callable()
	for child in $LobbyItemEffects.get_children(): child.queue_free()
	lobby_current_camera_travel_item_selected = 0
	change_animation_status.emit(0)
	camera_travel_finished = Callable()
	
func create_camera_rotation_point_array(path_str: String) -> void:
	
	var local_path_rotation_array: Array = []
	path_rotation_array.clear()
	path_point_array.clear()
	
	var path: Curve3D = load(path_str)
	
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
	move_camera_through_path(false, on_lobby_camera_main_menu_travel_finished, item_id_to_path(lobby_current_item_selected), lobby_current_item_selected)
	on_lobby_step_back_finished = info[1]
	
func ease_item(x: float, item_id: int) -> float:
	if x < 0: return 0
	elif x > 1: return 1
	match lobby_camera_travel_info_dict[str(item_id)].ease:
		"EaseInSine": return  1.0 - cos((x * PI) / 2)
		"EaseInOutSine": return -(cos(x * PI) - 1) / 2
		"EaseInCirc": return 1.0 - sqrt(1 - pow(x, 2))
	return 1
	
func on_lobby_item_selected(item_id: int) -> void:
	move_camera_through_path(true, on_lobby_camera_item_travel_finished, item_id_to_path(item_id), item_id)
	
func item_id_to_path(item_id: int) -> String: return "res://screens/lobby_map/paths/%slobby-item-path.tres" % item_id
	
func on_exit_door_exit_game(path: String): 
	move_camera_through_path(true, on_lobby_camera_exit_travel_finished, path, exit_id)
	exit_door_start_interpolate = true
	
func move_camera_through_path(direction: bool, exit_function: Callable, path: String, item_id: int) -> void:
	camera_move_forward = direction
	camera_travel_finished = exit_function
		
	lobby_current_camera_travel_item_selected = item_id
	lobby_current_item_selected = 0
	
	create_camera_rotation_point_array(path)
	on_lobby_item_travel_start(item_id, direction)

func on_lobby_item_travel_start(item_id: int, direction: bool):
	if item_id > min_item_id and item_id < max_item_id:
		lobby_camera_travel_item_started.emit(item_id, direction)
		on_trigger_lobby_item_effects(item_id, direction)

func on_trigger_lobby_item_effects(item_id: int, direction: bool) -> void:
	var effect_path: String = "res://screens/lobby_map/travel_effects/%seffects_init.tscn" % str(item_id)
	if ResourceLoader.exists(effect_path):
		call("on_" + lobby_camera_travel_info_dict[str(item_id)].name + "_travel_effects_init", effect_path, item_id, direction)
		
func on_DeckManager_travel_effects_init(effect_path: String, _item_id: int, direction: bool):
	var effect: Node3D = load(effect_path).instantiate()
	effect.ready_with_direction(direction)
	on_camera_distance_travelled = effect.on_camera_distance_travelled
	$LobbyItemEffects.add_child(effect)
	
