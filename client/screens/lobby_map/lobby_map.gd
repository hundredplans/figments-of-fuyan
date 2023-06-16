extends Node3D
var lobby_can_select_item: int = 0
var lobby_current_item_selected: int = 0

const lobby_camera_posrot_path := "res://static_data/lobby_camera_posrot.json"
@onready var lcps = Helper.load_json(lobby_camera_posrot_path)
signal lobby_item_selected

func _ready():
	var path = load("res://screens/lobby_map/paths/3lobby-item-path.tres")
	var baked_goods = path.get_baked_points()
	for i in baked_goods:
		print(i)
	for child in $LobbyAreas.get_children():
		child.mouse_entered.connect(func(): if child.name.is_valid_int() and !lobby_current_item_selected: \
		lobby_can_select_item = child.name.to_int())
		child.mouse_exited.connect(func(): if !lobby_current_item_selected: lobby_can_select_item = 0)

func _process(_delta: float) -> void:
	if lobby_can_select_item and Input.is_action_just_pressed("InputA"):
		lobby_current_item_selected = lobby_can_select_item
		lobby_can_select_item = 0
		lobby_item_selected.emit(lobby_current_item_selected)
