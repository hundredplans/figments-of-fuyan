extends TbcUI

#region Onready
@onready var BigTierLabel: Label = %BigTierLabel
@onready var TierLabel: Label = %TierLabel

@onready var AreaBackground: ButtonAutomask = %AreaBackground
@onready var Background: ButtonAutomask = %Background
@onready var ArtPop: ButtonAutomask = %ArtPop
@onready var NameLabel: Label = %NameLabel

@onready var RaycastArea: Area2D = %RaycastArea
@onready var AttackLabel: Label = %AttackLabel
@onready var HealthLabel: Label = %HealthLabel
@onready var SpeedLabel: Label = %SpeedLabel
@onready var EnergyLabel: Label = %EnergyLabel
@onready var TextLabel: FancyTextLabel = %TextLabel
@onready var ToolControl: Control = %ToolControl
@onready var ToolIcon: TbcUI = %ToolIcon
@onready var ToolInside: Sprite2D = %ToolInside
@onready var ToolOutside: Sprite2D = %ToolOutside

@onready var BuffControlAttack: Control = %BuffControlAttack
@onready var BuffLabelAttack: Label = %BuffLabelAttack
@onready var BuffLabelAttackSign: Label = %BuffLabelAttackSign

@onready var BuffControlHealth: Control = %BuffControlHealth
@onready var BuffLabelHealth: Label = %BuffLabelHealth
@onready var BuffLabelHealthSign: Label = %BuffLabelHealthSign

@onready var BuffControlSpeed: Control = %BuffControlSpeed
@onready var BuffLabelSpeed: Label = %BuffLabelSpeed
@onready var BuffLabelSpeedSign: Label = %BuffLabelSpeedSign

@onready var TemporaryCardMarker: TextureRect = %TemporaryCardMarker
@onready var AwakenedInCombatMarker: TextureRect = %AwakenedInCombatMarker
@onready var Ring: Sprite2D = %Ring

@export var rarities: Array[Image]

#region Globals
var Card: CardGD
var ignore_mouse: bool
var inspectable: bool
var child_index: int

var is_held: bool
var original_position: Vector2
var is_held_moving: bool
var offset_to_center: Vector2
var original_parent: Control
#endregion

const OUTLINE_PIXEL_SIZE: int = 3

func setInfo(_Card: CardGD, _hoverable: bool = false, _inspectable: bool = true, _draggable: bool = false, _autoscale: bool = false) -> void:
	hoverable = _hoverable
	inspectable = _inspectable
	draggable = _draggable
	autoscale = _autoscale
	
	Card = _Card
	
	Background.setTexture(rarities[Card.info.rarity])
	ArtPop.setTexture(Card.info.art_pop)
	TextLabel.setText(Card.getDescription())
	AreaBackground.setTexture(Card.getArea().card_background)
	NameLabel.text = Card.info.name
	
	onUpdateTemporaryCardMarker()
	onUpdateAwakenedInCombat()
	onToolUpdated(Card.Tool)
	onUpdateStats()
	
	Card.update_stats.connect(onUpdateStats)
	Card.tool_updated.connect(onToolUpdated)
	Card.is_temporary_updated.connect(onUpdateTemporaryCardMarker)
	Card.awakened_in_combat.connect(onUpdateAwakenedInCombat)
	Card.update_tier.connect(onUpdateTier)
	
	onUpdateTier(Card.getTier())
	
func onUpdateTier(tier: int) -> void:
	onUpdateStats()
	TextLabel.setText(Card.getDescription(true))
	TierLabel.text = str(Game.getTierString(tier))
	NameLabel.modulate = Game.getTierColor(tier)
	
func onUpdateStats() -> void:
	AttackLabel.text = str(Card.base_stats.attack)
	HealthLabel.text = str(Card.base_stats.health)
	SpeedLabel.text = str(Card.base_stats.speed)
	EnergyLabel.text = str(Card.base_stats.energy)
	#
	#var energy_modulate: Color
	#if Card.energy > Card.base_stats.energy: energy_modulate = Color.RED
	#elif Card.energy == Card.base_stats.energy: energy_modulate = Color.WHITE
	#else: energy_modulate = Color.GREEN
	#EnergyLabel.modulate = energy_modulate
	
