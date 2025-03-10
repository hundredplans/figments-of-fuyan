extends Control

signal mouse_in_ui
signal pressed

signal dragged_begin
signal dragged_end
signal dragged_finished

#region Onready
@onready var AreaBackground: ButtonAutomask = %AreaBackground
@onready var Background: ButtonAutomask = %Background
@onready var ArtPop: ButtonAutomask = %ArtPop
@onready var NameLabel: Label = %NameLabel

@onready var AttackLabel: Label = %AttackLabel
@onready var HealthLabel: Label = %HealthLabel
@onready var SpeedLabel: Label = %SpeedLabel
@onready var EnergyLabel: Label = %EnergyLabel
@onready var TextLabel: FancyTextLabel = %TextLabel
@onready var ToolControl: Control = %ToolControl
@onready var ToolIcon: Control = %ToolIcon
@onready var ToolIconBackground: Sprite2D = %ToolIconBackground
@onready var OutlineMask: TextureRect = %OutlineMask

@onready var ArchetypeLabelTemp: Label = %ArchetypeLabelTemp

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
#endregion

#region Exports
@export var white_outline_canvas: ShaderMaterial
@export_group("Admin")
@export var rarities: Array[Image]
@export var ascended_rarities: Array[Image]
@export var masks: Array[Texture2D]
@export var REGULAR_TOOL_ICON_BACKGROUND: Texture2D
@export var ASCENDED_TOOL_ICON_BACKGROUND: Texture2D
#endregion
#region Globals
const CARD_TO_CENTER_HELD_TIMER: float = 0.2
const ROTATION_SPEED_TO_MIDDLE: float = 10.0
const RELATIVE_SIDE_FORCE_DIV: float = 15.0

var Card: CardGD
var highlight_on_hover: bool
var disabled: bool
var selected: bool
var inspectable: bool
var DraggableParent: Control
var child_index: int

var is_held: bool
var original_position: Vector2
var is_held_moving: bool
var offset_to_center: Vector2
var progress_to_center: float = CARD_TO_CENTER_HELD_TIMER # How far along is the Card UI to moving to the center of the mouse
var original_parent: Control
#endregion

func setInfo(_Card: CardGD, _highlight_on_hover: bool = false, _inspectable: bool = true, _DraggableParent: Control = null) -> void:
	highlight_on_hover = _highlight_on_hover
	inspectable = _inspectable
	DraggableParent = _DraggableParent
	
	Card = _Card
	ArchetypeLabelTemp.text = Card.info.archetype.name
	Card.update_ascended.connect(onCardAscended)
	
	Background.setTexture(rarities[Card.info.rarity] if !Card.ascended else ascended_rarities[Card.info.rarity])
	OutlineMask.texture = masks[Card.info.rarity]
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
	
func onUpdateStats() -> void:
	AttackLabel.text = str(Card.base_stats.attack)
	HealthLabel.text = str(Card.base_stats.health)
	SpeedLabel.text = str(Card.base_stats.speed)
	EnergyLabel.text = str(Card.base_stats.energy)
	
func onCardAscended(_state: bool) -> void:
	Background.setTexture(rarities[Card.info.rarity] if !Card.ascended else ascended_rarities[Card.info.rarity])
	onUpdateStats()
	TextLabel.setText(Card.getDescription())
	
func onToolUpdated(Tool: ToolGD) -> void:
	ToolControl.visible = Tool != null
	ToolIcon.setInfo(Tool, false)
	onToolAscended(Tool.ascended if Tool != null else false)
	
func onToolAscended(state: bool) -> void:
	ToolIconBackground.texture = REGULAR_TOOL_ICON_BACKGROUND if !state else ASCENDED_TOOL_ICON_BACKGROUND
	
func onPressed() -> void:
	if disabled: return
	pressed.emit(self)

var is_mouse_in_ui: bool = false
func onMouseHovered(state: bool) -> void:
	is_mouse_in_ui = state
	if is_held: return
	mouse_in_ui.emit(state)
	if highlight_on_hover and !disabled:
		if state: modulate = Color(0.5, 0.5, 0.5)
		else: modulate = Color(1, 1, 1)

