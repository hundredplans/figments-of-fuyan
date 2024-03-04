class_name LevelUIGD
extends Control
signal load_world
signal equip_sky
signal mouse_in_ui

var Heroes: HeroesGD


@onready var PassUnitTurn := %PassUnitTurn
@onready var StatusBoxPanel := $UnitStatusBoxPanel
@onready var HandBoxPanel := $HandBoxPanel
@onready var HandBox := $HandBoxPanel/HandBox
@onready var ChangePhase: Control = $ChangePhase
@onready var StatusBox: Control = $UnitStatusBoxPanel/UnitStatusBox

var _LevelMap: PackedScene = preload("res://scenes/screens/level_map/level_map.tscn")
var LevelMap: LevelMapGD
var GameState: Node

func _ready() -> void:
	$SkipReminder.visible = false
	StatusBoxPanel.visible = false
	
	LevelMap = _LevelMap.instantiate()
	LevelMap.GameState = GameState
	LevelMap.LevelUI = self
	LevelMap.lock_inputs_changed.connect(on_lock_inputs_changed)
	
	load_world.emit(LevelMap)
	Heroes = LevelMap.Heroes
	equip_sky.emit(GameState.area_info.id, false)
	ChangePhase.visible = false
	PassUnitTurn.visible = false
	
	$Admin/ShowPhase.visible = GameState.admin
	on_pin_hand_box_panel(0)

func _queue_free() -> void:
	if !Helper.settings_loaded:
		GameState._queue_free()
		load_world.emit(null)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("SelectLeft") and !LevelMap.lock_inputs: LevelMap.SpectateCamera.on_select_spectate_camera_direction(-1)
	elif Input.is_action_just_pressed("SelectRight") and !LevelMap.lock_inputs: LevelMap.SpectateCamera.on_select_spectate_camera_direction(1)

var _GameCard: PackedScene = preload("res://assets/base_game/cards/game_card/game_card.tscn")
func on_draw_card(HandCard: HandCardGD) -> void:
	var GameCard: Control = _GameCard.instantiate()
	GameCard.is_hover = true
	GameCard.Heroes = Heroes
	GameCard.custom_minimum_size = Vector2(GameCard.size.x, 0)
	GameCard.set_info(Helper.id_to_dict(HandCard.id, "Card"))
	GameCard.pressed.connect(on_card_selected.bind(GameCard))
	HandBox.add_child(GameCard)
	
var _card_selected_material: Resource = preload("res://assets/base_game/cards/card_ui/card_selected_material.tres")
var GameCardSelected: Control
func on_card_selected(GameCard: Control) -> void:
	var index: int = -1
	if GameCardSelected != null: GameCardSelected.Art.get_node("CardButton").material = null
	if GameCard != GameCardSelected:
		GameCardSelected = GameCard
		GameCardSelected.Art.get_node("CardButton").material = _card_selected_material
		index = GameCard.get_index()
		on_unpin_hand_box_panel()
	else: GameCardSelected = null; on_pin_hand_box_panel()
	LevelMap.Hand.on_card_selected(index)
		
func on_card_placed(index: int) -> void:
	HandBox.get_child(index).queue_free()

func on_change_energy(energy: int, is_energy_max: bool) -> void:
	$Energy/Label.text = str(max(energy, 0))
	$Energy/Label.modulate = Helper.BASE if !is_energy_max else Helper.YELLOW

func on_player_end_turn_phase_start() -> void:
	ChangePhase.visible = false
	PassUnitTurn.visible = false

func on_hand_phase_start(skip_hand_phase: bool) -> void:
	if !skip_hand_phase: on_pin_hand_box_panel()
	HandBoxPanel.visible = HandBox.get_child_count() > 0
	on_set_hand_box_cards_state()
	ChangePhase.visible = true

var playable_cards: Array
func on_set_hand_box_cards_state() -> void:
	var state: bool = LevelMap.game_phase != "HandPhase"
	for i in range(HandBox.get_child_count()):
		HandBox.get_child(i).on_set_disabled(state or i not in playable_cards)

func _on_hand_phase_hitbox_pressed():
	LevelMap.on_change_game_phase("PlayerPhase")
	
func on_player_phase_start() -> void:
	if GameCardSelected != null:
		GameCardSelected.Art.get_node("CardButton").material = null
		GameCardSelected = null
		
	PassUnitTurn.visible = true
	on_set_hand_box_cards_state()
	on_unpin_hand_box_panel()

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

const PANEL_MOVE_TWEEN_DURATION: float = 0.1
const HAND_BOX_PANEL_OFFSET: int = 400
const STATUS_BOX_PANEL_OFFSET: int = 130

func _on_panel_container_mouse_entered(): on_extended_position_container(HandBoxPanel)
func _on_panel_container_mouse_exited(): on_default_position_container(HandBoxPanel)

const STATUS_BOX_INITIAL_PANEL_CONTAINER_POSITION: int = -145
const HAND_BOX_INITIAL_PANEL_CONTAINER_POSITION: int = 1070
var hand_box_pinned: bool = true

