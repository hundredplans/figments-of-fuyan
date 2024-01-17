extends Node3D

signal champion_arrived
@onready var Nodes: Node3D = $Nodes
@onready var HeavenlyLight: SpotLight3D = $HeavenlyLight
@onready var Heroes: Node = $Heroes
var GameState: Node
var node_amount: int = 0
var row_nodes: Array = []

func _ready():
	add_child(load("res://assets/base_game/areas/" + Helper.id_to_dict(GameState.area_info.id, "Area").bgfn + "/area_map.tscn").instantiate())
	add_node_row()
	
	$Camera3D.position.z = Nodes.position.z + 4.5
	on_load_base_hero()

const NodeModelPositions: Array = [
	[0],
	[-2, 2],
	[-4, 0, 4],
]

func add_node_row() -> void:
	row_nodes = GameState.map_info.nodes.filter(func(x: Array): return x[2] == GameState.map_progress.y - 1 and on_node_arrow_exists(x))
	node_amount = row_nodes.size()
	Nodes.position.z = abs(GameState.map_progress.y - 1 - GameState.map_info.map_size) * -4.5
	
	for i in range(node_amount):
		var NodeModel: Node3D = load("res://assets/env/area_map/map_nodes/" + str(row_nodes[i][0]) +".glb").instantiate()
		Nodes.add_child(NodeModel)
		NodeModel.rotation_degrees.x = -75
		NodeModel.position.x = NodeModelPositions[node_amount - 1][i]
		NodeModel.script = preload("res://assets/env/area_map/map_nodes/map_node.gd")
		NodeModel.node_type = row_nodes[i][0]
	
func on_node_arrow_exists(node_info: Array) -> bool:
	if GameState.map_progress.y < GameState.map_info.map_size:
		return GameState.map_info.arrows.any(func(x: Array): return Vector2(x[0][0], x[0][1]) == GameState.map_progress\
		and Vector2(node_info[1], node_info[2]) == Vector2(x[1][0], x[1][1]))
	return true

var HeroModel: Node3D
func on_load_base_hero() -> void:
	var model: Node3D = load("res://assets/base_game/cards/" + \
	Helper.id_to_dict(Heroes.hid_to_base(GameState.hero_id), "Card").bgfn + "/model.glb").instantiate()
	
	model.script = preload("res://assets/base_game/cards/card_ui/map_model.gd")
	HeroModel = model
	
	model.position.z = $Camera3D.position.z - 1
	add_child(model)
	model.on_add_walk_sfx(GameState.area_info.id)
	model.champion_arrived.connect(on_champion_arrived)

func on_node_selected(id: int, index: int) -> void:
	GameState.map_progress.x = id
	GameState.map_progress.y -= 1
	HeroModel.move_to(Nodes.get_child(index).global_position)

func on_node_hovered(state: bool, index: int) -> void:
	HeavenlyLight.visible = state
	if state:
		var NodeModel: Node3D = Nodes.get_child(index)
		HeavenlyLight.light_color = Helper.node_type_to_light[NodeModel.node_type]
		HeavenlyLight.position = Vector3(NodeModel.global_position.x, NodeModel.global_position.y + 2, NodeModel.global_position.z - 1)
		AudioMaster.play_sfx(AudioMaster.ID_TO_HOVER_SFX[NodeModel.node_type])
		
func on_champion_arrived() -> void:
	var index: int = Nodes.get_child(GameState.map_progress.x).node_type
	champion_arrived.emit(index)
