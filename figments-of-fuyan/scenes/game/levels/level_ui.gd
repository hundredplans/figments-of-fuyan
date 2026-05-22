extends Control


#region Onready
@onready var MinimapButton: DefaultButton = %MinimapButton
@onready var VisionModeButton: DefaultButton = %VisionModeButton
@onready var GraveyardButton: DefaultButton = %GraveyardButton
@onready var TopCenter: Control = %TopCenter
@onready var HandBox: Container = %HandBox
@onready var CameraButton: DefaultButton = %CameraButton
@onready var CommonGameUI: Control = %CommonGameUI
@onready var SpectatedUnitStatusUI: Control = %SpectatedUnitStatusUI
@onready var GameEffectsLevelUI: Control = %GameEffectsLevelUI
@onready var EnemyStatusManager: Control = %EnemyStatusManager
@onready var AllyStatusManager: Control = %AllyStatusManager
@onready var FadeBackground: Control = %FadeBackground
@onready var MainControl: Control = %Main
@onready var AniPlayer: AnimationPlayer = %AniPlayer

@onready var PhaseIcon: TextureRect = %PhaseIcon

@onready var BackgroundDimmer: ColorRect = %BackgroundDimmer
@onready var PassButton: DefaultButton = %PassButton

@onready var Console: Control = %Console

@onready var LeftCameraArrow: DefaultButton = %LeftCameraArrow
@onready var RightCameraArrow: DefaultButton = %RightCameraArrow

@onready var HoverCardControl: Control = %HoverCardControl
@onready var BoonEffectFiller: Control = %BoonEffectFiller
@onready var EpicFightControl: Control = %EpicFightControl
@onready var AllyStatusScroll: ScrollContainer = %AllyStatusScroll
@onready var EnemyStatusScroll: ScrollContainer = %EnemyStatusScroll
#endregion

#region Globals
signal active_effect_pressed
signal mouse_signal
signal camera_button_pressed
signal action_lock
signal camera_direction_changed
signal vision_mode_changed
signal create_movement_range

signal drag_begin
signal drag_end

const BOTTOM_SCREEN_OFFSET: int = 5
const SHIELD_ID: int = 3

var save_file: SaveFileGD
var level: LevelGD
var area: AreaGD
var World: Node3D
var mouse_in_ui: bool
var PauseMenu: Control
var StashScreen: Control
var BoonBox: Control
#endregion

#region Exports
@export var GraveyardScreenPacked: PackedScene
@export var LossUIPacked: PackedScene
#endregion

#region Base Functions

func setInfo(_save_file: SaveFileGD) -> void:
	save_file = _save_file
	area = save_file.area
	level = area.active_level
	
	CommonGameUI.update_stash_screen.connect(onUpdateStashScreenExisting)
	BoonBox = CommonGameUI.getBoonBox()
	SpectatedUnitStatusUI.visible = false
	
	AllyStatusScroll.get_v_scroll_bar().mouse_entered.connect(onMouseInUI.bind(true))
	AllyStatusScroll.get_v_scroll_bar().mouse_exited.connect(onMouseInUI.bind(false))
	
	EnemyStatusScroll.get_v_scroll_bar().mouse_entered.connect(onMouseInUI.bind(true))
	EnemyStatusScroll.get_v_scroll_bar().mouse_exited.connect(onMouseInUI.bind(false))
	
	Game.ActionManagerReference.action_playing.connect(onActionPlaying)
		
	level.phase_changed.connect(onPhaseChanged)
	level.turn_state_changing.connect(onTurnStateChanging)
	level.awakened.connect(onAwakened)
	level.tile_occupied.connect(onTileOccupied)
	level.game_ended.connect(onGameEnded)
	level.death.connect(onDeath)
	action_lock.connect(level.onActionLock)
	
	area.process_action.connect(onProcessAction)
	level.camera_change_action.connect(onCameraUpdated)
	
	World.active_effect_deselected.connect(onActiveEffectDeselected)
	World.active_effect_selected.connect(onActiveEffectSelected)
	World.active_effect_activated.connect(onActiveEffectActivated)
	AllyStatusManager.active_effect_pressed.connect(onActiveEffectPressed)
	AllyStatusManager.pressed.connect(onUnitStatusUIPressed)
	EnemyStatusManager.pressed.connect(onUnitStatusUIPressed)
	SpectatedUnitStatusUI.pressed.connect(onUnitStatusUIPressed)
	
	Console.level = level
	
	onCameraUpdated(level.getSpectateObject())
	
	EpicFightControl.visible = false # Important
	setEpicFightControlInfo()
	
	BoonBox.onUpdate()
	SpectatedUnitStatusUI.setInfo(true, true)
	
	var area_color: Color = Helper.getFofInfoID(AreaInfo, level.getAreaID()).getAreaColor()
	CommonGameUI.setLevelName(level.info.name, area_color, level.getAreaID())
	
	for Tile: TileGD in get_tree().get_nodes_in_group("LevelTilesGD"):
		onTileCreated(Tile)
		
	for Card: CardGD in get_tree().get_nodes_in_group("FieldCardsGD"):
		if Card.isAlly(0): AllyStatusManager.onCreateUnitStatusUI(Card)
		else: EnemyStatusManager.onCreateUnitStatusUI(Card)
		
