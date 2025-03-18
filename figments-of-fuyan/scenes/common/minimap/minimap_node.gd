extends Control

@onready var TxRect: TextureRect = %TextureRect
@export var WHITE_OUTLINE: ShaderMaterial
@export var FightNodeHoverUIPacked: PackedScene

var map_location: MapLocation
var links: Array

func setInfo(tx: Texture2D, _map_location: MapLocation, _links: Array, is_entered: bool) -> void: # null tx means it's a filler
	TxRect.texture = tx
	map_location = _map_location
	links = _links
	
	if is_entered:
		TxRect.material = WHITE_OUTLINE

func onIsFightNode(map_node_data: SavedDataMapNode) -> void:
	mouse_entered.connect(onMouseInUI.bind(true, map_node_data))
	mouse_exited.connect(onMouseInUI.bind(false, map_node_data))

var HoverUI: Control
signal parent_hover_ui

func onMouseInUI(state: bool, map_node_data: SavedDataMapNode) -> void:
	if !state and HoverUI != null:
		HoverUI.queue_free()
	else:
		HoverUI = load(getHoverUIPath(map_node_data)).instantiate()
		parent_hover_ui.emit(HoverUI)
		HoverUI.setInfo(map_node_data)

func getHoverUIPath(map_node_data: SavedDataMapNode) -> String:
	match map_node_data.id:
		3, 4: return "res://scenes/game/map_nodes/extra/fight_node_hover_ui.tscn"
		7, 8: return "res://scenes/game/map_nodes/extra/epic_fight_node_hover_ui.tscn"
	return ""
