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

@onready var PageArrows: Control = %PageArrows
@onready var Rainbow = %RainbowLight
@onready var Stats: Control = %Stats
@onready var In: Sprite2D = %In
@onready var ArtPop: TextureButton = %ArtPop
@onready var AttackSprite: Sprite2D = %AttackSprite
@onready var HealthSprite: Sprite2D = %HealthSprite 
@onready var SpeedSprite: Sprite2D = %SpeedSprite

@onready var SelectedMask: TextureButton = %SelectedMask 
@onready var SlotOne: Sprite2D = %SlotOne
@onready var AniPlayer: AnimationPlayer = $AnimationPlayer

var card_selected_material: Material = preload("res://assets/base_game/cards/game_card/materials/card_selected_material.tres")
func _ready() -> void:
	Helper.create_button_clickmask(SelectedMask)
	for child in PageArrows.get_children():
		Helper.create_button_clickmask(child)
		child.visible = false
	Rainbow.visible = false
	Gem.visible = false
	pivot_offset = size / 2
	AniPlayer.play("ScaleStatSlight")
	
	
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
		var value: int = Unit.get(stat.to_lower())
		StatLabel.text = str(value)
		setStatColorSize(StatLabel, value, Unit.onFindStatColor(stat.to_lower()))
	
	onCreateAbilities()
	for info_fx in Unit.unit_fx: onAddUnitFX(info_fx)
	if type == "UnitStatusRegular": visible = false
	
func onCreateAbilities() -> void:
	for ability in Unit.abilities:
		if ability is TargetAbilityGD:
			var TargetAbilityBtn: Control = preload("res://assets/base_game/cards/game_card/art/target_ability/target_ability_button.tscn").instantiate()
			TargetAbilityBtn.ability = ability
			TargetAbilityBtn.pressed.connect(onTargetAbilityBtnPressed.bind(ability))
			TargetAbilities.add_child(TargetAbilityBtn)
			onUpdateAbility(ability)
	
func onUpdateStat(stat: int, stat_changed: String, color: String) -> void:
	var ScaleTween := create_tween()
	var StatLabel: Label = Stats.get_node(stat_changed + "/Label")
	ScaleTween.tween_property(StatLabel, "scale:y", 0, NUMBER_SCALE_TIME)
	ScaleTween.finished.connect(onUpdateStatBounceBack.bind(stat, stat_changed, color))
	HoverCard.onUpdateStat(stat, stat_changed)
func onUpdateStatBounceBack(stat: int, stat_changed: String, color: String) -> void:
	var StatLabel: Label = Stats.get_node(stat_changed + "/Label")
	setStatColorSize(StatLabel, stat, color)
	var ScaleTween := create_tween()
	ScaleTween.tween_property(StatLabel, "scale:y", 1, NUMBER_SCALE_TIME)

func setStatColorSize(StatLabel: Label, stat: int, color: String) -> void:
	StatLabel.text = str(stat)
	
	if StatLabel.text.length() > 1: StatLabel.label_settings = preload("res://assets/UI/sixty_four/sixty_four_small.tres")
	else: StatLabel.label_settings = preload("res://assets/UI/sixty_four/sixty_four_medium.tres")
	StatLabel.modulate = COLOR_INFO[color]

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

func onUpdateAbility(ability: AbilityGD) -> void:
	var disable_state: bool = !Unit.Units.Combat.isAbilityEnabled(Unit, ability)
	for AbilityButton in TargetAbilities.get_children():
		if AbilityButton.ability == ability:
			AbilityButton.onUpdateAbility(Unit, disable_state)
			break
			
var speeds: Dictionary = {}
var modulates: Dictionary = {}

func onTargetAbilityBtnPressed(ability: TargetAbilityGD) -> void:
	target_ability_pressed.emit(Unit, ability)

func onAddUnitFX(info_fx: InfoFXGD) -> Control:
	var base_fx := preload("res://scenes/screens/level_ui/unit_status/unit_fx/base_fx.tscn").instantiate()
	base_fx.setInfoFX(info_fx)
	UnitFX.add_child(base_fx)
	onChangePage(0)
	return base_fx

func onRemoveUnitFX(fx_type: String, AppliedBy: AppliedByGD) -> void:
	for child in UnitFX.get_children():
		if child.info_fx.fx_type == fx_type and (AppliedBy.Applier == child.info_fx.Unit):
			child.queue_free()
	onChangePage(0)

func onCreateBuffNextTurn(stat: String, value: int, color: Color) -> void:
	var prefix: String = "down" if value < 0 else "up"
	var arrow_value: int = 0
	match abs(value):
		1: arrow_value = 1
		2, 3: arrow_value = 2
		_: arrow_value = 3
	
	var stat_node: TextureRect = Stats.get_node(stat.capitalize() + "/NextTurnStats/" + stat.capitalize())
	stat_node.texture = load("res://scenes/screens/level_ui/next_turn_buffs/" + prefix + str(arrow_value) + ".png")
	stat_node.modulate = color
	stat_node.visible = true

func onRemoveBuffNextTurn(stat: String) -> void:
	var stat_node: TextureRect = Stats.get_node(stat.capitalize() + "/NextTurnStats/" + stat.capitalize())
	stat_node.texture = null
	stat_node.visible = false

func onCreateHealNextTurn(color: Color) -> void:
	var stat_node: TextureRect = Stats.get_node("Health/NextTurnStats/Heal")
	stat_node.texture = preload("res://scenes/screens/level_ui/next_turn_buffs/up_heal.png")
	stat_node.modulate = color
	stat_node.visible = true

func onRemoveHealNextTurn() -> void:
	Stats.get_node("Health/NextTurnStats/Heal").texture = null
	Stats.get_node("Health/NextTurnStats/Heal").visible = false

var page: int = 0
func onSortUnitFXChildren() -> void:
	@warning_ignore("integer_division")
	var max_page: int = UnitFX.get_child_count() / 9
	for child in PageArrows.get_children(): child.visible = max_page > 1
	
	var vis_range: Array = range(page * 9, (page + 1) * 9)
	for i in range(UnitFX.get_child_count()):
		UnitFX.get_child(i).visible = i in vis_range

func onChangePage(i: int) -> void:
	@warning_ignore("integer_division")
	var max_page: int = UnitFX.get_child_count() / 9
	page = clamp(page + i, 0, max_page)
	
	onSortUnitFXChildren()
	if max_page > 1:
		PageArrows.get_child(0).disabled = page == 0
		PageArrows.get_child(1).disabled = page == max_page
	
