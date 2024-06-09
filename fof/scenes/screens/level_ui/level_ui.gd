class_name LevelUIGD
extends Control

signal screen_change_sig
signal load_world
signal equip_sky
signal mouse_in_ui

var Combat: CombatGD
var Tiles: TilesGD
var Vision: VisionGD
var SpectateCamera: Node3D
var Units: UnitsGD
var Hand: HandGD
var Deck: DeckGD
var PlayerManager: PlayerManagerGD

@onready var EnemySpottedArrows: Control = %EnemySpottedArrows
@onready var DrawCard: Control = %DrawCard
@onready var AbilityDescription: RichTextLabel = %AbilityDescription
@onready var AbilityLabel: Label = %AbilityLabel
@onready var UnitNameLabel: Label = %UnitNameLabel
@onready var TargetAbilities: VBoxContainer = %TargetAbilities
@onready var Console := %Console
@onready var VisionMode := %VisionMode

@onready var PassUnitTurn: TextureButton = %PassUnitTurn
@onready var ChangePhase: Control = %ChangePhase
@onready var StatusBox: Control = %StatusBox
@onready var CameraArrows: Control = %CameraArrows

var _LevelMap: PackedScene = preload("res://scenes/screens/level_map/level_map.tscn")
var LevelMap: Node3D
var GameState: Node
@onready var WarningText: Label = %WarningText

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Tab"): on_tab_pressed()

func _ready() -> void:
	setUnitModeText("")
	setWarningText(false)
	
	LevelMap = _LevelMap.instantiate()
	LevelMap.GameState = GameState
	LevelMap.LevelUI = self
	LevelMap.action_lock_changed.connect(onActionLockChanged)
	
	load_world.emit(LevelMap)
	Vision = LevelMap.Vision
	SpectateCamera = LevelMap.SpectateCamera
	equip_sky.emit(GameState.area_info.id, false)
	setCornerRightVisibile(false)
	LevelMap.SpectateCamera.mouse_in_ui.connect(on_camera_panning)
	
	var old: float = PANEL_MOVE_TWEEN_DURATION
	PANEL_MOVE_TWEEN_DURATION = 0
	on_pin_hand_box_panel()
	PANEL_MOVE_TWEEN_DURATION = old
	
@onready var CornerRightMenu = %CornerRightMenu
func setCornerRightVisibile(state: bool) -> void:
	var dev := preload("res://static/dev/dev.tres")
	if dev.remove_action_lock: state = true
	for child in CornerRightMenu.get_children(): child.visible = state

func _queue_free(screen_name: String) -> void:
	if screen_name not in ["LoseScreen", "SettingsMenu", "WinScreen"]:
		GameState._queue_free()
		load_world.emit(null)

func _input(event: InputEvent) -> void:
	if !Console.CommandLine.has_focus() and LevelMap != null and LevelMap.action_lock in ["", "HandRegular", "SpawnVision"]:
		if Input.is_action_just_pressed("SelectLeft"): LevelMap.SpectateCamera.onSpectate(-1)
		elif Input.is_action_just_pressed("SelectRight"): LevelMap.SpectateCamera.onSpectate(1)
	
	if event is InputEventMouseMotion:
		onMoveTileHoveredGameCard()
		
@onready var CardBox: HBoxContainer = %CardBox

var _GameCard: PackedScene = preload("res://assets/base_game/cards/game_card/game_card.tscn")
func on_draw_card(HandCard: HandCardGD) -> void:
	if HandCard.id not in range(1, 7)	: # fix this it's so dodgy
		var GameCard: Control = _GameCard.instantiate()
		GameCard.set_info(Helper.getCard(HandCard.id))
		DrawCard.add_child(GameCard)
		if LevelMap.game_phase == "PlayerPhase": GameCard.on_set_disabled(true)
		onTweenDrawCard(GameCard, HandCard)
	else: onDrawCard(HandCard)
	