func onToolUpdated(Tool: ToolGD) -> void:
	ToolControl.visible = Tool != null
	ToolIcon.setTool(Tool)
	
	if Tool != null:
		ToolInside.modulate = Game.getRarityColor(Tool.getRarity())
		onToolUpdateTier(Tool.getTier())
		Tool.update_tier.connect(onToolUpdateTier)

func onToolUpdateTier(tier: int) -> void:
	ToolOutside.modulate = Game.getTierColor(tier)

func setDisabled(_disabled: bool) -> void:
	disabled = _disabled
	ToolIcon.setDisabled(disabled)
	if disabled:
		onMouseInUI(false)
	onUpdateModulate()
	
const MASSIVE_MOVEMENT_PREVENT: int = 200
func _input(event: InputEvent) -> void:
	super(event)
	if Input.is_action_just_pressed("InspectCard") and is_mouse_in_ui and inspectable and \
	!(get_viewport().gui_get_focus_owner() as LineEdit):
		Card.onInspectCard()
		
func setBuffLabels() -> void:
	var attack_diff: int = Card.attack - Card.base_stats.attack
	var health_diff: int = Card.health - Card.base_stats.health
	var speed_diff: int = Card.max_speed - Card.base_stats.speed
	
	if attack_diff != 0:
		BuffControlAttack.visible = true
		BuffLabelAttack.text = str(abs(attack_diff))
		BuffLabelAttackSign.text = "+" if attack_diff > 0 else "-"
		
	if health_diff != 0:
		BuffControlHealth.visible = true
		BuffLabelHealth.text = str(abs(health_diff))
		BuffLabelHealthSign.text = "+" if health_diff > 0 else "-"
		
	if speed_diff != 0:
		BuffControlSpeed.visible = true
		BuffLabelSpeed.text = str(abs(speed_diff))
		BuffLabelSpeedSign.text = "+" if speed_diff > 0 else "-"

func onUpdateTemporaryCardMarker() -> void:
	TemporaryCardMarker.visible = Card.isTemporary()

func onUpdateAwakenedInCombat() -> void:
	AwakenedInCombatMarker.visible = Card.is_awakened_in_combat

#region Holding
	
func getCenterPos() -> Vector2:
	return global_position + (size / 2)
	
func onChangeBackgroundMouseFilter(is_stop: bool, ignore_tool: bool = false) -> void:
	var new_mouse_filter := Control.MOUSE_FILTER_STOP if is_stop else Control.MOUSE_FILTER_IGNORE
	Background.mouse_filter = new_mouse_filter
	AreaBackground.mouse_filter = new_mouse_filter
	ArtPop.mouse_filter = new_mouse_filter
	TextLabel.mouse_filter = new_mouse_filter
	
	if !ignore_tool:
		ToolIcon.setMouseFilter(new_mouse_filter)
	
	get_viewport().update_mouse_cursor_state()
	
func setMouseFilter(_mouse_filter: Control.MouseFilter) -> void:
	super(_mouse_filter)
	if _mouse_filter == Control.MouseFilter.MOUSE_FILTER_STOP: onChangeBackgroundMouseFilter(true)
	else: onChangeBackgroundMouseFilter(false)
#endregion

func onMouseInText(state: bool):
	if disable_tooltip: return
	Game.onMouseInUITooltip(state, TextLabel.getInfos(), self, true)

func setDisableTooltip(state: bool) -> void:
	disable_tooltip = state
	ToolIcon.disable_tooltip = state

func getCard() -> CardGD:
	return Card

func getTool() -> ToolGD:
	return ToolIcon.Tool

func getPriceLabelPosition() -> Vector2:
	return Vector2(100, 400)

func getItem() -> FofGD: return Card
	
func getToolIcon() -> TbcUI:
	return ToolIcon

func setDeckCardUICollisionLayer() -> void:
	RaycastArea.collision_layer = 4 + 32

func onShowTierLabel() -> void:
	BigTierLabel.modulate = Game.getTierColor(Card.getTier())
	BigTierLabel.text = "Tier " + Game.getTierString(Card.getTier())
