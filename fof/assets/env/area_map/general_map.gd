extends Node3D

@onready var HeavenlyLight: SpotLight3D = $HeavenlyLight
@onready var Heroes: Node = $Heroes
var GameState: Node
var AreaMap: Node3D

func _ready():
	AreaMap = load("res://assets/base_game/areas/" + Helper.id_to_dict(GameState.area_info.id, "Area").bgfn + "/area_map.tscn").instantiate()
	add_child(AreaMap)
	
	var Markers: Node3D = AreaMap.get_node("Markers")
	var map_info: Dictionary = Helper.id_to_dict(GameState.map_info.id, "Map")
	for node_info in map_info.nodes:
		if node_info[0] != 0:
			Markers.get_child(node_info[2]).get_child(node_info[1]).add_child(\
			load("res://assets/env/area_map/map_nodes/" + str(node_info[0]) +".glb").instantiate())
	
	if GameState.map_progress.y < GameState.map_info.map_size: 
		$Camera3D.position = Vector3(0, $Camera3D.position.y,\
		Markers.get_node(str(GameState.map_progress.y - 1)).get_node(str(GameState.map_progress.x)).global_position.z + 4.5)
		Markers.get_node(str(GameState.map_progress.y)).visible = false
		
		var is_marker_visible: bool = false
		for i in range(0, 3):
			is_marker_visible = false
			for node_info in GameState.map_info.arrows:
				if Vector2(node_info[0][0], node_info[0][1]) == GameState.map_progress and node_info[1][0] == i:
					is_marker_visible = true
					break
			Markers.get_node(str(GameState.map_progress.y - 1)).get_node(str(i)).visible = is_marker_visible
	on_load_base_hero()

var HeroModel: Node3D
func on_load_base_hero() -> void:
	var model: Node3D = load("res://assets/base_game/cards/" + \
	Helper.id_to_dict(Heroes.hid_to_base(GameState.hero_id), "Card").bgfn + "/model.glb").instantiate()
	
	model.script = preload("res://assets/base_game/cards/card/map_model.gd")
	HeroModel = model
	
	model.position.z = $Camera3D.position.z - 1
	add_child(model)
	model.on_add_walk_sfx(GameState.area_info.id)
	model.champion_arrived.connect(on_champion_arrived)

func on_node_selected(i: int) -> void:
	GameState.map_progress.x = i
	GameState.map_progress.y -= 1
	
	var marker_node: Marker3D = AreaMap.get_node("Markers").get_node(str(GameState.map_progress.y)).get_node(str(i))
	HeroModel.move_to(marker_node.global_position, (i - 1) * -30)

func on_node_hovered(state: bool, id: int) -> void:
	HeavenlyLight.visible = state
	if state:
		var marker_node: Marker3D = AreaMap.get_node("Markers").get_node(str(GameState.map_progress.y - 1)).get_node(str(id))
		var node_type: int = int(str(marker_node.get_child(0).name))
		HeavenlyLight.light_color = Helper.node_type_to_light[node_type]
		HeavenlyLight.position = Vector3(marker_node.global_position.x, marker_node.global_position.y + 2, marker_node.global_position.z - 1)

func on_champion_arrived() -> void:
	pass
