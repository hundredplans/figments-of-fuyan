extends Node3D

signal champion_arrived
@onready var Nodes: Node3D = $Nodes
@onready var HeavenlyLight: SpotLight3D = $HeavenlyLight
var GameState: Node
var node_amount: int = 0
var row_nodes: Array = []

func _ready():
	add_child(load("res://assets/base_game/areas/" + Helper.getFofInfo(GameState.save_info.area_info.id, "area").folder_name + "/area_map.tscn").instantiate())
	add_node_row()
	
	$Camera3D.position.z = Nodes.position.z + 4.5
	on_load_base_hero()

const NodeModelPositions: Array = [
	[0],
	[-2, 2],
	[-4, 0, 4],
]

func add_node_row() -> void:
	row_nodes = GameState.save_info.map_info.nodes.filter(func(x: Array): return x[2] == GameState.save_info.map_progress.y - 1 and on_node_arrow_exists(x))
	node_amount = row_nodes.size()
	Nodes.position.z = abs(GameState.save_info.map_progress.y - 1 - GameState.save_info.map_info.map_size) * -4.5
	
	for i in range(node_amount):
		var NodeModel: Node3D = load("res://assets/env/area_map/map_nodes/" + str(row_nodes[i][0]) +".glb").instantiate()
		Nodes.add_child(NodeModel)
		NodeModel.rotation_degrees.x = -75
		NodeModel.position.x = NodeModelPositions[node_amount - 1][i]
		NodeModel.script = preload("res://assets/env/area_map/map_nodes/map_node.gd")
		NodeModel.node_type = row_nodes[i][0]
	
func on_node_arrow_exists(node_info: Array) -> bool:
	if GameState.save_info.map_progress.y < GameState.save_info.map_info.map_size:
		return GameState.save_info.map_info.arrows.any(func(x: Array): return Vector2(x[0][0], x[0][1]) == GameState.save_info.map_progress\
		and Vector2(node_info[1], node_info[2]) == Vector2(x[1][0], x[1][1]))
	return true

var HeroModel: Node3D
func on_load_base_hero() -> void:
	var model: Node3D = load("res://assets/base_game/cards/cards/" + \
	Helper.getHeroCardInfo(GameState.save_info.hero_id).base_cards[0].folder_name + "/model.glb").instantiate()
	
	model.script = preload("res://assets/base_game/cards/game_card/models/map_model.gd")
	HeroModel = model
	
	model.position.z = $Camera3D.position.z - 1
	add_child(model)
	model.on_add_walk_sfx(GameState.save_info.area_info.id)
	model.champion_arrived.connect(on_champion_arrived)

func on_node_selected(id: int, index: int) -> void:
	GameState.save_info.map_progress.x = id
	GameState.save_info.map_progress.y -= 1
	HeroModel.move_to(Nodes.get_child(index).global_position)

func on_node_hovered(state: bool, index: int) -> void:
	HeavenlyLight.visible = state
	if state:
		var NodeModel: Node3D = Nodes.get_child(index)
		HeavenlyLight.light_color = Helper.node_type_to_light[NodeModel.node_type]
		HeavenlyLight.position = Vector3(NodeModel.global_position.x, NodeModel.global_position.y + 2, NodeModel.global_position.z - 1)
		AudioMaster.play_sfx(AudioMaster.ID_TO_HOVER_SFX[NodeModel.node_type])
		
func on_champion_arrived() -> void:
	var index: int = Nodes.get_child(GameState.save_info.map_progress.x - 3 + Nodes.get_child_count()).node_type
	champion_arrived.emit(index)