func onDrawCard(HandCard: HandCardGD) -> void:
	var GameCard: Control = _GameCard.instantiate()
	GameCard.is_hover = true
	GameCard.custom_minimum_size = Vector2(GameCard.size.x, 0)
	GameCard.set_info(Helper.getCard(HandCard.id))
	GameCard.pressed.connect(on_card_selected.bind(GameCard))
	if LevelMap.game_phase == "PlayerPhase": GameCard.on_set_disabled(true)
	CardBox.add_child(GameCard)
	
var _card_selected_material: Resource = preload("res://assets/base_game/cards/game_card/materials/card_selected_material.tres")
var GameCardSelected: Control
func on_card_selected(GameCard: Control) -> void:
	var index: int = -1
	if GameCardSelected != null: GameCardSelected.Art.get_node("CardButton").material = null
	if GameCard != GameCardSelected:
		GameCardSelected = GameCard
		GameCardSelected.Art.get_node("CardButton").material = _card_selected_material
		index = GameCard.get_index()
		LevelMap.setActionLock("SpawnVision")
		on_unpin_hand_box_panel()
		CameraArrows.visible = true
	else: 
		GameCardSelected = null
		on_pin_hand_box_panel()
		LevelMap.setActionLock("HandRegular")
		CameraArrows.visible = false
	LevelMap.Hand.on_card_selected(index)
		
func on_card_placed(index: int) -> void:
	CardBox.get_child(index).queue_free()
	Vision.on_vision_mode_set(0)

func on_change_energy(energy: int, is_energy_max: bool) -> void:
	$Energy/Label.text = str(max(energy, 0))
	$Energy/Label.modulate = Helper.BASE if !is_energy_max else Helper.YELLOW

func on_player_end_turn_phase_start() -> void:
	setCornerRightVisibile(false)
	on_pass_unit_turn_button_state(false)
	UnitStatusOverlord.onPlayerEndTurnPhaseStart()

@onready var HandBox: Control = %HandBox

func onAfterStartPhaseStart() -> void:
	PhaseIcon.visible = true

func on_hand_phase_start(skip_hand_phase: bool) -> void:
	if !skip_hand_phase: on_pin_hand_box_panel()
	on_set_hand_box_cards_state()
	ChangePhase.visible = true
	onChangePhaseIcon("HandPhase")

var playable_cards: Array
func on_set_hand_box_cards_state() -> void:
	var state: bool = LevelMap.game_phase != "HandPhase"
	for i in range(CardBox.get_child_count()):
		CardBox.get_child(i).on_set_disabled(state or i not in playable_cards)
	
func on_player_phase_start() -> void:
	if GameCardSelected != null:
		GameCardSelected.Art.get_node("CardButton").material = null
		GameCardSelected = null
		
	VisionMode.visible = true
	on_set_hand_box_cards_state()
	on_unpin_hand_box_panel()
	onChangePhaseIcon("PlayerPhase")
	GreyScale.modulate.a = 0

func onPassUnitTurnButtonPressed():
	if PlayerManager.unpassed_turns.is_empty():
		LevelMap.on_advance_game_phase()
	else:
		PlayerManager.on_pass_unit_turn_pressed()

@onready var Statuses: Control = %Statuses
func onSpectateEnemyOrAlly(Unit: UnitGD) -> void:
	if Units.unit_actions.is_empty() and LevelMap.action_lock in ["", "HandRegular", "SpawnVision"]:
		SpectateCamera.onSpectate(Unit)

func on_extend_hand_box() -> void:
	var dev := preload("res://static/dev/dev.tres")
	if !dev.god_start:
		if !is_hand_box_panel_moving and HandBox.position.y == HAND_BOX_INITIAL_PANEL_CONTAINER_POSITION:
			on_move_hand_box(HAND_BOX_INITIAL_PANEL_CONTAINER_POSITION - HAND_BOX_PANEL_OFFSET)
	
func on_unextend_hand_box() -> void:
	if !is_hand_box_panel_moving and !hand_box_pinned and HandBox.position.y == HAND_BOX_INITIAL_PANEL_CONTAINER_POSITION - HAND_BOX_PANEL_OFFSET:
		on_move_hand_box(HAND_BOX_INITIAL_PANEL_CONTAINER_POSITION)
		
