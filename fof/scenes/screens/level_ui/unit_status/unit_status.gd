extends Control

const ROTATION_DEATH_SPEED: int = 300
const RAINBOW_SPEED: int = 300
const NUMBER_SCALE_TIME: float = 0.15

signal target_ability_pressed
var type: String = "UnitStatusRegular"

@onready var UnitFX: GridContainer = %UnitFX
@onready var TargetAbilities: HBoxContainer = %TargetAbilities
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
	
var Unit: UnitGD
func setUnit(_Unit: UnitGD) -> void:
	Unit = _Unit
	ShiftingBackground.material = preload("res://scenes/screens/level_ui/unit_status/unit_status_pieces/shifting_background.tres").duplicate()
	
	var path: String = "res://scenes/screens/level_ui/unit_status/unit_status_pieces/zzz.png" if\
	Unit.team == 0 else "res://scenes/screens/level_ui/unit_status/unit_status_pieces/in_range.png"
	SlotOne.texture = load(path)
	
	var card_texture_path: String = "res://assets/base_game/cards/cards/" + Unit.base_card.folder_name + "/art_mini.png"
	ArtPop.texture_normal = load(card_texture_path)
	HoverCard.Unit = Unit
	HoverCard.Buffs.Unit = Unit
	
	for stat in ["Attack", "Health", "Speed"]:
		var StatLabel: Label = Stats.get_node(stat + "/Label")
		StatLabel.text = str(Unit.get(stat.to_lower()))
	
	onCreateAbilities()
	for fx in Unit.unit_fx:
		onAddUnitFX(fx[0], fx[1])
	
func onCreateAbilities() -> void:
	for ability in Unit.abilities:
		if ability is TargetAbilityGD:
			var TargetAbilityBtn: Control = preload("res://assets/base_game/cards/game_card/art/target_ability/target_ability_button.tscn").instantiate()
			TargetAbilityBtn.ability = ability
			TargetAbilityBtn.pressed.connect(onTargetAbilityBtnPressed.bind(ability))
			TargetAbilities.add_child(TargetAbilityBtn)
			onUpdateAbility(ability, true)
	
func onUpdateStat(stat: int, stat_changed: String, color: String) -> void:
	var ScaleTween := create_tween()
	var StatLabel: Label = Stats.get_node(stat_changed + "/Label")
	ScaleTween.tween_property(StatLabel, "scale:y", 0, NUMBER_SCALE_TIME)
	ScaleTween.finished.connect(onUpdateStatBounceBack.bind(stat, stat_changed, color))
	HoverCard.onUpdateStat(stat, stat_changed)
func onUpdateStatBounceBack(stat: int, stat_changed: String, color: String) -> void:
	var StatLabel: Label = Stats.get_node(stat_changed + "/Label")
	
	StatLabel.text = str(stat)
	StatLabel.label_settings = preload("res://assets/UI/sixty_four/sixty_four_default.tres")\
	if StatLabel.text.length() == 1 else preload("res://assets/UI/sixty_four/sixty_four_medium.tres")
	StatLabel.modulate = COLOR_INFO[color]
	
	var ScaleTween := create_tween()
	ScaleTween.tween_property(StatLabel, "scale:y", 1, NUMBER_SCALE_TIME)

var COLOR_INFO: Dictionary = {}
var on_rotate_queue_free: bool = false
func _process(delta: float) -> void:
	if Rainbow.visible: Rainbow.rotation_degrees += RAINBOW_SPEED * delta
	if on_rotate_queue_free: rotation_degrees += delta * ROTATION_DEATH_SPEED
func setUnitStatusState(state_type: String) -> void:
	ShiftingBackground.material.set_shader_parameter("speed", speeds[state_type])
	ShiftingBackground.material.set_shader_parameter("modulate", modulates[state_type])
	Gem.visible = state_type == "TurnActive"
	SelectedMask.material = card_selected_material if state_type == "TurnActive" else null
func setLightMask(state: bool) -> void:
	for node in [In, ArtPop, AttackSprite, HealthSprite, SpeedSprite, SelectedMask]:
		node.light_mask = 32 if state else 0

func onUpdateAbility(ability: AbilityGD, disable_state: bool) -> void:
	for AbilityButton in TargetAbilities.get_children():
		if AbilityButton.ability == ability:
			AbilityButton.onUpdateAbility(Unit, disable_state)
			break
			
var speeds: Dictionary = {}
var modulates: Dictionary = {}

func onTargetAbilityBtnPressed(ability: TargetAbilityGD) -> void:
	target_ability_pressed.emit(Unit, ability)

func onAddUnitFX(fx_type: String, charges: int = -1) -> void:
	if charges == -1:
		pass
	else:
		var label_fx := preload("res://scenes/screens/level_ui/unit_status/unit_fx/label_fx/label_fx.tscn").instantiate()
		UnitFX.add_child(label_fx)
		label_fx.setFX(fx_type, charges)