func _process(_delta: float) -> void:
	if HoverCardUI != null:
		setHoverCardUIPosition()
		
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("HideUI") and !level.isGameEnded():
		onHideUI(!visible)
	
	elif Input.is_action_just_pressed("Back") and PauseMenu == null:
		PauseMenu = Game.onCreatePauseMenu(self)
		PauseMenu.mouse_in_ui.connect(onMouseInUI)
#endregion

#region Action Lock / Mouse In UI
var is_action_playing: bool
func onUpdateActionLock(previous_state: bool) -> void:
	var state: bool = getActionLock()
	if state != previous_state:
		action_lock.emit(state)
		if get_tree() == null: return
		get_tree().call_group("LevelTilesGD", "onUpdateActionLock", state)
		for btn in get_tree().get_nodes_in_group("ActionLockDisabled"):
			if btn == PassButton: btn.setActionLock(state)
			elif btn is Button: btn.setActionLock(state)
			elif btn is HighlightTxButton: btn.setDisabled(state)
			elif btn in [LeftCameraArrow, RightCameraArrow]: btn.setActionLock(state)
			elif btn is DefaultControl: btn.setDisabled(state)
		AllyStatusManager.setActionLock(state)
		AllyStatusManager.setDisabled(state)
		EnemyStatusManager.setDisabled(state)
		SpectatedUnitStatusUI.setDisabled(state)
		CommonGameUI.setActionLock(state)

func getActionLock() -> bool:
	return is_action_playing

func onMouseInUI(state: bool) -> void:
	if get_viewport().get_mouse_position().y >= get_viewport().size.y - BOTTOM_SCREEN_OFFSET: return
	mouse_in_ui = state
	mouse_signal.emit(mouse_in_ui)

func onActionPlaying(state: bool) -> void:
	if level.isGameEnded(): return
	var previous_state: bool = getActionLock()
	is_action_playing = state
	onChangeVisionMode(false)
	onUpdateActionLock(previous_state)
#endregion

#region Phase

var PhaseTween: Tween
const CHANGE_PASS_BUTTON_COLOR_TIME: float = 0.35

func onPhaseChanged(phase: Game.Phases, _phase: Game.Phases, instant: bool = false, reload: bool = false) -> void:
	PhaseIcon.setPhase(phase)
	PassButton.setPhase(phase)
	
	match phase:
		Game.Phases.START:
			CameraButton.setDisabled(true)
			if instant:
				onCreateHand(level.getHandCards(), true)
		Game.Phases.PLAYER:
			if !reload:
				CameraButton.setDisabled(false)
				HandBox.onRemoveHand(level.getHandCards())
			PassButton.setAllySpectating(level.getAllySpectateObject())
	
	var phase_color := Game.getPhaseColor(phase)
	if !instant:
		if PhaseTween: PhaseTween.kill()
		PhaseTween = create_tween()
		PhaseTween.tween_property(TopCenter, "modulate", phase_color, CHANGE_PASS_BUTTON_COLOR_TIME)
	else:
		TopCenter.modulate = phase_color
#endregion

#region Hand
func onCreateHand(cards: Array, instant: bool) -> void:
	var card_uis: Array = await HandBox.onCreateHand(cards, instant)
	for CardUI: TbcUI in card_uis:
		CardUI.drag_begin.connect(onCardDraggedBegin)
		CardUI.drag_end.connect(onCardDraggedEnd)
		CardUI.mouse_in_ui.connect(onMouseInUI)
		CardUI.mouse_in_ui.connect(HandBox.onMouseInUI)