func on_move_hand_box(to: int) -> void:
	var MoveTween := create_tween()
	MoveTween.tween_property(HandBox, "position:y", to, PANEL_MOVE_TWEEN_DURATION)
	MoveTween.finished.connect(on_move_tween_finished)
	is_hand_box_panel_moving = true
	
var PANEL_MOVE_TWEEN_DURATION: float = 0.1
const HAND_BOX_PANEL_OFFSET: int = 405
const HAND_BOX_INITIAL_PANEL_CONTAINER_POSITION: int = 1075
var hand_box_pinned: bool = true
var is_hand_box_panel_moving: bool = false

func on_move_tween_finished() -> void:
	is_hand_box_panel_moving = false

func onActionLockChanged(action_lock: String) -> void:
	if LevelMap.game_phase == "PlayerPhase":
		ChangePhase.visible = action_lock not in ["UnitActionRegular", "Regular"]
		setCornerRightVisibile(action_lock.is_empty())

var absolute_mouse_in_ui: bool
var is_mouse_in_ui: bool = false
func on_is_mouse_in_ui(x: bool, absolute_change: bool = true) -> void:
	absolute_mouse_in_ui = x and absolute_change
	is_mouse_in_ui = x
	mouse_in_ui.emit(x)
	
func on_camera_panning(x: bool) -> void:
	if !absolute_mouse_in_ui: on_is_mouse_in_ui(x, false)

func on_camera_arrow_pressed(direction: int) -> void:
	if LevelMap.action_lock in ["", "HandRegular", "SpawnVision"]: LevelMap.SpectateCamera.onSpectate(direction)

const greyscale_light: float = 0.3
@onready var GreyScale: ColorRect = %GreyScale
func on_pin_hand_box_panel() -> void:
	hand_box_pinned = true
	on_extend_hand_box()

func on_unpin_hand_box_panel() -> void:
	hand_box_pinned = false
	on_unextend_hand_box()

func on_ally_unit_awakened(skip_result: bool) -> void:
	if !skip_result: on_pin_hand_box_panel()

func on_pass_unit_turn_button_state(x: bool) -> void:
	PassUnitTurn.disabled = x

var team_selected: int = 0
var vision_selected: int = 0
func _on_team_button_item_selected(x: int):
	team_selected = x
	for child in Statuses.get_children():
		child.visible = true if (x == 2) else x == child.Unit.team
	_on_vision_button_item_selected()

func on_vision_selected(x: int) -> void:
	vision_selected = x
	_on_team_button_item_selected(team_selected)

func _on_vision_button_item_selected():
	var SpectateUnit: UnitGD = SpectateCamera.SpectateUnit
	if SpectateUnit != null:
		for child in Statuses.get_children():
			if child.visible:
				if vision_selected == 0:
					child.visible = Vision.isUnitInUnitVisionSafe(SpectateUnit, child.Unit)
				elif child.Unit.team == 1:
					child.visible = child.Unit.Tile in Vision.getTeamVision()
	elif vision_selected == 0:
		for child in Statuses.get_children(): child.visible = false
	elif vision_selected == 1:
		for child in Statuses.get_children():
			if child.Unit.team == 1: child.visible = child.Unit.Tile in Vision.getTeamVision()

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
		var MoveTween := create_tween()
		MoveTween.tween_property(StatusBox, "position:x", status_box_positions[status_box_state], STATUS_BOX_TRAVEL_TIME)
		MoveTween.finished.connect(func(): is_status_box_moving = false; get_viewport().update_mouse_cursor_state())

@onready var UnitStatusState: Control = %UnitStatusState
@onready var UnitStatusOverlord: Node = %UnitStatusOverlord

func _on_vision_mode_set():
	Vision.on_vision_mode_set(1 if Vision.vision_mode == 0 else 0)

func onVisionModeSet() -> void:
	GreyScale.modulate.a = greyscale_light if Vision.vision_mode == 1 else 0.0
	
