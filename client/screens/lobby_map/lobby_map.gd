extends Node3D

var at_item: bool = false
var lobby_can_select_item: int = 0
var lobby_current_camera_travel_item_selected: int = 0
var lobby_current_item_selected: int = 0
var moving_lobby_camera_initial_position: Vector3
var path_point_array: Array = []


const lobby_camera_posrot_path := "res://static_data/lobby_camera_posrot.json"
@onready var lcps = Helper.load_json(lobby_camera_posrot_path)

const lobby_camera_travel_speed_json := "res://static_data/lobby_camera_travel_speed.json"
@onready var lobby_camera_travel_speed_dict: Dictionary = Helper.load_json(lobby_camera_travel_speed_json)

@onready var camera: Camera3D = $Camera3D

func _ready():
	for child in $LobbyAreas.get_children():
		child.mouse_entered.connect(func(): if child.name.is_valid_int() and !lobby_current_camera_travel_item_selected \
		and !lobby_current_item_selected: lobby_can_select_item = child.name.to_int())
		child.mouse_exited.connect(func(): if !lobby_current_item_selected: lobby_can_select_item = 0)

func _process(delta: float) -> void:
	
	if lobby_can_select_item and Input.is_action_just_pressed("InputA"):
		move_camera_to_or_from_lobby_item_position(false)
		at_item = true
		
	elif lobby_current_item_selected and Input.is_action_just_pressed("InputBackMenu"):
		move_camera_to_or_from_lobby_item_position(true)
		at_item = false

	elif lobby_current_camera_travel_item_selected:
		var movement: Vector3 = path_point_array[0][1] * lobby_camera_travel_speed_dict[str(lobby_current_camera_travel_item_selected)] * delta
		camera.position += movement
		if moving_lobby_camera_initial_position.distance_to(camera.position) > moving_lobby_camera_initial_position.distance_to(path_point_array[0][0]):
			path_point_array.remove_at(0)
			if path_point_array.size():
				path_point_array[0].append((path_point_array[0][0] - camera.position).normalized())
				moving_lobby_camera_initial_position = camera.position
			else:
				if at_item:
					lobby_current_item_selected = lobby_current_camera_travel_item_selected
				else:
					lobby_can_select_item = lobby_current_item_selected
					lobby_current_item_selected = 0
				lobby_current_camera_travel_item_selected = 0
					
			
func move_camera_to_or_from_lobby_item_position(backward: bool):
	moving_lobby_camera_initial_position = camera.position
	for item in [lobby_can_select_item, lobby_current_item_selected]:
		if item:
			lobby_current_camera_travel_item_selected = item
		item = 0
		
	var path: Curve3D = load("res://screens/lobby_map/paths/%slobby-item-path.tres" % lobby_current_camera_travel_item_selected)
	if !backward:
		for i in range(1, path.point_count):
			path_point_array.append([path.get_point_position(i)])
	else:
		for i in range(path.point_count - 1, 0, -1):
			print(i)
			path_point_array.append([path.get_point_position(i)])
		
	path_point_array[0].append((path_point_array[0][0] - camera.position).normalized())
