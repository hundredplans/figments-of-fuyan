extends Control

const ROTATION_DEATH_SPEED: int = 300
const RAINBOW_SPEED: int = 300
const NUMBER_SCALE_TIME: float = 0.15

var type: String = "UnitStatusRegular"

@onready var HoverCard: Control = $HoverCard
@onready var Gem: Sprite2D = %Gem
@onready var ShiftingBackground: Sprite2D = %ShiftingBackground

@onready var Rainbow = %RainbowLight
@onready var Stats: Control = %Stats
@onready var In: Sprite2D = %In
@onready var ArtPop: TextureButton = %ArtPop
@onready var AttackSprite: Sprite2D = %AttackSprite
@onready var HealthSprite: Sprite2D = %HealthSprite 
@onready var SpeedSprite: Sprite2D = %SpeedSprite

@onready var SelectedMask: TextureButton = %SelectedMask 
@onready var SlotOne: Sprite2D = %SlotOne

var card_selected_material: Material = preload("res://assets/base_game/cards/game_card/materials/card_selected_material.tres")
func _ready() -> void:
	Helper.create_button_clickmask(SelectedMask)
	Rainbow.visible = false
	Gem.visible = false
	pivot_offset = size / 2
func onSetUnit(Unit: UnitGD) -> void:
	ShiftingBackground.material = preload("res://scenes/screens/level_ui/unit_status/unit_status_pieces/shifting_background.tres").duplicate()
	
	var path: String = "res://scenes/screens/level_ui/unit_status/unit_status_pieces/zzz.png" if\
	Unit.team == 0 else "res://scenes/screens/level_ui/unit_status/unit_status_pieces/in_range.png"
	SlotOne.texture = load(path)
	
	var card_texture_path: String = "res://assets/base_game/cards/cards/" + Unit.base_card.folder_name + "/art_mini.png"
	ArtPop.texture_normal = load(card_texture_path)
	HoverCard.base_card = Unit.base_card
	
func onUpdateStat(stat: int, stat_changed: String, color: Color) -> void:
	var ScaleTween := create_tween()
	var StatLabel: Label = Stats.get_node(stat_changed + "/Label")
	ScaleTween.tween_property(StatLabel, "scale:y", 0, NUMBER_SCALE_TIME)
	ScaleTween.finished.connect(onUpdateStatBounceBack.bind(stat, stat_changed, color))
	HoverCard.onUpdateStat(stat, stat_changed)
func onUpdateStatBounceBack(stat: int, stat_changed: String, color: Color) -> void:
	var StatLabel: Label = get(stat_changed + "Label")
	
	StatLabel.text = str(stat)
	StatLabel.label_settings = preload("res://assets/UI/sixty_four/sixty_four_default.tres")\
	if StatLabel.text.length() == 1 else preload("res://assets/UI/sixty_four/sixty_four_medium.tres")
	StatLabel.modulate = color
	
	var ScaleTween := create_tween()
	ScaleTween.tween_property(StatLabel, "scale:y", 1, NUMBER_SCALE_TIME)
	#get_node("HoverCard/Buffs/HBoxContainer/" + stat + "/Label").text = ("+" if val >= 0 else "") + str(val)

var on_rotate_queue_free: bool = false
func _process(delta: float) -> void:
	if Rainbow.visible: Rainbow.rotation_degrees += RAINBOW_SPEED * delta
	if on_rotate_queue_free: rotation_degrees += delta * ROTATION_DEATH_SPEED
func onSetUnitStatusState(speed: float, color: Color, turn_active: bool) -> void:
	ShiftingBackground.material.set_shader_parameter("speed", speed)
	ShiftingBackground.material.set_shader_parameter("modulate", color)
	Gem.visible = turn_active
	SelectedMask.material = card_selected_material if turn_active else null
func onSetLightMask(state: int) -> void:
	for node in [In, ArtPop, AttackSprite, HealthSprite, SpeedSprite, SelectedMask]:
		node.light_mask = state
