class_name LevelUIGD
extends Control
signal load_world
signal equip_sky

var Heroes: HeroesGD

@onready var StatusBoxPanel := $UnitStatusBoxPanel
@onready var HandBoxPanel := $HandBoxPanel
@onready var HandBox := $HandBoxPanel/HandBox
@onready var ChangePhase: Control = $ChangePhase
@onready var StatusBox: Control = $UnitStatusBoxPanel/UnitStatusBox

var _LevelMap: PackedScene = preload("res://scenes/screens/level_map/level_map.tscn")
var LevelMap: LevelMapGD
var GameState: Node

func _ready() -> void:
	StatusBoxPanel.visible = false
	var levels: Array = Helper.on_item_dicts("Level").filter(on_is_level_valid)
	GameState.level_info = levels[randi() % levels.size()]
	
	LevelMap = _LevelMap.instantiate()
	LevelMap.GameState = GameState
	LevelMap.LevelUI = self
	
	load_world.emit(LevelMap)
	Heroes = LevelMap.Heroes
	equip_sky.emit(GameState.area_info.id, false)
	ChangePhase.visible = false
	
	$Admin/ShowPhase.visible = GameState.admin
	
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
		
func on_card_placed(index: int) -> void:
	HandBox.get_child(index).queue_free()

func on_change_energy(energy: int, is_energy_max: bool) -> void:
	$Energy/Label.text = str(max(energy, 0))
	$Energy/Label.modulate = Helper.BASE if !is_energy_max else Helper.YELLOW

func on_player_end_turn_phase_start() -> void:
	ChangePhase.visible = false

func on_hand_phase_start() -> void:
	HandBoxPanel.visible = true
	ChangePhase.visible = true

func on_set_hand_box_disabled(playable_cards: Array) -> void:
	for i in range(HandBox.get_child_count()):
		HandBox.get_child(i).on_set_disabled(i not in playable_cards)

func _on_hand_phase_hitbox_pressed():
	LevelMap.on_change_game_phase("PlayerPhase")
	
func on_player_phase_start() -> void:
	if CardUISelected != null:
		CardUISelected.get_node("Art/BlackCard").material = null
		CardUISelected = null
	HandBoxPanel.visible = false

func _on_change_phase_hitbox_pressed():
	LevelMap.on_advance_game_phase()
	$ChangePhase/ChangePhaseSprite.on_hyperspeed()

func on_add_unit_status_box(Unit: UnitGD) -> void:
	var UnitStatus: Control = preload("res://scenes/screens/level_ui/unit_status/unit_status.tscn").instantiate()
	UnitStatus.Heroes = Heroes
	StatusBox.add_child(UnitStatus)
	UnitStatus.on_set_unit(Unit)
	Unit.UnitStatus = UnitStatus
	
	if UnitStatus.visible: StatusBoxPanel.visible = true

var is_panel_moving: bool = false
const PANEL_MOVE_TWEEN_DURATION: float = 0.1
const HAND_BOX_PANEL_OFFSET: int = 380
const STATUS_BOX_PANEL_OFFSET: int = 135

func _on_panel_container_mouse_entered(): on_move_panel_container(HandBoxPanel)
func _on_panel_container_mouse_exited(): on_move_panel_container(HandBoxPanel)

const STATUS_BOX_INITIAL_PANEL_CONTAINER_POSITION: int = -155
const HAND_BOX_INITIAL_PANEL_CONTAINER_POSITION: int = 1065
func on_move_panel_container(cont: PanelContainer) -> void:
	if !is_panel_moving:
		var final_val: int = 0
		match cont:
			HandBoxPanel:
				final_val = HAND_BOX_INITIAL_PANEL_CONTAINER_POSITION if cont.position.y < HAND_BOX_INITIAL_PANEL_CONTAINER_POSITION\
				else HAND_BOX_INITIAL_PANEL_CONTAINER_POSITION - HAND_BOX_PANEL_OFFSET
			StatusBoxPanel:
				final_val = STATUS_BOX_INITIAL_PANEL_CONTAINER_POSITION if cont.position.y > STATUS_BOX_INITIAL_PANEL_CONTAINER_POSITION\
				else STATUS_BOX_INITIAL_PANEL_CONTAINER_POSITION + STATUS_BOX_PANEL_OFFSET
				
		var MoveTween := get_tree().create_tween()
		MoveTween.tween_property(cont, "position:y", final_val, PANEL_MOVE_TWEEN_DURATION)
		is_panel_moving = true
		MoveTween.finished.connect(func(): is_panel_moving = false; warp_mouse(get_viewport().get_mouse_position()))

func _on_hand_box_panel_pre_sort_children():
	HandBoxPanel.size.x = 0
	HandBoxPanel.position.x = 960 - (HandBoxPanel.size.x / 2)

func _on_unit_status_box_panel_pre_sort_children():
	var enemies: Array = []
	var last_ally: int = -1
	for child in StatusBox.get_children():
		if child.Unit.team == 1: enemies.append(child)
		else: last_ally = child.get_index()
		
	if last_ally >= 0:
		for Unit in enemies:
			if Unit.get_index() < last_ally:
				StatusBox.move_child(Unit, last_ally + 1)
				last_ally -= 1
	
	StatusBoxPanel.size.x = 0
	StatusBoxPanel.position.x = 960 - ((StatusBoxPanel.size.x) / 2)

func _on_unit_status_box_panel_mouse_entered(): on_move_panel_container(StatusBoxPanel)
func _on_unit_status_box_panel_mouse_exited(): on_move_panel_container(StatusBoxPanel)