func on_default_position_container(cont: PanelContainer, tween_time: float = PANEL_MOVE_TWEEN_DURATION) -> void:
	if (cont == HandBoxPanel and !is_hand_box_panel_moving and !hand_box_pinned) or (cont == StatusBoxPanel and !is_status_box_panel_moving):
		var tween_to: int = -1
		match cont:
			HandBoxPanel:
				if cont.position.y != HAND_BOX_INITIAL_PANEL_CONTAINER_POSITION:
					tween_to = HAND_BOX_INITIAL_PANEL_CONTAINER_POSITION
					
			StatusBoxPanel:
				var pos: int = STATUS_BOX_INITIAL_PANEL_CONTAINER_POSITION - (STATUS_BOX_PANEL_OFFSET + 15)\
				* (ceil(StatusBox.get_children().filter(func(x: Node): return x.visible).size() * 0.25) - 1)
				
				if cont.position.y != pos: tween_to = pos
		
		if tween_to != -1:
			on_move_panel_container(cont, tween_to, tween_time)

func on_extended_position_container(cont: PanelContainer, tween_time: float = PANEL_MOVE_TWEEN_DURATION) -> void:
	if (cont == HandBoxPanel and !is_hand_box_panel_moving) or (cont == StatusBoxPanel and !is_status_box_panel_moving):
		var tween_to: int = -1
		match cont:
			HandBoxPanel:
				var pos: int = HAND_BOX_INITIAL_PANEL_CONTAINER_POSITION - HAND_BOX_PANEL_OFFSET
				if cont.position.y != pos: tween_to = pos
					
			StatusBoxPanel:
				var pos: int = STATUS_BOX_INITIAL_PANEL_CONTAINER_POSITION + STATUS_BOX_PANEL_OFFSET
				if cont.position.y != pos: tween_to = pos
					
		if tween_to != -1:
			on_move_panel_container(cont, tween_to, tween_time)

var is_hand_box_panel_moving: bool = false
var is_status_box_panel_moving: bool = false
func on_move_panel_container(cont: PanelContainer, tween_to: int, tween_time: float) -> void:
	var MoveTween := get_tree().create_tween()
	MoveTween.tween_property(cont, "position:y", tween_to, tween_time)
	MoveTween.finished.connect(on_move_tween_finished.bind(cont))
	
	match cont:
		HandBoxPanel: is_hand_box_panel_moving = true
		StatusBoxPanel: is_status_box_panel_moving = true

func on_move_tween_finished(cont: PanelContainer) -> void:
	match cont:
		HandBoxPanel: is_hand_box_panel_moving = false
		StatusBoxPanel: is_status_box_panel_moving = false

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
	
	StatusBoxPanel.size = Vector2.ZERO
	StatusBoxPanel.position.x = 960 - ((StatusBoxPanel.size.x) / 2)
	
	if !is_mouse_in_status_box_panel:
		on_extended_position_container(StatusBoxPanel)
		await get_tree().create_timer(STATUS_BOX_RESORT_DELAY).timeout
		if !is_mouse_in_status_box_panel:
			on_default_position_container(StatusBoxPanel)

const STATUS_BOX_RESORT_DELAY: float = 1.2
var is_mouse_in_status_box_panel: bool = false
func _on_unit_status_box_panel_mouse_entered(): on_extended_position_container(StatusBoxPanel); is_mouse_in_status_box_panel = true
func _on_unit_status_box_panel_mouse_exited(): on_default_position_container(StatusBoxPanel); is_mouse_in_status_box_panel = false
func on_lock_inputs_changed(x: bool) -> void:
	ChangePhase.visible = !x
	PassUnitTurn.visible = !x

var is_mouse_in_ui: bool = false
func on_is_mouse_in_ui(x: bool) -> void: 
	is_mouse_in_ui = x
	mouse_in_ui.emit(x)

func on_hand_box_calculate_visibility(__: Control, offset: int = 0):
	if !is_queued_for_deletion():
		HandBoxPanel.visible = HandBox.get_child_count() > 0 + offset

func on_camera_arrow_pressed(direction: int) -> void:
	LevelMap.SpectateCamera.on_select_spectate_camera_direction(direction)

func on_pin_hand_box_panel(time: float = PANEL_MOVE_TWEEN_DURATION) -> void:
	hand_box_pinned = true
	on_extended_position_container(HandBoxPanel, time)
	$GreyScale.visible = true

func on_unpin_hand_box_panel(time: float = PANEL_MOVE_TWEEN_DURATION) -> void:
	hand_box_pinned = false
	on_default_position_container(HandBoxPanel, time)
	$GreyScale.visible = false

func on_ally_unit_awakened(skip_result: bool) -> void:
	if !skip_result: on_pin_hand_box_panel()

func _on_pass_unit_turn_button_pressed():
	LevelMap.Units.PlayerManager.on_pass_unit_turn()

func on_pass_unit_turn_button_state(x: bool) -> void:
	PassUnitTurn.modulate = Helper.BASE if !x else Helper.LIGHT_GREY
	PassUnitTurn.get_node("PassUnitTurnButton").disabled = x
