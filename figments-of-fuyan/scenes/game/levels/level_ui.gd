extends Control


#region Onready
@onready var HandPanel: PanelContainer = %HandPanel
@onready var HandPanelAnimationPlayer: AnimationPlayer = %HandPanelAnimationPlayer
@onready var ShillingLabel: FancyTextLabel = %ShillingLabel
@onready var LevelLabel: Label = %LevelLabel
@onready var ArtMiniRect: TextureRect = %ArtMiniRect

@onready var EnergyLabel: Label = %EnergyLabel
@onready var PhaseIcon: TextureRect = %PhaseIcon
@onready var HeroNameLabel: Label = %HeroNameLabel
@onready var ActiveEffectLabel: Label = %ActiveEffectLabel

@onready var BackgroundDimmer: ColorRect = %BackgroundDimmer
@onready var PassButton: Button = %PassButton

@onready var ActiveEffects: Container = %ActiveEffects
@onready var Console: Control = %Console

@onready var BoonBox: Control = %BoonBox

@onready var TimeLabel: Label = %TimeLabel

@onready var DeckPanel: PanelContainer = %DeckPanel
@onready var MapPanel: PanelContainer = %MapPanel

@onready var LeftCameraArrow: Button = %LeftCameraArrow
@onready var RightCameraArrow: Button = %RightCameraArrow

@onready var MinimapControl: Control = %MinimapControl
@onready var DeckCardAmountLabel: Label = %DeckCardAmountLabel

@onready var OverworldInformation: Control = %OverworldInformation
@onready var LeftContainer: HBoxContainer = %LeftContainer

@onready var HoverCardControl: Control = %HoverCardControl
#endregion

#region Globals
signal mouse_signal
signal camera_button_pressed
signal action_lock
signal camera_direction_changed
signal vision_mode_changed
signal active_effect_box_pressed
signal active_effect_added
signal tile_occupied

signal dragged_begin
signal dragged_end

const BOTTOM_SCREEN_OFFSET: int = 5

var save_file: SaveFileGD
var level: LevelGD
var area: AreaGD
var World: Node3D
var mouse_in_ui: bool
#endregion

#region Exports
@export var DeckScreenPacked: PackedScene
@export var GraveyardScreenPacked: PackedScene
@export var MinimapPacked: PackedScene
@export var LossUIPacked: PackedScene
#endregion

#region Base Functions
func setInfo(_save_file: SaveFileGD) -> void:
	save_file = _save_file
	area = save_file.area
	level = area.active_level
	Game.ActionManagerReference.action_playing.connect(onActionPlaying)
		
	level.draw_card.connect(onDrawCardUI)
	level.phase_changed.connect(onPhaseChanged)
	level.remove_card.connect(onRemoveCardUI)
	level.energy_changed.connect(onUpdateEnergy)
	level.turn_state_changing.connect(onTurnStateChanging)
	level.awakened.connect(onAwakened)
	level.active_effect_used.connect(onActiveEffectUsed)
	level.active_effect_added.connect(onActiveEffectAdded)
	level.boon_added.connect(onBoonAdded)
	level.boon_removed.connect(onBoonRemoved)
	level.boon_activated.connect(onBoonActivated)
	level.boon_ascended.connect(onBoonAscended)
	level.tile_occupied.connect(onTileOccupied)
	level.game_started.connect(onGameStarted)
	level.game_ended.connect(onGameEnded)
	level.tool_removed.connect(onToolRemoved)
	
	level.update_active_effects.connect(onUpdateActiveEffects)
	save_file.update_shillings.connect(onUpdateShillings)
	
	TimeLabel.setInfo(save_file)
	level.camera_change_action.connect(onCameraUpdated)
	
	ArtMiniRect.texture = save_file.getChampionCard().info.getArtMini()
	LevelLabel.text = level.info.name
	World.active_effect_activated.connect(onActiveEffectActivated)
	World.active_effect_deselected.connect(onActiveEffectDeselected)
	World.active_effect_selected.connect(onActiveEffectSelected)
	Console.level = level
	HandBox.level = level
	
	setHeroNameLabel()
	setActiveEffectLabel()
	onUpdateShillings(save_file.shillings)
	onUpdateDeckCardAmountLabel()
	onCameraUpdated(level.getSpectateObject())
	
	for Tile in get_tree().get_nodes_in_group("TilesGD"):
		onTileCreated(Tile)
		
