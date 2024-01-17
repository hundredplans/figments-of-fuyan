extends Node3D
var GameState: Node

var LoadedLevel: Node3D
var Tiles: TilesGD
var LevelUI: Control

@onready var BaseCards: BaseCardsGD = $BaseCards
@onready var Heroes: HeroesGD = $Heroes
@onready var Deck: DeckGD = $Deck
@onready var Hand: HandGD = $Hand
@onready var History: HistoryGD = $History
@onready var Units: UnitsGD = $Units

@onready var SpectateCamera: Camera3D = $SpectateCamera
@onready var Vision: Node3D = $Vision

func on_set_utility_nodes_paths() -> void:
	var new_children: Array = get_children() + [GameState, Tiles, LevelUI]
	for child in new_children:
		for _child in new_children:
			if child != _child and _child.name in child:
				child[_child.name] = _child

func _ready() -> void:
	on_load_default_world_state()
	History.on_load_world_history()
	Vision.on_recalculate_vision()
	Deck.on_create_deck()
	Deck.on_choose_champion()

func on_load_default_world_state() -> void:
	LoadedLevel = load("res://assets/base_game/levels/" + GameState.level_info.bgfn + "/loaded_level.tscn").instantiate()
	LoadedLevel.script = null
	
	LoadedLevel.get_node("Tiles").script = preload("res://scenes/screens/level_map/utility_nodes/tiles/tiles.gd")
	Tiles = LoadedLevel.get_node("Tiles")
	
	on_set_utility_nodes_paths()
	
	add_child(LoadedLevel)
	SpectateCamera.on_spectate("Spawn")
