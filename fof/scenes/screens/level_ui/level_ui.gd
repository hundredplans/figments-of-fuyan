class_name LevelUIGD
extends Control

signal screen_change_sig
signal load_world
signal equip_sky
signal mouse_in_ui

var is_first_hand_phase: bool = true
const GREY_LIGHT: float = 0.3
const BASE_MODULATE: float = 0

var Combat: CombatGD
var Tiles: TilesGD
var Vision: VisionGD
var SpectateCamera: Node3D
var Units: UnitsGD
var Hand: HandGD
var Deck: DeckGD
var PlayerManager: PlayerManagerGD
var StatusManager: StatusManagerGD
var ActionManager: ActionManagerGD

@onready var EnemySpottedArrows: Control = %EnemySpottedArrows
@onready var DrawCard: Control = %DrawCard
@onready var AbilityLabel: Label = %AbilityLabel
@onready var UnitNameLabel: Label = %UnitNameLabel
@onready var TargetAbilities: Container = %TargetAbilities
@onready var Console := %Console
@onready var VisionMode := %EyeButton
@onready var EnergyLabels := %EnergyLabels

@onready var PassUnitTurn: TextureButton = %PassUnitTurn
@onready var ChangePhase: Control = %ChangePhase
@onready var StatusBox: Control = %StatusBox
@onready var HeroName := %HeroName
@onready var HeroPortrait := %HeroPortrait
@onready var SeedInfo := %SeedInfo
@onready var MapInfo := %MapInfo
@onready var LevelInfo := %LevelInfo
@onready var BrownParticles := %BrownParticles
@onready var StatusBoxBackground := %StatusBoxBackground

@onready var LeftCameraArrow := %LeftCameraArrow
@onready var RightCameraArrow := %RightCameraArrow

@onready var DeckButton := %DeckButton
@onready var GraveyardButton := %GraveyardButton
@onready var CameraButton := %CameraButton
@onready var PassUnitTurnLabel := %PassUnitTurnLabel

var _LevelMap: PackedScene = preload("res://scenes/screens/level_map/level_map.tscn")
var LevelMap: Node3D
var GameState: Node
@onready var WarningText: Label = %WarningText

func _process(_delta: float) -> void:
	if BrownParticles.amount_ratio == 1:
		BrownParticles.global_position.y = get_viewport().get_mouse_position().y

func _ready() -> void:
	setGameInfo()
	
	setUnitNameLabel()
	setAbilityLabels()
	setWarningText(false)
	
	LevelMap = _LevelMap.instantiate()
	LevelMap.GameState = GameState
	LevelMap.LevelUI = self
	LevelMap.input_lock_updated.connect(onInputLockUpdated)
	
	load_world.emit(LevelMap)
	Vision = LevelMap.Vision
	SpectateCamera = LevelMap.SpectateCamera
	equip_sky.emit(GameState.area_info.id, false)
	
	setTopBarDisabled(true)
	LevelMap.SpectateCamera.mouse_in_ui.connect(on_camera_panning)
	
	var old: float = PANEL_MOVE_TWEEN_DURATION
	PANEL_MOVE_TWEEN_DURATION = 0
	PANEL_MOVE_TWEEN_DURATION = old
	
	var dev := preload("res://static/dev/dev.tres")
	if !dev.god_start: on_pin_hand_box_panel()
	
func setGameInfo() -> void:
	var hero_card: BaseCardGD = Helper.getCard(GameState.hero_id)
	HeroName.text = hero_card.name
	var area_info: AreaInfoGD = GameState.area_info
	HeroPortrait.get_node("InsideBorder").color = area_info.accent_color
	HeroPortrait.get_node("HeroArt").texture = load("res://assets/base_game/cards/cards/" + hero_card.folder_name + "/art_mini.png") 
	SeedInfo.text = str(GameState.gseed)
	MapInfo.text = str(area_info.world_id) + "-" + str(abs(GameState.map_progress.y - 10))
	LevelInfo.text = GameState.level_info.name

func setTopBarDisabled(state: bool) -> void:
	for child in [PassUnitTurn, LeftCameraArrow, RightCameraArrow, DeckButton, VisionMode, CameraButton, GraveyardButton]:
		child.setDisabled(state)

func _queue_free(screen_name: String) -> void:
	if screen_name not in ["LoseScreen", "SettingsMenu", "WinScreen"]:
		GameState._queue_free()
		load_world.emit(null)

func _input(event: InputEvent) -> void:
	if !Console.CommandLine.has_focus() and LevelMap != null and LevelMap.verifyLock(LevelMap.CHANGE_SPECTATE):
		if Input.is_action_just_pressed("SelectLeft"): LevelMap.SpectateCamera.onSpectate(-1)
		elif Input.is_action_just_pressed("SelectRight"): LevelMap.SpectateCamera.onSpectate(1)
	
	if event is InputEventMouseMotion:
		onMoveTileHoveredGameCard()
		
