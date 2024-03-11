class_name LevelUIGD
extends Control
signal load_world
signal equip_sky
signal mouse_in_ui

var Heroes: HeroesGD
var Vision: VisionGD
var SpectateCamera: Node3D

@onready var PassUnitTurn := %PassUnitTurn
@onready var HandBoxPanel := $HandBoxPanel
@onready var HandBox := $HandBoxPanel/HandBox
@onready var ChangePhase: Control = %ChangePhase
@onready var StatusBox: Control = %StatusBox

var _LevelMap: PackedScene = preload("res://scenes/screens/level_map/level_map.tscn")
var LevelMap: LevelMapGD
var GameState: Node

@onready var VisionButton: Control = %VisionButton
@onready var TeamButton: Control = %TeamButton

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Tab"): on_tab_pressed()

func _ready() -> void:
	$SkipReminder.visible = false
	
	LevelMap = _LevelMap.instantiate()
	LevelMap.GameState = GameState
	LevelMap.LevelUI = self
	LevelMap.lock_inputs_changed.connect(on_lock_inputs_changed)
	
	load_world.emit(LevelMap)
	Heroes = LevelMap.Heroes
	Vision = LevelMap.Vision
	SpectateCamera = LevelMap.SpectateCamera
	equip_sky.emit(GameState.area_info.id, false)
	ChangePhase.visible = false
	PassUnitTurn.visible = false
	LevelMap.SpectateCamera.mouse_in_ui.connect(on_camera_panning)
	
	on_pin_hand_box_panel(0)
	vision_selected = VisionButton.default
	team_selected = TeamButton.default

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
		LevelMap.set_lock_inputs(false)
		on_unpin_hand_box_panel()
	else: GameCardSelected = null; on_pin_hand_box_panel(); LevelMap.set_lock_inputs(true)
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
	ChangePhase.get_node("ChangePhaseSprite").on_hyperspeed()

var last_ally: int = 0
@onready var Statuses: Control = %Statuses
func on_add_unit_status_box(Unit: UnitGD) -> void:
	var UnitStatus: Control = preload("res://scenes/screens/level_ui/unit_status/unit_status.tscn").instantiate()
	UnitStatus.Heroes = Heroes
	UnitStatus.queue_free_signal.connect(on_unit_status_queue_free)
	Statuses.add_child(UnitStatus)
	
	UnitStatus.on_set_unit(Unit)
	Unit.UnitStatus = UnitStatus
	
	if Unit.team == 0:
		Statuses.move_child(UnitStatus, last_ally)
		last_ally += 1
	
func on_unit_status_queue_free(UnitStatus: Control) -> void:
	if last_ally > 0 and UnitStatus.get_index() == last_ally: last_ally -= 1

const PANEL_MOVE_TWEEN_DURATION: float = 0.1
const HAND_BOX_PANEL_OFFSET: int = 400

func _on_panel_container_mouse_entered(): on_extended_position_container(HandBoxPanel)
func _on_panel_container_mouse_exited(): on_default_position_container(HandBoxPanel)

const HAND_BOX_INITIAL_PANEL_CONTAINER_POSITION: int = 1070
var hand_box_pinned: bool = true

func on_default_position_container(cont: PanelContainer, tween_time: float = PANEL_MOVE_TWEEN_DURATION) -> void:
	if (cont == HandBoxPanel and !is_hand_box_panel_moving and !hand_box_pinned):
		var tween_to: int = -1
		if cont.position.y != HAND_BOX_INITIAL_PANEL_CONTAINER_POSITION:
			tween_to = HAND_BOX_INITIAL_PANEL_CONTAINER_POSITION
		
		if tween_to != -1:
			on_move_panel_container(cont, tween_to, tween_time)

func on_extended_position_container(cont: PanelContainer, tween_time: float = PANEL_MOVE_TWEEN_DURATION) -> void:
	if (cont == HandBoxPanel and !is_hand_box_panel_moving):
		var tween_to: int = -1
		
		var pos: int = HAND_BOX_INITIAL_PANEL_CONTAINER_POSITION - HAND_BOX_PANEL_OFFSET
		if cont.position.y != pos: tween_to = pos
		
		if tween_to != -1:
			on_move_panel_container(cont, tween_to, tween_time)

var is_hand_box_panel_moving: bool = false
func on_move_panel_container(cont: PanelContainer, tween_to: int, tween_time: float) -> void:
	var MoveTween := get_tree().create_tween()
	MoveTween.tween_property(cont, "position:y", tween_to, tween_time)
	MoveTween.finished.connect(on_move_tween_finished)
	is_hand_box_panel_moving = true

func on_move_tween_finished() -> void:
	is_hand_box_panel_moving = false

func _on_hand_box_panel_pre_sort_children():
	HandBoxPanel.size.x = 0
	HandBoxPanel.position.x = 960 - (HandBoxPanel.size.x / 2)

func on_lock_inputs_changed(x: bool) -> void:
	if LevelMap.game_phase == "PlayerPhase":
		ChangePhase.visible = !x
		PassUnitTurn.visible = !x

var absolute_mouse_in_ui: bool
var is_mouse_in_ui: bool = false
func on_is_mouse_in_ui(x: bool, absolute_change: bool = true) -> void:
	absolute_mouse_in_ui = x and absolute_change
	is_mouse_in_ui = x
	mouse_in_ui.emit(x)
	
func on_camera_panning(x: bool) -> void:
	if !absolute_mouse_in_ui: on_is_mouse_in_ui(x, false)

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

var team_selected: int = 0
var vision_selected: int = 0
func _on_team_button_item_selected(x: int):
	team_selected = x
	for child in Statuses.get_children().filter(func(y: Control): return y.Unit != null):
		child.visible = true if (x == 2) else x == child.Unit.team
	_on_vision_button_item_selected()

func on_vision_selected(x: int) -> void:
	vision_selected = x
	_on_team_button_item_selected(team_selected)

func _on_vision_button_item_selected():
	for child in Statuses.get_children():
		if child.visible:
			if vision_selected == 0:
				child.visible = Vision.is_unit_in_unit_vision(SpectateCamera.SpectateUnit, child.Unit, true)
			elif child.Unit.team == 1:
				child.visible = Vision.is_unit_in_vision(child.Unit)

func on_update_vision() -> void:
	_on_team_button_item_selected(team_selected)

const STATUS_BOX_TRAVEL_TIME: float = 0.12
var status_box_positions: Array = [0, -400]
var status_box_state: int = 1
var is_status_box_moving: bool

func on_tab_pressed() -> void:
	if !is_status_box_moving:
		is_status_box_moving = true
		status_box_state = abs(status_box_state - 1)
		var MoveTween := get_tree().create_tween()
		MoveTween.tween_property(StatusBox, "position:x", status_box_positions[status_box_state], STATUS_BOX_TRAVEL_TIME)
		MoveTween.finished.connect(func(): is_status_box_moving = false; get_viewport().update_mouse_cursor_state())