func onStartPhaseStart() -> void:
	ChangePhase.visible = false
	PhaseIcon.visible = false
	
	UnitStatusOverlord.onStartPhaseStart()
	GreyScale.modulate.a = greyscale_light
	_on_team_button_item_selected(team_selected)
	Tiles.console_tile_selected.connect(onSelectTileFinish)

func _on_card_clipper_child_entered_tree(node):
	if node is HScrollBar:
		node.mouse_filter = MOUSE_FILTER_PASS

func onLoseGame() -> void:
	if get_node("../../../..") == get_tree().get_root():
		screen_change_sig.emit("res://scenes/screens/lose_screen/lose_screen.tscn")
	else: print_debug("You lost the game")

func onWinGame() -> void:
	if get_node("../../../..") == get_tree().get_root():
		screen_change_sig.emit("res://scenes/screens/win_screen/win_screen.tscn")
	else: print_debug("You won the game")

func onAIPhaseStart() -> void:
	ChangePhase.visible = false
	onChangePhaseIcon("AIPhase")
	UnitStatusOverlord.onAIPhaseStart()

const PHASE_ICON_CHANGE_DURATION: float = 0.2
@onready var PhaseIcon: Sprite2D = %PhaseIcon
func onChangePhaseIcon(phase: String) -> void:
	var ScaleTween := create_tween()
	ScaleTween.tween_property(PhaseIcon, "scale:y", 0, PHASE_ICON_CHANGE_DURATION)
	ScaleTween.finished.connect(onFinishChangePhaseIcon.bind(phase))

func onFinishChangePhaseIcon(phase: String) -> void:
	var ScaleTween := create_tween()
	ScaleTween.tween_property(PhaseIcon, "scale:y", 2, PHASE_ICON_CHANGE_DURATION)
	PhaseIcon.texture = load("res://scenes/screens/level_ui/phase_icon/" + phase + ".png")

const SKIP_HAND_TURN_DELAY: float = 1.2
func onHandPhaseNoSpawnTiles() -> void:
	setWarningText(true, "SkipHandTurn")
	await get_tree().create_timer(SKIP_HAND_TURN_DELAY).timeout
	setWarningText(false)

func onHandPhaseStart() -> void:
	ChangePhase.visible = true
	GreyScale.modulate.a = greyscale_light

var warning_texts: Dictionary = {
	"SkipAction": "If you perform an action with this unit you will skip another unit's turn!",
	"SkipHandTurn": "There are no valid spawn tiles! Skipping to the Player Phase",
	"ConsoleActive": "Select a Tile"
}

func setWarningText(visibility: bool, text: String = "") -> void:
	WarningText.visible = visibility
	if visibility:
		WarningText.text = warning_texts[text]

func onAIEndTurnPhaseStart() -> void:
	UnitStatusOverlord.onAIEndTurnPhaseStart()

var TileHoveredGameCard: Control
const TILE_HOVERED_DELAY: float = 0.6

func onTileHoveredDisplayCard(Tile: TileGD) -> void:
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	if Unit != null:
		await get_tree().create_timer(TILE_HOVERED_DELAY).timeout
		if TileHoveredGameCard == null and Tiles.active_tile == Tile and Units.unit_by_tile_bool(Tile):
			onCreateTileHoveredGameCard(Unit)
			
func onCreateTileHoveredGameCard(Unit: UnitGD) -> void:
	TileHoveredGameCard = preload("res://scenes/screens/level_ui/tile_hovered_game_card.tscn").instantiate()
	add_child(TileHoveredGameCard)
	TileHoveredGameCard.setUnit(Unit)
	UnitStatusOverlord.onCreateTileHoveredUnitStatus(Unit)
	onMoveTileHoveredGameCard()
	
var TILE_HOVERED_CARD_OFFSET := Vector2(-175, -600)
func onMoveTileHoveredGameCard() -> void:
	if TileHoveredGameCard != null and !(TileHoveredGameCard.is_queued_for_deletion()):
		TileHoveredGameCard.position = get_viewport().get_mouse_position() + TILE_HOVERED_CARD_OFFSET
		TileHoveredGameCard.position.y = max(TileHoveredGameCard.position.y, -15)
	