@onready var CardBox: HBoxContainer = %CardBox

var _GameCard: PackedScene = preload("res://assets/base_game/cards/game_card/game_card.tscn")
func onDrawCardAnimation(HandCard: HandCardGD) -> void:
	onDrawCard(HandCard)
	
func onDrawCard(HandCard: HandCardGD) -> void:
	var GameCard: Control = _GameCard.instantiate()
	GameCard.is_hover = true
	GameCard.custom_minimum_size = Vector2(GameCard.size.x, 0)
	GameCard.set_info(Helper.getCard(HandCard.id))
	#var GameCardDraggable := preload("res://scenes/screens/level_ui/game_card_draggable.tscn").instantiate()
	#GameCardDraggable.setInfo(GameCard)
	#GameCard.add_child(GameCardDraggable)
	#GameCardDraggable.drag_start.connect(on_card_selected.bind(GameCard))
	#GameCardDraggable.drag_release.connect(on_card_selected.bind(GameCard))
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
		on_unpin_hand_box_panel()
		#LevelMap.setActionLock("SpawnVision")
	else: 
		GameCardSelected = null
		on_pin_hand_box_panel()
		#LevelMap.setActionLock("HandRegular")
	LevelMap.setInputLock(LevelMap.HAND_LOCK)
	LevelMap.Hand.on_card_selected(index)
		
func on_card_placed(index: int) -> void:
	CardBox.get_child(index).queue_free()
	Vision.on_vision_mode_set(0)

func setEnergy(energy: int) -> void:
	EnergyLabels.setEnergy(energy)

func onPlayerEndTurnPhaseStart() -> void:
	setTopBarDisabled(true)
	on_pass_unit_turn_button_state(false)

@onready var HandBox: Control = %HandBox

func onAfterStartPhaseStart() -> void:
	PhaseIcon.visible = true

var playable_cards: Array
func on_set_hand_box_cards_state() -> void:
	var state: bool = LevelMap.game_phase != "HandPhase"
	for i in range(CardBox.get_child_count()):
		CardBox.get_child(i).on_set_disabled(state or i not in playable_cards)
	
func onPlayerPhaseStart() -> void:
	if GameCardSelected != null:
		GameCardSelected.Art.get_node("CardButton").material = null
		GameCardSelected = null
		
	on_set_hand_box_cards_state()
	on_unpin_hand_box_panel()
	onChangePhaseIcon("PlayerPhase")
	setSelfModulate(BASE_MODULATE)

func setSelfModulate(mod: float) -> void:
	self_modulate.a = mod

func onPassUnitTurnButtonPressed():
	if PlayerManager.unpassed_turns.is_empty() or LevelMap.game_phase == "HandPhase":
		LevelMap.on_advance_game_phase()
	else:
		PlayerManager.on_pass_unit_turn_pressed()

@onready var Statuses: Control = %Statuses
func onSpectateEnemyOrAlly(Unit: UnitGD) -> void:
	if ActionManager.unit_actions.is_empty() and LevelMap.verifyLock(LevelMap.CHANGE_SPECTATE):
		SpectateCamera.onSpectate(Unit)

func on_extend_hand_box() -> void:
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

func onInputLockUpdated() -> void:
	if LevelMap.game_phase == "PlayerPhase":
		setTopBarDisabled(LevelMap.verifyLock(LevelMap.IN_ACTION))

var absolute_mouse_in_ui: bool
var is_mouse_in_ui: bool = false
func on_is_mouse_in_ui(x: bool, absolute_change: bool = true) -> void:
	absolute_mouse_in_ui = x and absolute_change
	is_mouse_in_ui = x
	mouse_in_ui.emit(x)
	
func on_camera_panning(x: bool) -> void:
	if !absolute_mouse_in_ui: on_is_mouse_in_ui(x, false)

func onCameraArrowPressed(direction: int) -> void:
	LevelMap.SpectateCamera.onSpectate(direction)

func on_pin_hand_box_panel() -> void:
	hand_box_pinned = true
	on_extend_hand_box()

func on_unpin_hand_box_panel() -> void:
	hand_box_pinned = false
	on_unextend_hand_box()

func on_ally_unit_awakened(skip_result: bool) -> void:
	if !skip_result: on_pin_hand_box_panel()

func on_pass_unit_turn_button_state(x: bool) -> void:
	PassUnitTurn.setDisabled(x)

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

func onOpenStatusBox() -> void:
	if !is_status_box_moving:
		is_status_box_moving = true
		status_box_state = abs(status_box_state - 1)
		var MoveTween := create_tween()
		MoveTween.tween_property(StatusBox, "position:x", status_box_positions[status_box_state], STATUS_BOX_TRAVEL_TIME)
		MoveTween.finished.connect(func(): is_status_box_moving = false; get_viewport().update_mouse_cursor_state())