#region Card Dragged
func onCardDraggedEnd(CardUI: Control) -> void:
	drag_end.emit(CardUI)
	CardUI.setMouseFilter(Control.MOUSE_FILTER_STOP)
	
func onCardDraggedBegin(CardUI: Control) -> void:
	drag_begin.emit(CardUI)
	CardUI.setMouseFilter(Control.MOUSE_FILTER_IGNORE)
#endregion

#region Camera
func onCameraDirectionChanged(direction: int) -> void:
	camera_direction_changed.emit(direction)
	
func _on_camera_button_pressed() -> void:
	camera_button_pressed.emit()
	
func onCameraUpdated(SpectateObject: GameObjectGD, __: GameObjectGD = null) -> void:
	if !World.CameraManager.isCycle():
		PassButton.setAllySpectating(SpectateObject)
		
		AllyStatusManager.onUpdateAbilityBoxes(SpectateObject if SpectateObject is CardGD else null)
		Console.onCameraUpdated(SpectateObject)
		
		LeftCameraArrow.setIsInFreelook(SpectateObject == null)
		RightCameraArrow.setIsInFreelook(SpectateObject == null)
#endregion

#region Deck / Graveyard
var GraveyardScreen: Control
var is_graveyard_fading: bool
func _on_graveyard_button_pressed() -> void:
	if is_graveyard_fading: return
	if GraveyardScreen == null:
		is_graveyard_fading = true
		GraveyardScreen = GraveyardScreenPacked.instantiate()
		GraveyardScreen.mouse_in_ui.connect(onMouseInUI)
		MainControl.add_child(GraveyardScreen)
		GraveyardScreen.exit_start.connect(onGraveyardExitStart)
		
		CommonGameUI.onFadeStashButton(true)
		var original_pos: Vector2 = GraveyardButton.global_position
		GraveyardButton.top_level = true
		GraveyardButton.global_position = original_pos
		PassButton.onFade(false)
		LeftCameraArrow.onFade(false)
		RightCameraArrow.onFade(false)
		await GraveyardScreen.setInfo(Game.getArea().getAreaColor())
		is_graveyard_fading = false
	else:
		is_graveyard_fading = true
		await onGraveyardExitStart()
		is_graveyard_fading = false
	
func onGraveyardExitStart() -> void:
	CommonGameUI.onFadeStashButton(false)
	PassButton.onFade(true)
	LeftCameraArrow.onFade(true)
	RightCameraArrow.onFade(true)
	await GraveyardScreen.onFade(false)
	GraveyardButton.top_level = false
	GraveyardButton.position = Vector2.ZERO
	get_viewport().call_deferred("update_mouse_cursor_state")
#endregion

#region Pass Button
func _on_pass_button_pressed() -> void:
	level.onPassTurn()
	World.onPassButtonPressed()
	
func onTurnStateChanging(Card: CardGD, _action: ChangeTurnStateAction) -> void:
	PassButton.setTurnStates(Card)
	if Card == level.SpectateObject:
		AllyStatusManager.onUpdateAbilityBoxes(Card)
#endregion

#region Minimap
var MinimapUI: Control
var active_minimap: bool
func _on_minimap_button_pressed() -> void:
	if MinimapUI != null: return
	active_minimap = true
	
	var start_loading_screen_action := StartLoadingScreenAction.new(
		Game.LoadingType.MAP,
		Game.getArea().getInfo().id)
	Game.getSaveFile().onForceAction(start_loading_screen_action)
	
func onMinimapPostLoadingScreen() -> void:
	World.onMinimapCreated()
	MainControl.visible = false
	Game.getLevel().visible = false
	for Card: CardGD in get_tree().get_nodes_in_group("FieldCardsGD"):
		Card.visible = false
		
	MinimapUI = Game.onCreateMinimap(self)
	MinimapUI.exit.connect(onMinimapUIExit)
	
func onMinimapUIExit() -> void:
	active_minimap = false
	World.onMinimapExited()
	MainControl.visible = true
	Game.getLevel().visible = true
	MinimapUI = null
	for Card: CardGD in get_tree().get_nodes_in_group("FieldCardsGD"):
		Card.visible = Card.isLevelVisible()
	
func onMinimapRemoved() -> void:
	if !level.isGameEnded():
		BackgroundDimmer.visible = false
#endregion

#region Vision Mode
var in_vision_mode: bool
func _on_vision_mode_button_pressed() -> void:
	onChangeVisionMode(!in_vision_mode)
	
