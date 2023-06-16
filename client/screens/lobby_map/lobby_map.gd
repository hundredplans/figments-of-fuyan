extends Node3D

var lobby_can_select_item: int = 0
var lobby_current_item_selected: int = 0
var path_point_array: Array = []

const lobby_camera_posrot_path := "res://static_data/lobby_camera_posrot.json"
@onready var lcps = Helper.load_json(lobby_camera_posrot_path)

@onready var lobby_camera_normalized_timer: Timer = $LobbyCameraNormalizedTimer
const lobby_camera_travel_time_json := "res://static_data/lobby_camera_travel_time.json"
@onready var lobby_camera_travel_time_dict: Dictionary = Helper.load_json(lobby_camera_travel_time_json)

@onready var camera: Camera3D = $Camera3D

func _ready():
	for child in $LobbyAreas.get_children():
		child.mouse_entered.connect(func(): if child.name.is_valid_int() and !lobby_current_item_selected: \
		lobby_can_select_item = child.name.to_int())
		child.mouse_exited.connect(func(): if !lobby_current_item_selected: lobby_can_select_item = 0)

func _process(delta: float) -> void:
	if lobby_can_select_item and Input.is_action_just_pressed("InputA"):
		lobby_current_item_selected = lobby_can_select_item
		lobby_can_select_item = 0
		move_camera_to_lobby_item_position()
	
	elif lobby_current_item_selected:
		if !lobby_camera_normalized_timer.is_stopped():
			print(lobby_camera_normalized_timer.time_left)
			var progress_ratio: float = lobby_camera_normalized_timer.time_left / lobby_camera_normalized_timer.wait_time
			var distance: Vector3 = (path_point_array[0] * progress_ratio * delta)
			print(distance)
			
		elif path_point_array:
			print("here")
			path_point_array.remove_at(0)
			if path_point_array:
				lobby_camera_normalized_timer.start()
				

func move_camera_to_lobby_item_position():
	var path: Curve3D = load("res://screens/lobby_map/paths/%slobby-item-path.tres" % lobby_current_item_selected)
	for i in range(path.point_count):
		path_point_array.append(path.get_point_position(i))
	lobby_camera_normalized_timer.start(lobby_camera_travel_time_dict[str(lobby_current_item_selected)] / path_point_array.size())