func _process(_delta: float) -> void:
	if HoverCardUI != null:
		setHoverCardUIPosition()
		
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("HideUI") and !level.isGameEnded():
		onHideUI(!visible)
#endregion

#region Action Lock / Mouse In UI
var is_action_playing: bool
func onUpdateActionLock(previous_state: bool) -> void:
	var state: bool = getActionLock()
	if state != previous_state:
		action_lock.emit(state)
		get_tree().call_group("LevelTilesGD", "onUpdateActionLock", state)
		for btn in get_tree().get_nodes_in_group("ActionLockDisabled"):
			if btn == PassButton: btn.setActionLock(state)
			elif btn is Button: btn.setActionLock(state)
			elif btn is HighlightTxButton: btn.setDisabled(state)

func getActionLock() -> bool:
	return is_action_playing

func onMouseInUI(state: bool) -> void:
	if get_viewport().get_mouse_position().y >= get_viewport().size.y - BOTTOM_SCREEN_OFFSET: return
	mouse_in_ui = state
	mouse_signal.emit(mouse_in_ui)
	$MouseInUILabel.text = "Mouse In UI: " + str(mouse_in_ui)

func onActionPlaying(state: bool) -> void:
	if level.isGameEnded(): return
	var previous_state: bool = getActionLock()
	is_action_playing = state
	onChangeVisionMode(false)
	onUpdateActionLock(previous_state)
#endregion

#region Phase
func onPhaseChanged(phase: Game.Phases, _phase: Game.Phases, _instant: bool = false) -> void:
	HandPanel.theme_type_variation = "BluePanelContainer" if phase == Game.Phases.START else "WhitePanelContainer"
	PhaseIcon.setPhase(phase)
	PassButton.setPhase(phase)
	HandBox.setPhase(phase)
	match phase:
		Game.Phases.PLAYER:
			PassButton.setAllySpectating(level.getAllySpectateObject())
#endregion

#region Hand
@onready var HandBox: Container = %HandBox
func onDrawCardUI(Card: CardGD) -> void:
	var CardUI: Control = Card.onCreateCardUI(HandBox, true, true, self)
	Card.setInspectable(true, self)
	CardUI.dragged_begin.connect(onCardDraggedBegin)
	CardUI.dragged_finished.connect(onCardDraggedFinished)
	CardUI.dragged_end.connect(onCardDraggedEnd)
	CardUI.mouse_in_ui.connect(onMouseInUI)
	CardUI.mouse_in_ui.connect(HandBox.onMouseInUI)
	onUpdateDeckCardAmountLabel()
	
func onRemoveCardUI(Card: CardGD) -> void:
	for CardUI in HandBox.get_children():
		if CardUI.Card == Card: CardUI.queue_free()
#endregion

#region Card Dragged
func onCardDraggedEnd(CardUI: Control, dragged_position: Vector2) -> void:
	dragged_end.emit(CardUI.Card, dragged_position, CardUI)
	
	if level.getPhase() in [Game.Phases.HAND, Game.Phases.START]:
		HandBox.onPin()
		
	HandPanel.mouse_filter = Control.MOUSE_FILTER_STOP
	
func onCardDraggedFinished(_CardUI: Control) -> void: # When card comes back to it's orignial position
	HandBox.setDraggedCardUI(null)
	