func onChangeVisionMode(state: bool) -> void:
	if state != in_vision_mode:
		in_vision_mode = state
		BackgroundDimmer.visible = state
		vision_mode_changed.emit(state)
#endregion

#region Inspect Screen
func onInspectScreenCreated(InspectScreen: Control) -> void:
	InspectScreen.mouse_in_ui.connect(onMouseInUI)
#endregion

#region Awakened
func onAwakened(Card: CardGD) -> void:
	Card.inspect_screen_created.connect(onInspectScreenCreated)
	#Card.FieldInfo.visible = visible
	if !Card.isAlly(0): return
	PassButton.setUnpassedTurns()
#endregion

#region Death
func onDeath(Card: CardGD) -> void:
	if Card.isAlly(0): AllyStatusManager.onRemoveUnitStatusUI(Card)
	else: EnemyStatusManager.onRemoveUnitStatusUI(Card)
	
	if !Card.isAlly(0): return
	PassButton.setUnpassedTurns()
#endregion

#region Active Effects
func onActiveEffectDeselected() -> void:
	onCameraUpdated(level.getSpectateObject())
	PassButton.setAbilityMode(false)

func onActiveEffectSelected() -> void:
	PassButton.setAbilityMode(true)
	
func onActiveEffectActivated() -> void:
	AllyStatusManager.onUpdateAbilityBoxes(level.getCardSpectateObject())
#endregion

#region Occupy Tile
func onTileOccupied(Card: CardGD, _Tile: TileGD) -> void:
	if Card == level.getSpectateObject():
		AllyStatusManager.onUpdateAbilityBoxes(Card)
#endregion

#region Game Changers
var RewardsUI: Control
func onGameEnded(rewards: Rewards) -> void:
	await get_tree().process_frame # Necessary for UI to load in
	onHideUI(true)
	EpicFightControl.visible = false
	if rewards == null:
		var LossUI: Control = LossUIPacked.instantiate()
		MainControl.add_child(LossUI)
	else:
		RewardsUI = Game.onCreateRewardsScreen(rewards, MainControl, level.fight_type)
		AniPlayer.play("RewardsScreenCreated")
		RewardsUI.screen_finished.connect(onRewardsFinished)
		RewardsUI.stash_screen_fade_out.connect(onRewardsStashScreenFade.bind(false))
		RewardsUI.stash_screen_fade_in.connect(onRewardsStashScreenFade.bind(true))
		
		for child in [BoonBox]:
			child.reparent(RewardsUI)
	
	is_action_playing = true
	onUpdateActionLock(false)
	
	for btn in get_tree().get_nodes_in_group("ActionLockDisabled").filter(func(x: Control): return x is HighlightTxButton):
		btn.setDisabled(btn.is_in_group("EndGameDisabled"))
	
	CommonGameUI.setGameEnded(true)
	
var stash_screen_previous_fade: bool
func onRewardsStashScreenFade(fade_in: bool) -> void:
	stash_screen_previous_fade = fade_in
	
	var boon_tween := create_tween()
	boon_tween.tween_property(BoonBox, "modulate:a", int(!fade_in), Game.FADE_TIME)
	
	if !fade_in: BoonBox.visible = true
	await boon_tween.finished
	if fade_in and stash_screen_previous_fade == fade_in:
		BoonBox.visible = false
#endregion

#region Created
func onTileCreated(Tile: TileGD) -> void:
	Tile.change_hover_card_state.connect(onChangeHoverCardState)
#endregion	

#region Hoverin
var HoverCardUI: Control
const HOVER_CARD_OFFSET := Vector2(-110, -400)
func onChangeHoverCardState(Card: CardGD, state: bool) -> void:
	if HoverCardUI != null and !state: HoverCardUI.queue_free()
	elif HoverCardUI == null and state and Card.onCanHoverOnTile():
		HoverCardUI = Card.onCreateCardUI(HoverCardControl)
		setHoverCardUIPosition()
		
func setHoverCardUIPosition() -> void:
	HoverCardUI.global_position = get_viewport().get_mouse_position() + HOVER_CARD_OFFSET
#endregion

#region Hide UI
func onHideUI(state: bool) -> void:
	visible = state
	
	for Card in get_tree().get_nodes_in_group("FieldCardsGD").filter(func(x: CardGD): return x.isLevelVisible() and x.FieldInfo != null):
		Card.FieldInfo.visible = state
		
	for Tile in get_tree().get_nodes_in_group("LevelTilesGD"):
		Tile.onHideUI(state)
		
	EpicFightControl.visible = state
