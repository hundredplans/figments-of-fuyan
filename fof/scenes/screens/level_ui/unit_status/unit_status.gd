extends Control

var UnitStatusExtra: Control
var is_model: bool
var Heroes: HeroesGD

var Unit: UnitGD
@onready var oHoverCard: Control = $HoverCard
@onready var Gem: Sprite2D = %Gem
@onready var ShiftingBackground: Sprite2D = %ShiftingBackground

@onready var Stats: Control = %Stats
@onready var In: Sprite2D = %In
@onready var ArtPop: TextureButton = %ArtPop
@onready var AttackSprite: Sprite2D = %AttackSprite
@onready var HealthSprite: Sprite2D = %HealthSprite 
@onready var SpeedSprite: Sprite2D = %SpeedSprite

@onready var SelectedMask: TextureButton = %SelectedMask 
@onready var SlotOne: Sprite2D = %SlotOne

var card_selected_material: Material = preload("res://assets/base_game/cards/card_ui/card_selected_material.tres")
func _ready() -> void:
	Helper.create_button_clickmask(SelectedMask)
	oHoverCard.visible = false
	Rainbow.visible = false
	pivot_offset = size / 2

func on_set_unit(_Unit: UnitGD) -> void:
	Unit = _Unit
	Gem.visible = false
	
	ShiftingBackground.material = preload("res://scenes/screens/level_ui/unit_status/unit_status_pieces/shifting_background.tres").duplicate()
	ShiftingBackground.material.set_shader_parameter("modulate", modulates["TurnUnused"] if Unit.team == 0 else Color("c11e00")) 
	if Unit.team == 1: ShiftingBackground.material.set_shader_parameter("speed", 0.02)
	
	var path: String = "res://scenes/screens/level_ui/unit_status/unit_status_pieces/zzz.png" if\
	Unit.team == 0 else "res://scenes/screens/level_ui/unit_status/unit_status_pieces/in_range.png"
	SlotOne.texture = load(path)
	
	for stat in ["speed", "attack", "health"]: on_reset_stats(stat)
	on_set_status_box_modulate("TurnUsed")
	on_reset_status_effects()
	on_reset_tool()
	
	var hero_bgfn: String = Unit.base_card.bgfn if Unit.rarity != 7 else Helper.id_to_dict(Heroes.id_to_base(Unit.id), "Card").bgfn
	var card_texture_path: String = "res://assets/base_game/cards/" + hero_bgfn + "/art_mini.png"
	ArtPop.texture_normal = load(card_texture_path)

@onready var AttackLabel: Label = $Stats/Attack/Label
@onready var HealthLabel: Label = $Stats/Health/Label
@onready var SpeedLabel: Label = $Stats/Speed/Label
@export var NUMBER_SCALE_TIME: float = 0.15

func on_reset_stats(stat_changed: String) -> void:
	stat_changed = stat_changed.capitalize()
	var attack_modulate: String
	var health_modulate: String
	var speed_modulate: String
	
	if Unit.attack < Unit.base_card.a: attack_modulate = "DARK_RED"
	elif Unit.attack == Unit.base_card.a: attack_modulate = "BASE"
	else: attack_modulate = "BRIGHT_GREEN" 
	
	if Unit.health < Unit.max_health: health_modulate = "DARK_RED"
	elif Unit.health == Unit.max_health: health_modulate = "BASE"
	else: health_modulate = "BRIGHT_GREEN"
	
	if Unit.speed == 0: speed_modulate = "MEDIUM_GRAY"
	elif Unit.speed <= Unit.max_speed: speed_modulate = "BASE"
	else: speed_modulate = "BRIGHT_GREEN"
		
	if !stat_changed.is_empty():
		on_set_unit_field_status_stats(attack_modulate, health_modulate, speed_modulate)
		var ScaleTween := create_tween()
		var StatLabel: Label = Stats.get_node(stat_changed + "/Label")
		ScaleTween.tween_property(StatLabel, "scale:y", 0, NUMBER_SCALE_TIME)
		ScaleTween.finished.connect(on_reset_stat_numbers.bind(attack_modulate, health_modulate, speed_modulate, stat_changed))
	
	if UnitStatusExtra != null: UnitStatusExtra.on_reset_stats(stat_changed)
	
func onSetStatLabelText(StatLabel: Label, stat: int) -> void:
	StatLabel.text = str(stat)
	StatLabel.label_settings = preload("res://assets/UI/sixty_four/sixty_four_default.tres")\
	if StatLabel.text.length() == 1 else preload("res://assets/UI/sixty_four/sixty_four_medium.tres")
 	