@onready var UnitStatusState: Control = %UnitStatusState

func onEyeButtonPressed():
	Vision.on_vision_mode_set(1 if Vision.vision_mode == 0 else 0)

func onVisionModeSet() -> void:
	setSelfModulate(GREY_LIGHT if Vision.vision_mode == 1 else BASE_MODULATE)
	
func onStartPhaseStart() -> void:
	setSelfModulate(GREY_LIGHT)
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
	on_pass_unit_turn_button_state(true)
	onChangePhaseIcon("AIPhase")
	onFlipPassButton("ENEMY")

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
	var skip_hand_phase: bool = LevelMap.on_skip_hand_phase_result()
	setSelfModulate(GREY_LIGHT)
	
	on_set_hand_box_cards_state()
	if !skip_hand_phase:
		on_pin_hand_box_panel()
		LevelMap.setInputLock(LevelMap.HAND_LOCK)
		on_pass_unit_turn_button_state(false)
	else: LevelMap.on_advance_game_phase()
	
	if !is_first_hand_phase:
		onChangePhaseIcon("HandPhase")
		onFlipPassButton("PASS")
	is_first_hand_phase = false

func onFlipPassButton(text: String) -> void:
	ChangePhaseAniPlayer.play("ChangePhaseChanged")
	await get_tree().create_timer(0.08).timeout
	onChangePassButtonText(text)

var warning_texts: Dictionary = {
	"SkipAction": "If you perform an action with this unit you will skip another unit's turn!",
	"SkipHandTurn": "There are no valid spawn tiles! Skipping to the Player Phase",
	"ConsoleActive": "Select a Tile"
}

func setWarningText(visibility: bool = false, text: String = "") -> void:
	WarningText.visible = visibility
	if visibility:
		WarningText.text = warning_texts[text]

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
	StatusManager.onCreateTileHoveredUnitStatus(Unit)
	onMoveTileHoveredGameCard()
	
var TILE_HOVERED_CARD_OFFSET := Vector2(-175, -600)
func onMoveTileHoveredGameCard() -> void:
	if TileHoveredGameCard != null and !(TileHoveredGameCard.is_queued_for_deletion()):
		TileHoveredGameCard.position = get_viewport().get_mouse_position() + TILE_HOVERED_CARD_OFFSET
		TileHoveredGameCard.position.y = max(TileHoveredGameCard.position.y, -15)
	
func onQueueTileHoveredGameCard() -> void:
	if TileHoveredGameCard != null:
		TileHoveredGameCard.queue_free()
		StatusManager.onRemoveTileHoveredUnitStatus(TileHoveredGameCard.Unit)

func onSelectTileConsoleMode() -> void:
	setWarningText(true, "ConsoleActive")
	Tiles.onSelectTileConsoleMode()
	
func onSelectTileFinish(Tile: TileGD) -> void:
	setWarningText(false, "ConsoleActive")
	Tiles.onSelectTileFinish()
	Console.onTileSelected(Tile)

func onEnterUnitMode(Unit: UnitGD) -> void:
	setUnitNameLabel(Unit.base_card.name)
	for ability in Unit.abilities:
		if ability is TargetAbilityGD:
			var TargetAbilityBox: Control = preload("res://scenes/screens/level_ui/target_ability_box.tscn").instantiate()
			TargetAbilities.add_child(TargetAbilityBox)
			var charges_text: String = "Charges: " + ((str(ability.charges) + "/" + str(ability.max_charges)) if ability.charges >= 0 else "∞")
			TargetAbilityBox.AbilityCharges.text = charges_text
			TargetAbilityBox.label.text = ability.ability_name
			TargetAbilityBox.description.text = ability.ability_description
			TargetAbilityBox.ability = ability
			TargetAbilityBox.pressed.connect(onTargetAbilityBoxPressed.bind(Unit, ability))
			TargetAbilityBox.setDisabled(!Combat.isAbilityEnabled(Unit, ability))
			TargetAbilityBox.mouse_in_ui.connect(on_is_mouse_in_ui)
			
func onExitUnitMode() -> void:
	setUnitNameLabel()
	for child in TargetAbilities.get_children(): child.queue_free()
	onExitTargetAbilityMode(PlayerManager.EXIT_TARGET_ABILITY_OTHER)
#
func onTargetAbilityBoxPressed(Unit: UnitGD, ability: AbilityGD) -> void:
	if PlayerManager.TAbility == ability: onExitTargetAbilityMode(PlayerManager.EXIT_TARGET_ABILITY_BUTTON)
	else: onEnterTargetAbilityMode(Unit, ability)