#endregion

#region Action
func onProcessAction(action: Action) -> void:
	if action.post:
		if action is DamageAction:
			AllyStatusManager.onUpdateAbilityBoxes(level.getCardSpectateObject())
		elif action is AddBoonAction:
			BoonBox.onUpdate(action.Boon)
		elif action is RemoveBoonAction:
			BoonBox.onUpdate(action.Boon, true)
		elif action is ChangeBoonChargesAction:
			BoonBox.onUpdateBoonChargesAndDisabled(action.Boon)
		elif action is ChangeShillingsAction:
			CommonGameUI.onUpdateShillings()
		elif action is PlayCardAction:
			onCardPlayed(action)
		elif action is BoonActivatedAction:
			onBoonEffectTemp(action)
		elif action is CardEnergyAction:
			HandBox.onUpdateCardEnergy()
		elif action is StartLoadingScreenAction and active_minimap:
			onMinimapPostLoadingScreen()
		elif action is EndLoadingScreenAction and !active_minimap:
			onEndLoadingScreen()
		elif action is FinishAwakenAction:
			if action.Card.isAlly(0): AllyStatusManager.onCreateUnitStatusUI(action.Card)
			else: EnemyStatusManager.onCreateUnitStatusUI(action.Card)
		elif action is ChangeActiveEffectChargesAction:
			AllyStatusManager.onUpdateAbilityBox(action.item, level.getCardSpectateObject())
		elif action is ChangeActiveEffectUsedAction:
			AllyStatusManager.onUpdateAbilityBox(action.item, level.getCardSpectateObject())
		elif action is AddToolAction:
			onToolAdded(action)
		elif action is ClearTileObjectAction:
			AllyStatusManager.onUpdateIObjectAbilityBox(level.getCardSpectateObject())
		elif (action is AddStatusEffectAction or action is AddFieldEffectAction or action is AddTraitAction) and action.getCard() == level.getCardSpectateObject():
			GameEffectsLevelUI.onAddIcon(action.getGameEffect())
		elif (action is RemoveStatusEffectAction or action is RemoveFieldEffectAction or action is RemoveTraitAction) and action.getCard() == level.getCardSpectateObject():
			GameEffectsLevelUI.onRemoveIcon(action.getGameEffect())
		elif action is VisionNewUnitAction and action.Discoverer == level.getSpectateObject():
			onUpdateInVisionRange()
			
		if level.isEpic():
			var BossCard: CardGD = level.getBoss()
			if action is AwakenBossAction:
				setEpicFightControlInfo()
			elif action is StatAction and action.hasCard(BossCard):
				EpicFightControl.setHealthBar(BossCard)
			elif action is ChangeBossPhaseAction:
				EpicFightControl.onUpdateBossNameLabel(BossCard)
			elif action is AddTraitAction and action.Card == BossCard:
				EpicFightControl.setHealthBar(BossCard)
			elif action is RemoveTraitAction and action.Card == BossCard:
				EpicFightControl.setHealthBar(BossCard)
			elif action is AddFieldEffectAction and action.getCard() == BossCard and action.getFieldEffectId() == SHIELD_ID:
				EpicFightControl.setBossShieldUI(true)
			elif action is RemoveFieldEffectAction and action.getCard() == BossCard and action.getFieldEffectId() == SHIELD_ID:
				EpicFightControl.setBossShieldUI(false)
	elif !action.post:
		if action is StartLoadingScreenAction:
			onHideLevelUI()
		elif action is RemoveToolAction:
			onToolRemoved(action)
		elif action is CreateHandAction:
			onCreateHand(action.getCards(), false)
#endregion
const BOON_EFFECT_TEMP_DURATION: float = 1.2
func onBoonEffectTemp(action: BoonActivatedAction) -> void:
	if !action.Boon.info.display_trigger: return
	
	var BoonEffectTemp := TextureRect.new()
	BoonEffectFiller.add_child(BoonEffectTemp)
	BoonEffectTemp.texture = action.Boon.getIcon()
	BoonEffectTemp.pivot_offset = Vector2(40, 40)
	
	var rotate_tween := create_tween()
	rotate_tween.tween_property(BoonEffectTemp, "rotation", PI, BOON_EFFECT_TEMP_DURATION).as_relative().set_trans(Tween.TRANS_SINE)
	
	var vis_tween := create_tween()
	vis_tween.tween_property(BoonEffectTemp, "modulate:a", -1, BOON_EFFECT_TEMP_DURATION).as_relative().set_trans(Tween.TRANS_SINE)

	await vis_tween.finished
	BoonEffectTemp.queue_free()

