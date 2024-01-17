class_name LevelUIGD
extends Control
signal load_world
signal equip_sky

@onready var Heroes: HeroesGD
@onready var HandBox := $HandBox

var _LevelMap: PackedScene = preload("res://scenes/screens/level_map/level_map.tscn")
var LevelMap: Node3D
var GameState: Node

func _ready() -> void:
	var levels: Array = Helper.on_item_dicts("Level").filter(on_is_level_valid)
	GameState.level_info = levels[randi() % levels.size()]
	
	LevelMap = _LevelMap.instantiate()
	LevelMap.GameState = GameState
	LevelMap.LevelUI = self
	
	load_world.emit(LevelMap)
	Heroes = LevelMap.Heroes
	equip_sky.emit(GameState.area_info.id, false)
	
func on_is_level_valid(level_info: Dictionary) -> bool:
	return level_info.area == GameState.area_info.id and level_info.difficulty == abs(GameState.map_progress.y - GameState.map_info.map_size)

func _queue_free() -> void:
	if !Helper.settings_loaded:
		GameState._queue_free()
		load_world.emit(null)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("SelectLeft"): LevelMap.SpectateCamera.on_select_spectate_camera_direction(-1)
	elif Input.is_action_just_pressed("SelectRight"): LevelMap.SpectateCamera.on_select_spectate_camera_direction(1)

var _CardUI: PackedScene = preload("res://assets/base_game/cards/card_ui/card_ui.tscn")
func on_draw_card(HandCard: HandCardGD) -> void:
	var CardUI: Control = _CardUI.instantiate()
	CardUI.is_hover = true
	CardUI.Heroes = Heroes
	CardUI.custom_minimum_size = Vector2(CardUI.size.x, 0)
	CardUI.set_info(Helper.id_to_dict(HandCard.id, "Card"))
	CardUI.pressed.connect(on_card_selected.bind(CardUI))
	HandBox.add_child(CardUI)
	
var _card_selected_material: Resource = preload("res://assets/base_game/cards/card_ui/card_selected_material.tres")
var CardUISelected: Control
func on_card_selected(CardUI: Control) -> void:
	var index: int = -1
	if CardUISelected != null: CardUISelected.get_node("Art/BlackCard").material = null
	if CardUI != CardUISelected:
		CardUISelected = CardUI
		CardUI.get_node("Art/BlackCard").material = _card_selected_material
		index = CardUI.get_index()
	else: CardUISelected = null
	LevelMap.Hand.on_card_selected(index)
		