func on_reset_stat_numbers(attack_modulate: String, health_modulate: String, speed_modulate: String, stat_changed: String) -> void:
	onSetStatLabelText(AttackLabel, Unit.attack)
	onSetStatLabelText(HealthLabel, Unit.health)
	onSetStatLabelText(SpeedLabel, Unit.speed)
	
	AttackLabel.modulate = Unit.Units.get(attack_modulate)
	HealthLabel.modulate = Unit.Units.get(health_modulate)
	SpeedLabel.modulate = Unit.Units.get(speed_modulate)
	
	for stat in ["Attack", "Health", "Speed"]:
		var val: int = Unit["max_" + stat.to_lower()] - Unit.base_card[stat[0].to_lower()]
		get_node("HoverCard/Buffs/HBoxContainer/" + stat + "/Label").text = ("+" if val >= 0 else "") + str(val)
	
	var StatLabel: Label = Stats.get_node(stat_changed + "/Label")
	var ScaleTween := create_tween()
	ScaleTween.tween_property(StatLabel, "scale:y", 1, NUMBER_SCALE_TIME)
	
func on_reset_status_effects() -> void:
	pass

func on_reset_tool() -> void:
	pass

const HOVER_TIME_DELAY: float = 0.4
var is_hover: bool = false
func _on_art_max_mouse_entered(): on_initiate_hover_card(); is_hover = true
func _on_art_max_mouse_exited(): on_remove_hover_card(); is_hover = false

var HoverCard: Control
func on_initiate_hover_card() -> void:
	await get_tree().create_timer(HOVER_TIME_DELAY).timeout
	if is_hover and HoverCard == null:
		var CardUI: Control = preload("res://assets/base_game/cards/game_card/game_card.tscn").instantiate()
		CardUI.Heroes = Heroes
		CardUI.set_info(Unit.base_card)
		HoverCard = CardUI
		oHoverCard.add_child(CardUI)
		oHoverCard.visible = true
		oHoverCard.position = get_global_mouse_position() + HOVER_CARD_OFFSET
	
func on_remove_hover_card() -> void:
	if HoverCard != null:
		oHoverCard.visible = false
		HoverCard.queue_free()
		HoverCard = null

var ROTATION_DEATH_SPEED: float = 300
@export var HOVER_CARD_OFFSET := Vector2(80, -200)
func _process(delta: float) -> void:
	if visible and HoverCard != null:
		oHoverCard.position = get_global_mouse_position() + HOVER_CARD_OFFSET

	if Rainbow.visible: Rainbow.rotation_degrees += RAINBOW_SPEED * delta
	if on_rotate_queue_free:
		rotation_degrees += delta * ROTATION_DEATH_SPEED

func _on_mouse_entered():
	if !Unit.Units.LevelMap.lock_inputs and !Unit.Units.LevelUI.is_status_box_moving:
		Unit.Units.Tiles.on_set_tile_material(Unit.Tile, "UnitInspected")

func _on_mouse_exited():
	if !Unit.Units.LevelMap.lock_inputs and !Unit.Units.LevelUI.is_status_box_moving:
		Unit.Units.Tiles.on_remove_tile_material(Unit.Tile)

signal queue_free_signal
const DEATH_AFTER_MULTIPLIER: float = 2.0
var on_rotate_queue_free: bool = false
func onBeginUnitStatusDeath(DEATH_AFTER_DELAY: float) -> void:
	var ScaleTween: Tween = create_tween()
	ScaleTween.tween_property(self, "scale", Vector2.ZERO, DEATH_AFTER_DELAY * DEATH_AFTER_MULTIPLIER)
	on_rotate_queue_free = true
	
	if UnitStatusExtra != null: UnitStatusExtra.onBeginUnitStatusDeath(DEATH_AFTER_DELAY)
	
func _queue_free() -> void:
	queue_free()
	queue_free_signal.emit(self)
	
	if UnitStatusExtra != null: UnitStatusExtra._queue_free()

const speeds: Dictionary = {
	"TurnUsed": 0.02,
	"TurnUnused": 0.12,
	"TurnActive": 0.2,}
	
const modulates: Dictionary = {
	"TurnUsed": Color("8fbf8f"),
	"TurnUnused": Color("43bf43"),
	"TurnActive": Color("00bf00"),
}

var modulate_state: String
func on_set_status_box_modulate(val: String) -> void:
	if Unit.team == 0:
		ShiftingBackground.material.set_shader_parameter("speed", speeds[val])
		ShiftingBackground.material.set_shader_parameter("modulate", modulates[val])
			
		modulate_state = val
		Gem.visible = val == "TurnActive"
		SelectedMask.material = null if val != "TurnActive" else card_selected_material
		
const RAINBOW_SPEED: int = 300
@onready var Rainbow = %RainbowLight
func on_unit_spectated(state: bool) -> void:
	Rainbow.visible = state
	on_set_light_mask(0 if !state else 32)
	if UnitStatusExtra != null: UnitStatusExtra.on_unit_spectated(state)

func on_set_unit_field_status_stats(attack_modulate, health_modulate, speed_modulate) -> void:
	Unit.UnitFieldStatus.on_set_stats(Unit.attack, Unit.health, Unit.speed, attack_modulate, health_modulate, speed_modulate)

func on_set_light_mask(state: int) -> void:
	for node in [In, ArtPop, AttackSprite, HealthSprite, SpeedSprite, SelectedMask]:
		node.light_mask = state