#region Boss
func setEpicFightControlInfo() -> void:
	if !level.isEpic(): return
	if level.getBoss() == null: return
	EpicFightControl.visible = true
	EpicFightControl.setInfo()
#endregion

func onRewardsFinished() -> void:
	level.onRewardsFinished()

func onHideLevelUI() -> void:
	MainControl.visible = false

func onEndLoadingScreen() -> void:
	visible = false
	FadeBackground.modulate.a = 1.0
	await get_tree().create_timer(Game.FADE_TIME).timeout
	visible = true
	await get_tree().create_timer(Game.FADE_TIME * 2).timeout
	FadeBackground.onFade(false)

func onCameraChangeFinish(SpectateObject: GameObjectGD) -> void:
	var PreviousCard: CardGD = SpectatedUnitStatusUI.getCard()
	var NewCard: CardGD = SpectateObject if SpectateObject is CardGD else null
	AllyStatusManager.onUpdateSpectatedUnitStatusUI(PreviousCard, NewCard)
	EnemyStatusManager.onUpdateSpectatedUnitStatusUI(PreviousCard, NewCard)
	GameEffectsLevelUI.onCreateGameEffects(SpectateObject)
	onUpdateInVisionRange(SpectateObject)
	
	SpectatedUnitStatusUI.visible = NewCard != null
	
	if NewCard != null:
		SpectatedUnitStatusUI.setCard(NewCard)
	
func onUpdateInVisionRange(SpectateObject: GameObjectGD = level.getSpectateObject()) -> void:
	AllyStatusManager.onUpdateInVisionRange(SpectateObject)
	EnemyStatusManager.onUpdateInVisionRange(SpectateObject)

func onActiveEffectPressed(item: Variant) -> void:
	var active_effect_tiles: ActiveEffectTiles = item.getActiveEffectTiles()
	active_effect_pressed.emit(item, active_effect_tiles)

func onUnitStatusUIPressed(Card: CardGD) -> void:
	if level.getPhase() == Game.Phases.START: return
	await get_tree().process_frame
	Game.getLevel().onPushAction(CameraChangeAction.new(Card))

func onToolAdded(action: AddToolAction) -> void:
	var Card: CardGD = action.Tool.getCard()
	if Card == level.getCardSpectateObject():
		AllyStatusManager.onUpdateToolAbilityBox(action.Tool)
	
	if Card.isAlly(0): AllyStatusManager.onUpdateTool(Card)
	else: EnemyStatusManager.onUpdateTool(Card)
	
	if Card == level.getCardSpectateObject():
		SpectatedUnitStatusUI.onUpdateTool(Card.getTool())
		
func onToolRemoved(action: RemoveToolAction) -> void:
	var Card: CardGD = action.Card
	if Card == level.getCardSpectateObject():
		AllyStatusManager.onUpdateToolAbilityBox(action.Card.getTool())
		
	if Card.isAlly(0): AllyStatusManager.onUpdateTool(Card)
	else: EnemyStatusManager.onUpdateTool(Card)
	
	if Card == level.getCardSpectateObject():
		SpectatedUnitStatusUI.onUpdateTool(Card.getTool())

func onCardPlayed(action: PlayCardAction) -> void:
	await HandBox.onCardPlayed(action.Card)
	Game.getLevel().onCheckAutoskipStartPhase()

func onUpdateStashScreenExisting() -> void:
	if StashScreen == null: onCreateStashScreen()
	else: onRemoveStashScreen()
		
	
func onCreateStashScreen() -> void:
	StashScreen = Game.onCreateStashScreen(self)
	if StashScreen == null: return
	StashScreen.onStashInLevel()
	StashScreen.mouse_in_ui.connect(onMouseInUI)
	CommonGameUI.onStashInLevel(false)
	onStashScreenUpdated(true)
	
func onRemoveStashScreen() -> void:
	StashScreen.onStartExit()
	CommonGameUI.onStashInLevel(true)
	onStashScreenUpdated(false)
	
func onStashScreenUpdated(is_created: bool) -> void:
	for node: Control in [LeftCameraArrow, PassButton, RightCameraArrow, CameraButton,
	GraveyardButton, MinimapButton, VisionModeButton]:
		node.onFade(!is_created)
