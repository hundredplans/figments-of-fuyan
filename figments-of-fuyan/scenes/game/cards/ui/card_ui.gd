extends Control

signal mouse_in_ui
signal pressed
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
@onready var OutlineMask: TextureRect = %OutlineMask

@onready var BuffControlAttack: Control = %BuffControlAttack
@onready var BuffLabelAttack: Label = %BuffLabelAttack
@onready var BuffLabelAttackSign: Label = %BuffLabelAttackSign

@onready var BuffControlHealth: Control = %BuffControlHealth
@onready var BuffLabelHealth: Label = %BuffLabelHealth
@onready var BuffLabelHealthSign: Label = %BuffLabelHealthSign

@onready var BuffControlSpeed: Control = %BuffControlSpeed
@onready var BuffLabelSpeed: Label = %BuffLabelSpeed
@onready var BuffLabelSpeedSign: Label = %BuffLabelSpeedSign

#endregion
#region Exports
@export var white_outline_canvas: ShaderMaterial
@export_group("Admin")
@export var rarities: Array[Image]
@export var ascended_rarities: Array[Image]
@export var masks: Array[Texture2D]

#endregion
#region Globals
var Card: CardGD
var highlight_on_hover: bool
var disabled: bool
var selected: bool
#endregion

func setInfo(_Card: CardGD, _highlight_on_hover: bool = false) -> void:
	Card = _Card
	Card.update_ascended.connect(onCardAscended)
	
	highlight_on_hover = _highlight_on_hover
	Background.setTexture(rarities[Card.info.rarity] if !Card.ascended else ascended_rarities[Card.info.rarity])
	OutlineMask.texture = masks[Card.info.rarity]
	ArtPop.setTexture(Card.info.art_pop)
	TextLabel.setText(Card.getDescription())
	AreaBackground.setTexture(Card.getArea().card_background)
	NameLabel.text = Card.info.name
	AttackLabel.text = str(Card.attack)
	HealthLabel.text = str(Card.health)
	SpeedLabel.text = str(Card.speed)
	EnergyLabel.text = str(Card.energy)
	
	onToolAdded(Card.Tool)
	Card.tool_added.connect(onToolAdded)
	
func onCardAscended(_state: bool) -> void:
	Background.setTexture(rarities[Card.info.rarity] if !Card.ascended else ascended_rarities[Card.info.rarity])
	
func onToolAdded(Tool: ToolGD) -> void:
	ToolControl.visible = Tool != null
	ToolIcon.setInfo(Tool, false)
	
func onPressed() -> void:
	if !disabled: pressed.emit(self)

var is_mouse_in_ui: bool = false
func onMouseHovered(state: bool) -> void:
	is_mouse_in_ui = state
	mouse_in_ui.emit(state)
	if highlight_on_hover and !disabled:
		if state: modulate = Color(0.5, 0.5, 0.5)
		else: modulate = Color(1, 1, 1)

func setDisabled(_disabled: bool) -> void:
	disabled = _disabled
	if disabled:
		onMouseHovered(false)
		onSelected(false)
		modulate = Color(0.2, 0.2, 0.2)
	else: modulate = Color(1, 1, 1)

func onSelected(_selected: bool) -> void:
	selected = _selected
	OutlineMask.material = white_outline_canvas if selected else null
	
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("InspectCard") and is_mouse_in_ui:
		Card.onInspectCard()
		
func setBuffLabels() -> void:
	var attack_diff: int = Card.attack - Card.info.attack
	var health_diff: int = Card.health - Card.max_health
	var speed_diff: int = Card.max_speed - Card.info.speed
	
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