func onCardDraggedBegin(CardUI: Control) -> void:
	dragged_begin.emit(CardUI)
	HandBox.onUnpin()
	HandBox.setDraggedCardUI(CardUI)
	HandPanel.mouse_filter = Control.MOUSE_FILTER_IGNORE
#endregion

#region Shillings
func onUpdateShillings(shillings: int) -> void:
	ShillingLabel.setText("SH: " + str(shillings))
#endregion
	
#region Energy
func onUpdateEnergy(energy: int) -> void:
	EnergyLabel.text = str(energy) + "/" + str(level.max_energy)
	HandBox.onUpdateEnergy(energy)
#endregion

#region Camera
func onCameraDirectionChanged(direction: int) -> void:
	camera_direction_changed.emit(direction)
	
func _on_camera_button_pressed() -> void:
	camera_button_pressed.emit()
	
func onCameraUpdated(SpectateObject: GameObjectGD, __: GameObjectGD = null) -> void:
	if !World.CameraManager.isCycle():
		setHeroNameLabel(SpectateObject.info.name if (SpectateObject != null and SpectateObject is CardGD) else "")
		PassButton.setAllySpectating(SpectateObject)
		
		onUpdateActiveEffects(SpectateObject)
		Console.onCameraUpdated(SpectateObject)
		
		LeftCameraArrow.setIsInFreelook(SpectateObject == null)
		RightCameraArrow.setIsInFreelook(SpectateObject == null)
#endregion

#region Deck / Graveyard
func _on_deck_button_pressed() -> void:
	var DeckScreen: Control = DeckScreenPacked.instantiate()
	add_child(DeckScreen)
	DeckScreen.setInfo(false)
	
func _on_graveyard_button_pressed() -> void:
	add_child(GraveyardScreenPacked.instantiate())
#endregion

#region Pass Button
func _on_pass_button_pressed() -> void:
	level.onPassTurn()
	World.onPassButtonPressed()
	
func onTurnStateChanging(Card: CardGD, _action: ChangeTurnStateAction) -> void:
	PassButton.setTurnStates(Card)
	if Card == level.SpectateObject:
		onUpdateActiveEffects()
#endregion

#region Hero + Ability Labels
func setHeroNameLabel(text: String = "") -> void:
	HeroNameLabel.text = text
	
func setActiveEffectLabel(text: String = "") -> void:
	ActiveEffectLabel.text = text
#endregion

#region Minimap
var Minimap: Control
func _on_minimap_button_pressed() -> void:
	if Minimap == null:
		Minimap = MinimapPacked.instantiate()
		MinimapControl.add_child(Minimap)
		Minimap.mouse_in_ui.connect(onMouseInUI)
		Minimap.tree_exited.connect(onMinimapRemoved)
		BackgroundDimmer.visible = true
	else:
		Minimap.queue_free()
		onMinimapRemoved()
	
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
	Card.FieldInfo.visible = visible
#endregion

#region Active Effects
func onActiveEffectBoxPressed(active_effect: ActiveEffectDatastore) -> void:
	var tiles: ActiveEffectTiles = null
	if active_effect.owner is IObjectGD: tiles = active_effect.owner.getActiveEffectTiles(active_effect, level.getAllySpectateObject())
	else: tiles = active_effect.owner.getActiveEffectTiles(active_effect)
	
	if !tiles.in_range_tiles.is_empty():
		setActiveEffectLabel(active_effect.name)
		active_effect_box_pressed.emit(active_effect, tiles)
		
func onActiveEffectDeselected() -> void:
	setActiveEffectLabel("")
	onCameraUpdated(level.getSpectateObject())
	PassButton.setAbilityMode(false)
		
func onActiveEffectSelected() -> void:
	PassButton.setAbilityMode(true)
		
func onActiveEffectActivated(_active_effect: ActiveEffectDatastore) -> void:
	onUpdateActiveEffects()
	
