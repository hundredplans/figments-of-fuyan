extends Node3D

signal change_animation_status
signal add_to_back_history

var points_removed: int = 0
var track_distance: bool = false
var track_distance_travelled: float = 0
var track_distance_total: float = 0
var on_lobby_step_back_finished: Callable
var at_item: bool = false
var lobby_can_select_item: int = 0
var lobby_current_camera_travel_item_selected: int = 0
var lobby_current_item_selected: int = 0
var moving_lobby_camera_initial_position: Vector3
var path_point_array: Array = []
var path_rotation_array: Array = []

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
	
	print(track_distance_total)
	if lobby_can_select_item and !lobby_current_camera_travel_item_selected and Input.is_action_just_pressed("InputA"):
		at_item = true
		move_camera_to_or_from_lobby_item_position()

	elif lobby_current_camera_travel_item_selected:
		var movement: Vector3 = (path_point_array[0][1] * lobby_camera_travel_info_dict[str(lobby_current_camera_travel_item_selected)].speed * delta)
		camera.position += movement
		var total_distance: float = moving_lobby_camera_initial_position.distance_to(path_point_array[0][0])
		var travelled_distance: float = moving_lobby_camera_initial_position.distance_to(camera.position)
		var remove_rotation: bool = false#rotate_camera_between_points(total_distance, travelled_distance)
		if travelled_distance > total_distance:
			track_distance_travelled += travelled_distance
			points_removed += 1
			path_point_array.remove_at(0)
			if remove_rotation:
				track_distance = false
				track_distance_total = 0
				track_distance_travelled = 0
				points_removed = 0
				path_rotation_array.remove_at(0)
				
			if path_point_array.size():
				path_point_array[0].append((path_point_array[0][0] - camera.position).normalized())
				moving_lobby_camera_initial_position = camera.position
			else:
				lobby_camera_travel_finished()
				
func rotate_camera_between_points(total_distance: float, travelled_distance: float) -> bool:
	if path_rotation_array.size():
		if typeof(path_rotation_array[0]) == TYPE_VECTOR3:
			camera.rotation_degrees = camera.rotation_degrees.lerp(path_rotation_array[0], min(travelled_distance / total_distance, 1))
			return true
		elif typeof(path_rotation_array[0]) == TYPE_ARRAY:
			var current_track_distance_travelled: float = track_distance_travelled
			if !track_distance:
				track_distance_total += total_distance
				for i in range(points_removed + 1, path_rotation_array[0][2] - 1):
					track_distance_total += path_point_array[i][0].distance_to(path_point_array[i+1][0])
			
			current_track_distance_travelled += travelled_distance
			track_distance = true

			var distance_travelled: float = min(current_track_distance_travelled / track_distance_total, 1)
			if distance_travelled <= 0.999:
				camera.rotation_degrees = path_rotation_array[0][0].lerp(path_rotation_array[0][1], distance_travelled)
				return false
			return true
	return false
		
func lobby_camera_travel_finished() -> void:
	if at_item:
		lobby_current_item_selected = lobby_current_camera_travel_item_selected
		add_to_back_history.emit([on_lobby_camera_step_back, 0])
	else:
		on_lobby_step_back_finished.call()
		lobby_current_item_selected = 0
	
	points_removed = 0
	change_animation_status.emit(0)
	lobby_current_camera_travel_item_selected = 0
func move_camera_to_or_from_lobby_item_position():
	
	moving_lobby_camera_initial_position = camera.position
	for item in [lobby_can_select_item, lobby_current_item_selected]:
		if item:
			lobby_current_camera_travel_item_selected = item
		
	lobby_can_select_item = 0
	lobby_current_item_selected = 0
		
	var tilts: Array = []
	var rotations: Array = [camera.rotation_degrees]
	var path: Curve3D = load("res://screens/lobby_map/paths/%slobby-item-path.tres" % lobby_current_camera_travel_item_selected)
	if at_item:
		for i in range(1, path.point_count):
			path_point_array.append([path.get_point_position(i)])
			tilts.append(path.get_point_tilt(i))
	else:
		for i in range(path.point_count - 2, -1, -1):
			path_point_array.append([path.get_point_position(i)])
			tilts.append(path.get_point_tilt(i))
	
	for i in range(tilts.size()):
		rotations.append(tilt_to_rotation_degrees(tilts[i], rotations[i]))
		
	convert_vector_one_to_interpolate(rotations)
	
	path_rotation_array.remove_at(0)
	print(path_rotation_array)
	path_point_array[0].append((path_point_array[0][0] - camera.position).normalized())
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

	var skip_to: int = 0
	for i in range(rotations.size()):
		if !skip_to or i > skip_to:
			if i < rotations.size() - 1:
				if rotations[i + 1] == Vector3(1, 1, 1):
					for j in range(i + 1, rotations.size()):
						if rotations[j] != Vector3(1, 1, 1):
							path_rotation_array.append(rotations[i])
							path_rotation_array.append([rotations[i], rotations[j], j - i])
							skip_to = j
							break
				else:
					path_rotation_array.append(rotations[i])
			else:
				if rotations[i - 1] != Vector3(1, 1, 1):
					path_rotation_array.append(rotations[i])
func on_lobby_camera_step_back(info: Array): # location in enum [0], stepping back changer func [1]
	at_item = false
	move_camera_to_or_from_lobby_item_position()
	on_lobby_step_back_finished = info[1]
