extends Control

#region Onready
@onready var HandBoxArea: Area2D = %HandBoxArea
@onready var HandPanel: PanelContainer = %HandPanel
@onready var HandPanelAnimationPlayer: AnimationPlayer = %HandPanelAnimationPlayer
@onready var ShillingLabel: FancyTextLabel = %ShillingLabel
@onready var LevelLabel: Label = %LevelLabel
@onready var ArtMiniRect: TextureRect = %ArtMiniRect

@onready var EnergyLabel: Label = %EnergyLabel
@onready var PhaseIcon: TextureRect = %PhaseIcon
@onready var HeroNameLabel: Label = %HeroNameLabel
@onready var AbilityNameLabel: Label = %AbilityNameLabel
#endregion

#region Globals
signal mouse_signal
signal camera_button_pressed
signal action_lock
signal card_selected
signal camera_direction_changed
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
	save_file.update_shillings.connect(onUpdateShillings)
	
	World.camera_updated.connect(onCameraUpdated)
	
	HandBox.setInfo(HandPanelAnimationPlayer, HandBoxArea)
	ArtMiniRect.texture = save_file.getChampionCard().info.getArtMini()
	LevelLabel.text = level.info.name
	
	setHeroNameLabel()
	setAbilityNameLabel()
	onUpdateEnergy(level.energy)
	onUpdateShillings(save_file.shillings)
#endregion

#region Action Lock / Mouse In UI
var is_action_playing: bool
func onUpdateActionLock() -> void:
	action_lock.emit(getActionLock())

func getActionLock() -> bool:
	return is_action_playing

func onMouseInUI(state: bool) -> void:
	mouse_in_ui = state
	mouse_signal.emit(mouse_in_ui)

func onActionPlaying(state: bool) -> void:
	is_action_playing = state
	onUpdateActionLock()
#endregion

#region Phase
func onPhaseChanged(phase: Game.Phases, _instant: bool = false) -> void:
	HandPanel.theme_type_variation = "BluePanelContainer" if phase == Game.Phases.START else "WhitePanelContainer"
	PhaseIcon.setPhase(phase)
	match phase:
		Game.Phases.START, Game.Phases.HAND:
			HandBox.onPin()
			HandBox.onSelectableCards(true)
		Game.Phases.PLAYER:
			HandBox.onUnpin()
			HandBox.onSelectableCards(false)
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
	
func onCameraUpdated(SpectateObject: Variant, _OldSpectateObject: Variant) -> void:
	setHeroNameLabel(SpectateObject.info.name if SpectateObject is CardGD else "")
		
#endregion

#region Deck / Graveyard
func _on_deck_button_pressed() -> void:
	add_child(DeckScreenPacked.instantiate())
	
func _on_graveyard_button_pressed() -> void:
	add_child(GraveyardScreenPacked.instantiate())
#endregion

#region Pass Button
func _on_pass_button_pressed() -> void:
	level.onPassTurn()
#endregion

#region Hero + Ability Labels
func setHeroNameLabel(text: String = "") -> void:
	HeroNameLabel.text = text
	
func setAbilityNameLabel(text: String = "") -> void:
	AbilityNameLabel.text = text
#endregion

#region Minimap
var Minimap: Control
func _on_minimap_button_pressed() -> void:
	if Minimap != null:
		Minimap = MinimapPacked.instantiate()
		add_child(Minimap)
#endregion