func onUpdateActiveEffects(SpectateObject: GameObjectGD = level.getSpectateObject()) -> void:
	var active_effects: Array = []
	var CardSpectate: CardGD = null if SpectateObject is not CardGD else SpectateObject
	if CardSpectate != null:
		active_effects = SpectateObject.active_effects
		if SpectateObject.getTool() != null:
			active_effects += SpectateObject.getTool().active_effects
		
		for IObject in get_tree().get_nodes_in_group("LevelIObjectsGD")\
			.filter(func(x: ObjectGD): return !x.is_queued_for_deletion()):
			active_effects += IObject.getValidActiveEffects(SpectateObject)
			
	ActiveEffects.onUpdate(active_effects, CardSpectate)
#endregion

#region Active Effects
func onActiveEffectUsed(_active_effect: ActiveEffectDatastore) -> void:
	onUpdateActiveEffects()
	
func onActiveEffectAdded(_active_effect: ActiveEffectDatastore) -> void:
	onUpdateActiveEffects()
	
func onToolRemoved() -> void:
	onUpdateActiveEffects()
#endregion

#region Boons
func onBoonAdded(Boon: BoonGD) -> void:
	BoonBox.onAddBoon(Boon)
	
func onBoonRemoved(_id: int) -> void:
	BoonBox.onUpdate()
	
func onBoonActivated(Boon: BoonGD) -> void:
	BoonBox.onUpdateBoonChargesAndDisabled(Boon)
	
func onBoonAscended(Boon: BoonGD) -> void:
	BoonBox.onUpdateBoonAscension(Boon)
#endregion

#region Occupy Tile
func onTileOccupied(Card: CardGD, _Tile: TileGD) -> void:
	if Card.isAlly(0) and Card == level.getSpectateObject():
		onUpdateActiveEffects()
#endregion

#region Game Changers
var RewardsUI: Control
func onGameEnded(rewards: Rewards) -> void:
	await get_tree().process_frame # Necessary for UI to load in
	onHideUI(true)
	if rewards == null:
		var LossUI: Control = LossUIPacked.instantiate()
		add_child(LossUI)
	else:
		RewardsUI = Game.onCreateRewardsUIScreen(rewards, self, level.is_elite)
		RewardsUI.rewards_finished.connect(level.onRewardsFinished)
		MinimapControl = RewardsUI.MinimapControl
		
		var filler := Control.new()
		filler.custom_minimum_size.x = OverworldInformation.size.x
		LeftContainer.add_child(filler)
		LeftContainer.move_child(filler, 0)
		
		for child in [DeckPanel, MapPanel, OverworldInformation]:
			child.reparent(RewardsUI)
	
	onUpdateDeckCardAmountLabel()
	onUpdateActionLock(false)
	for btn in get_tree().get_nodes_in_group("ActionLockDisabled").filter(func(x: Control): return x is HighlightTxButton):
		btn.setDisabled(btn.is_in_group("EndGameDisabled"))
	
	HandBox.onUnpin()
	
func onGameStarted() -> void:
	HandBox.onUnpin()
	HandBox.onSelectableCards(false)
#endregion

#region Deck Amount
func onUpdateDeckCardAmountLabel() -> void:
	DeckCardAmountLabel.text = str(get_tree().get_node_count_in_group("DeckCardsGD"))
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
	elif HoverCardUI == null and state:
		HoverCardUI = Card.onCreateCardUI(HoverCardControl, false, false)
		setHoverCardUIPosition()
		
func setHoverCardUIPosition() -> void:
	HoverCardUI.global_position = get_viewport().get_mouse_position() + HOVER_CARD_OFFSET
#endregion

#region Hide UI
func onHideUI(state: bool) -> void:
	visible = state
	
	for Card in get_tree().get_nodes_in_group("FieldCardsGD").filter(func(x: CardGD): return x.isLevelVisible()):
		Card.FieldInfo.visible = state
		
	for Tile in get_tree().get_nodes_in_group("LevelTilesGD"):
		Tile.onHideUI(state)
#endregion