func onQueueTileHoveredGameCard() -> void:
	if TileHoveredGameCard != null:
		TileHoveredGameCard.queue_free()
		UnitStatusOverlord.onRemoveTileHoveredUnitStatus(TileHoveredGameCard.Unit)

func onSelectTileConsoleMode() -> void:
	setWarningText(true, "ConsoleActive")
	Tiles.onSelectTileConsoleMode()
	
func onSelectTileFinish(Tile: TileGD) -> void:
	setWarningText(false, "ConsoleActive")
	Tiles.onSelectTileFinish()
	Console.onTileSelected(Tile)

func onEnterUnitMode(Unit: UnitGD) -> void:
	setUnitModeText(Unit.base_card.name)
	for ability in Unit.abilities:
		if ability is TargetAbilityGD:
			var TargetAbilityBox: Control = preload("res://scenes/screens/level_ui/target_ability_box.tscn").instantiate()
			TargetAbilities.add_child(TargetAbilityBox)
			TargetAbilityBox.mouse_entered.connect(on_is_mouse_in_ui.bind(true))
			TargetAbilityBox.mouse_exited.connect(on_is_mouse_in_ui.bind(false))
			TargetAbilityBox.AbilityCharges.text = str(ability.charges) if ability.charges >= 0 else "∞"
			TargetAbilityBox.label.text = ability.ability_name
			TargetAbilityBox.description.text = ability.ability_description
			TargetAbilityBox.ability = ability
			TargetAbilityBox.pressed.connect(onTargetAbilityBoxPressed.bind(Unit, ability, TargetAbilityBox))
			TargetAbilityBox.disabled = !Combat.isAbilityEnabled(Unit, ability)

func onExitUnitMode() -> void:
	setUnitModeText("")
	for child in TargetAbilities.get_children(): child.queue_free()
	onExitTargetAbilityMode(true)

func onTargetAbilityBoxPressed(Unit: UnitGD, ability: AbilityGD, TargetAbilityBox: Control) -> void:
	if PlayerManager.TAbility == ability:
		onExitTargetAbilityMode()
		TargetAbilityBox.modulate = Color(1, 1, 1)
	else:
		onEnterTargetAbilityMode(Unit, ability)
		TargetAbilityBox.modulate = Color(0.6, 0.6, 0.6)

func onTargetAbilityBtnPressed(Unit: UnitGD, ability: AbilityGD) -> void:
	if LevelMap.action_lock.is_empty():
		if PlayerManager.UnitSelected != Unit:
			PlayerManager.on_unit_selected(Unit)
		
		var TargetAbilityBox: Control = TargetAbilities.get_children().filter(func(x: Control): return !x.is_queued_for_deletion() and x.ability == ability)[0]
		onTargetAbilityBoxPressed(Unit, ability, TargetAbilityBox)
	
func setUnitModeText(text: String, description: String = "") -> void:
	if description == "": UnitNameLabel.text = text; AbilityDescription.text = ""; AbilityLabel.text = ""
	else: AbilityLabel.text = text; AbilityDescription.text = description; UnitNameLabel.text = ""
	
func onEnterTargetAbilityMode(Unit: UnitGD, ability: AbilityGD) -> void:
	setUnitModeText(ability.ability_name, ability.ability_description_big)
	PlayerManager.onEnterTargetAbilityMode(Unit, ability)
	
func onExitTargetAbilityMode(exit_unit: bool = false) -> void: # has to check if actually in target ability mode first
	if PlayerManager.TAbility != null:
		setUnitModeText(PlayerManager.TAbilityUnit.base_card.name if !exit_unit else "")
		PlayerManager.onExitTargetAbilityMode()

