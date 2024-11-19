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
#endregion

#region Globals
signal mouse_signal
signal camera_button_pressed
signal action_lock
signal card_selected
signal camera_direction_changed
signal vision_mode_changed
signal active_effect_box_pressed
signal active_effect_added
signal tile_occupied

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
@export var RewardsUIPacked: PackedScene
@export var ToolPickedUpUIPacked: PackedScene
@export var RewardsCardsPacked: PackedScene
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
	level.game_ended.connect(onGameEnded)
	level.tool_picked_up.connect(onToolPickedUp)
	level.cards_picked_up.connect(onCardsPickedUp)
	save_file.update_shillings.connect(onUpdateShillings)
	
	TimeLabel.setInfo(save_file)
	level.camera_change_action.connect(onCameraUpdated)
	
	ArtMiniRect.texture = save_file.getChampionCard().info.getArtMini()
	LevelLabel.text = level.info.name
	World.active_effect_activated.connect(onActiveEffectActivated)
	World.active_effect_deselected.connect(onActiveEffectDeselected)
	Console.level = level
	HandBox.level = level
	
	setHeroNameLabel()
	setActiveEffectLabel()
	onUpdateShillings(save_file.shillings)
	
	for Card in get_tree().get_nodes_in_group("FieldCardsGD"): onAwakened(Card)
	
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
			elif btn is Button: btn.disabled = state
			elif btn is HighlightTxButton: btn.setDisabled(state)

func getActionLock() -> bool:
	return is_action_playing

func onMouseInUI(state: bool) -> void:
	mouse_in_ui = state
	mouse_signal.emit(mouse_in_ui)

func onActionPlaying(state: bool) -> void:
	if level.is_ended: return
	var previous_state: bool = getActionLock()
	is_action_playing = state
	onChangeVisionMode(false)
	onUpdateActionLock(previous_state)
#endregion

#region Phase
func onPhaseChanged(phase: Game.Phases, _instant: bool = false) -> void:
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
	var CardUI: Control = Card.onCreateCardUI(HandBox, true)
	Card.setInspectable(true, self)
	CardUI.pressed.connect(onSelectCard)
	CardUI.mouse_in_ui.connect(onMouseInUI)
	
func onRemoveCardUI(Card: CardGD) -> void:
	for CardUI in HandBox.get_children():
		if CardUI.Card == Card: CardUI.queue_free()
#endregion

#region Card Select
func onSelectCard(CardUI: Control) -> void:
	CardUI.onSelected(!CardUI.selected)
	card_selected.emit(CardUI.selected)
	
func getSelectedCard() -> CardGD:
	for CardUI in HandBox.get_children():
		if CardUI.selected: return CardUI.Card
	return null
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
	
func onTurnStateChanging(Card: CardGD) -> void:
	PassButton.setIsAllyInactiveActive(Card)
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
	if Minimap != null:
		Minimap = MinimapPacked.instantiate()
		add_child(Minimap)
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
		
func onActiveEffectActivated(_active_effect: ActiveEffectDatastore) -> void:
	onUpdateActiveEffects()
	
func onUpdateActiveEffects(SpectateObject: GameObjectGD = level.getSpectateObject()) -> void:
	var active_effects: Array = []
	var CardSpectate: CardGD = null if SpectateObject is not CardGD else SpectateObject
	if CardSpectate != null:
		active_effects = SpectateObject.active_effects
		if SpectateObject.getTool() != null:
			active_effects += SpectateObject.getTool().active_effects
		
		for IObject in get_tree().get_nodes_in_group("LevelIObjectsGD"):
			active_effects += IObject.getValidActiveEffects(SpectateObject)
			
	ActiveEffects.onUpdate(active_effects, CardSpectate)
#endregion

#region Active Effects
func onActiveEffectUsed(_active_effect: ActiveEffectDatastore) -> void:
	onUpdateActiveEffects()
	
func onActiveEffectAdded(_active_effect: ActiveEffectDatastore) -> void:
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

#region Game Ended
func onGameEnded(rewards: Rewards) -> void:
	
	if rewards == null:
		var LossUI: Control = LossUIPacked.instantiate()
		add_child(LossUI)
	else:
		var RewardsUI: Control = RewardsUIPacked.instantiate()
		add_child(RewardsUI)
		
		for child in [DeckPanel, MapPanel, ShillingLabel]:
			child.z_index = 1
		
		RewardsUI.setInfo(rewards)
		RewardsUI.add_reward.connect(level.onAddReward)
		RewardsUI.rewards_finished.connect(level.onRewardsFinished)
		level.reward_taken.connect(RewardsUI.onRewardTaken)
	
	onUpdateActionLock(false)
	for btn in get_tree().get_nodes_in_group("EndGameDisabled"):
		btn.disabled = true
	
	HandBox.onUnpin()
	
func onToolPickedUp(Tool: ToolGD) -> void:
	var ToolPickedUpUI: Control = ToolPickedUpUIPacked.instantiate()
	add_child(ToolPickedUpUI)
	ToolPickedUpUI.setInfo(Tool, save_file)
	ToolPickedUpUI.taken.connect(onRewardTaken)
	
func onCardsPickedUp(cards: Array) -> void:
	var RewardsCards: Control = RewardsCardsPacked.instantiate()
	add_child(RewardsCards)
	RewardsCards.setInfo(cards, save_file)
	RewardsCards.taken.connect(onRewardTaken)
	
func onRewardTaken(reward: Variant) -> void:
	level.onRewardTaken(reward)
#endregion