func setDisabled(_disabled: bool) -> void:
	disabled = _disabled
	ToolIcon.setDisabled(disabled)
	if disabled:
		onMouseHovered(false)
		onSelected(false)
		modulate = Color(0.2, 0.2, 0.2)
	else: modulate = Color(1, 1, 1)

func onSelected(_selected: bool) -> void:
	selected = _selected
	OutlineMask.material = white_outline_canvas if selected else null
	
const MASSIVE_MOVEMENT_PREVENT: int = 200
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("InspectCard") and is_mouse_in_ui and inspectable and \
	!(get_viewport().gui_get_focus_owner() as LineEdit):
		Card.onInspectCard()
		
	elif event is InputEventMouseMotion and is_held and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		if (event.relative.x + event.relative.y) < MASSIVE_MOVEMENT_PREVENT:
			position += event.relative
			rotation_degrees += event.relative.x / RELATIVE_SIDE_FORCE_DIV
		else:
			position = get_viewport().get_mouse_position() - (size / 2)
		
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
var last_small_offset_to_center: Vector2
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("MainInput") and is_mouse_in_ui and !is_held_moving and DraggableParent != null and !disabled:
		onHeldBegan()
		
	elif Input.is_action_just_released("MainInput") and is_held and !is_held_moving and DraggableParent != null:
		onHeldEnded()
		
	elif Input.is_action_just_pressed("MainInput") and is_mouse_in_ui:
		onPressed()
		
	if DraggableParent != null and progress_to_center < CARD_TO_CENTER_HELD_TIMER:
		progress_to_center += delta
		var sine_progress = sin(progress_to_center / CARD_TO_CENTER_HELD_TIMER * PI * 0.5)
		var small_offset: Vector2 = sine_progress * offset_to_center
		position += (small_offset - last_small_offset_to_center)
		last_small_offset_to_center = small_offset
		
	rotation = lerp_angle(rotation, 0, ROTATION_SPEED_TO_MIDDLE * delta)
		
func onHeldBegan() -> void:
	is_held = true
	is_held_moving = true
	original_position = global_position
	onChangeBackgroundMouseFilter(false)
	
	original_parent = get_parent()
	child_index = get_index()
	get_parent().remove_child(self)
	DraggableParent.add_child(self)
	global_position = original_position
	
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	offset_to_center = mouse_pos - getCenterPos()
	
	progress_to_center = 0
		
	await get_tree().create_timer(CARD_TO_CENTER_HELD_TIMER).timeout
	
	is_held_moving = false
	last_small_offset_to_center = Vector2.ZERO
	
	if !Input.is_action_pressed("MainInput"):
		onHeldEnded()
	else:
		dragged_begin.emit(self)
	
func onHeldEnded() -> void:
	dragged_end.emit(self, getCenterPos())
	is_held = false
	
	offset_to_center = original_position - global_position
	progress_to_center = 0
	
	is_held_moving = true
	await get_tree().create_timer(CARD_TO_CENTER_HELD_TIMER).timeout
	
	is_held_moving = false
	last_small_offset_to_center = Vector2.ZERO
	
	onChangeBackgroundMouseFilter(true)
	if !is_mouse_in_ui: onMouseHovered(is_mouse_in_ui)
	get_parent().remove_child(self)
	original_parent.add_child(self)
	original_parent.move_child(self, child_index)
	global_position = original_position
	dragged_finished.emit(self)
	
func getCenterPos() -> Vector2:
	return global_position + (size / 2)
	
func onChangeBackgroundMouseFilter(is_stop: bool) -> void:
	var new_mouse_filter := Control.MOUSE_FILTER_STOP if is_stop else Control.MOUSE_FILTER_IGNORE
	Background.mouse_filter = new_mouse_filter
	AreaBackground.mouse_filter = new_mouse_filter
	ArtPop.mouse_filter = new_mouse_filter
	TextLabel.mouse_filter = new_mouse_filter
	
	get_viewport().warp_mouse(get_viewport().get_mouse_position())
#endregion

func onMouseInText(state: bool):
	Game.onMouseInUITooltip(state, TextLabel.getInfos(), self, true)