func onUpdateAbilityCharges(Unit: UnitGD) -> void:
	var charge_abilities: Array = []
	for ability in Unit.abilities:
		if ability.charges != -1: 
			charge_abilities.append([ability, ability.ability_index])
	charge_abilities.sort_custom(func(x: Array, y: Array): return x[1] > y[1])
	
	var ability_color_replace: Array = []
	for ability in charge_abilities.map(func(x: Array): return x[0]):
		var color: String = "BASE"
		if ability.charges == 0: color = "GRAY"
		elif ability.charges > ability.max_charges: color = "GREEN"
		elif ability.charges < ability.max_charges: color = "YELLOW"
		if color != "BASE": ability_color_replace.append([ability.ability_index, color, ability.charges])
		if ability is TargetAbilityGD:
			onUpdateTargetAbility(Unit, ability)
	
	var new_text: String = Unit.base_text
	for info in ability_color_replace:
		new_text[info[0]] = str(info[2])
		Unit.base_text = new_text
		
	for info in ability_color_replace:
		new_text = new_text.insert(info[0] + 1, "[/color]")
		new_text = new_text.insert(info[0], "[color=" + info[1] + "]")
		Unit.base_card.text = new_text
	
func onUpdateTargetAbilities() -> void:
	for Unit in Units.on_units():
		for ability in Unit.abilities:
			if ability is TargetAbilityGD:
				onUpdateTargetAbility(Unit, ability)
	
func onUpdateTargetAbility(Unit: UnitGD, ability: TargetAbilityGD) -> void:
	UnitStatusOverlord.onUpdateTargetAbility(Unit, ability)

func on_camera_mode_pressed():
	SpectateCamera.onChangeCameraMode(!SpectateCamera.is_unit_camera)

const DRAW_CARD_ORIGINAL_Y: int = -430
const DRAW_CARD_FINAL_Y: int = 1100
const DRAW_CARD_FALL_TIME: float = 1.6
func onTweenDrawCard(GameCard: GameCardGD, HandCard: HandCardGD) -> void:
	GameCard.position.y = DRAW_CARD_ORIGINAL_Y
	GameCard.position.x = randi_range(400, 1200)
	var pos_tween := create_tween()
	var rot_tween := create_tween()
	pos_tween.tween_property(GameCard, "position:y", DRAW_CARD_FINAL_Y, DRAW_CARD_FALL_TIME)
	rot_tween.tween_property(GameCard, "rotation", TAU, DRAW_CARD_FALL_TIME).as_relative()
	pos_tween.finished.connect(onTweenDrawCardFinished.bind(HandCard))

func onTweenDrawCardFinished(HandCard: HandCardGD) -> void:
	for child in DrawCard.get_children(): child.queue_free()
	onDrawCard(HandCard)

@onready var ChangePhaseAniPlayer := $ChangePhaseManager/AnimationPlayer
func onPlayHoverChangePhase(state: bool = true):
	if state: ChangePhaseAniPlayer.play("ChangePhaseHover")
	else: ChangePhaseAniPlayer.play("RESET")

const INCENTIVISE_DURATION: float = 1.6
var is_incentivise: bool = false
func onIncentivisePassTurn(Unit: UnitGD) -> void:
	var enemy_tiles: Array = Tiles.onUnits(TeamRelationGD.new(1))
	if !is_incentivise and (!Unit.onCanAttack() or (Unit.speed == 0 and enemy_tiles.all(func(x: TileGD): return PlayerManager.onMovementPathByDestinationTile(x) == null))):
		is_incentivise = true
		var RotateTween := create_tween()
		RotateTween.tween_property(ChangePhase, "rotation", TAU, INCENTIVISE_DURATION).as_relative().set_trans(Tween.TRANS_ELASTIC)
		RotateTween.finished.connect(func(): is_incentivise = false)

func onEnemySpotted(Unit: UnitGD, _Spotter: UnitGD) -> void:
	var arrow: Node2D = preload("res://scenes/screens/level_ui/unit_status/enemy_spotted_arrow/enemy_spotted_arrow.tscn").instantiate()
	EnemySpottedArrows.add_child(arrow)
	arrow.setInfo(SpectateCamera.Camera, Unit.global_position)
	arrow.destroy_arrow.connect(onDestroySpottedArrow.bind(Unit))
	Unit.Model.setRedMultiply(true)
	
func onDestroySpottedArrow(Unit: UnitGD) -> void:
	Unit.Model.setRedMultiply(false)