func onTargetAbilityBtnPressed(Unit: UnitGD, ability: AbilityGD) -> void:
	if LevelMap.verifyLock(): onTargetAbilityBoxPressed(Unit, ability)
	
func setAbilityLabels(text: String = "") -> void:
	AbilityLabel.text = text
	
func setUnitNameLabel(text: String = "") -> void:
	UnitNameLabel.text = text
	
func onEnterTargetAbilityMode(Unit: UnitGD, ability: AbilityGD) -> void:
	setAbilityLabels(ability.ability_name)
	PlayerManager.onEnterTargetAbilityMode(Unit, ability)
	
func onExitTargetAbilityMode(exit_type: int = 0) -> void: # has to check if actually in target ability mode first
	if PlayerManager.TAbility != null:
		setAbilityLabels()
		PlayerManager.onExitTargetAbilityMode(exit_type)

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
			StatusManager.onUpdateTargetAbility(Unit, ability)
	
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
				StatusManager.onUpdateTargetAbility(Unit, ability)

func onCameraButtonPressed():
	SpectateCamera.onChangeCameraMode(!SpectateCamera.is_unit_camera)

const DRAW_CARD_ORIGINAL_Y: int = -430
const DRAW_CARD_FINAL_Y: int = 1100
const DRAW_CARD_FALL_TIME: float = 1.6
#func onTweenDrawCard(GameCard: GameCardGD, HandCard: HandCardGD) -> void:
	#GameCard.position.y = DRAW_CARD_ORIGINAL_Y
	#GameCard.position.x = randi_range(400, 1200)
	#var pos_tween := create_tween()
	#var rot_tween := create_tween()
	#pos_tween.tween_property(GameCard, "position:y", DRAW_CARD_FINAL_Y, DRAW_CARD_FALL_TIME)
	#rot_tween.tween_property(GameCard, "rotation", TAU, DRAW_CARD_FALL_TIME).as_relative()
	#pos_tween.finished.connect(onTweenDrawCardFinished.bind(HandCard))
#
#func onTweenDrawCardFinished(HandCard: HandCardGD) -> void:
	#for child in DrawCard.get_children(): child.queue_free()
	#onDrawCard(HandCard)

@onready var ChangePhaseAniPlayer := %ChangePhaseAnimationPlayer

const INCENTIVISE_DURATION: float = 1.6
var is_incentivise: bool = false
func onIncentivisePassTurn(Unit: UnitGD) -> void:
	var enemy_tiles: Array = Tiles.onUnits(TeamRelationGD.new(1))
	if !is_incentivise and (!Unit.onCanAttack() or (Unit.speed == 0 and enemy_tiles.all(func(x: TileGD): return MovementPathGD.onFindTile(x, PlayerManager.unit_movement_paths) == null))):
		is_incentivise = true
		var RotateTween := create_tween()
		RotateTween.tween_property(ChangePhase, "rotation", TAU, INCENTIVISE_DURATION).as_relative().set_trans(Tween.TRANS_ELASTIC)
		RotateTween.finished.connect(func(): is_incentivise = false)

func onEnemySpotted(Unit: UnitGD, _Spotter: UnitGD) -> void:
	var arrow: Node2D = preload("res://scenes/screens/level_ui/enemy_spotted_arrow/enemy_spotted_arrow.tscn").instantiate()
	EnemySpottedArrows.add_child(arrow)
	arrow.setInfo(SpectateCamera.Camera, Unit.global_position)
	arrow.destroy_arrow.connect(onDestroySpottedArrow.bind(Unit))
	Unit.Model.setRedMultiply(true)
	
func onDestroySpottedArrow(Unit: UnitGD) -> void:
	Unit.Model.setRedMultiply(false)

func onStatusBoxMouseEntered():
	BrownParticles.amount_ratio = 1
	StatusBoxBackground.modulate = Color(1, 1, 0)

func onStatusBoxMouseExited():
	BrownParticles.amount_ratio = 0
	StatusBoxBackground.modulate = Color(1, 1, 1)

func onDeckButtonPressed():
	var CardsMenu: Control = preload("res://scenes/screens/level_ui/cards_menu/cards_menu.tscn").instantiate()
	add_child(CardsMenu)
	
	CardsMenu.setInfo(PlayerManager.graveyard_cards, Deck.get_children())
	CardsMenu.onLoadDeck()

func onGraveyardButtonPressed():
	var CardsMenu: Control = preload("res://scenes/screens/level_ui/cards_menu/cards_menu.tscn").instantiate()
	add_child(CardsMenu)
	
	CardsMenu.setInfo(PlayerManager.graveyard_cards, Deck.get_children())
	CardsMenu.onLoadGraveyard()

func onChangePassButtonText(text: String) -> void:
	PassUnitTurnLabel.text = text
