extends Control

var Heroes: HeroesGD
const DARK_RED: Color = Color("ff0000")
const BRIGHT_GREEN: Color = Color("00ff00")
const MEDIUM_GRAY: Color = Color("8c8c8c")

var Unit: UnitGD

func _ready() -> void:
	$HoverCard.visible = false

func on_set_unit(_Unit: UnitGD) -> void:
	Unit = _Unit
	visible = !(bool(Unit.team))
	if Unit.team == 1:
		$Background/Outside["theme_override_styles/panel"] = preload("res://scenes/screens/level_ui/unit_status/unit_status_outside_box_flat1.tres")
	on_reset_stats()
	on_reset_status_effects()
	on_reset_tool()
	
	var hero_bgfn: String = Unit.base_card.bgfn if Unit.rarity != 7 else Helper.id_to_dict(Heroes.id_to_base(Unit.id), "Card").bgfn
	var texture_path: String = "res://assets/base_game/cards/card_ui/default_art_max.png"
	var card_texture_path: String = "res://assets/base_game/cards/" + hero_bgfn + "/art_max.png"
	if FileAccess.file_exists(card_texture_path):
		texture_path = card_texture_path
	$ArtMax.texture_normal = load(texture_path)

@onready var AttackLabel: Label = $Stats/Attack/Label
@onready var HealthLabel: Label = $Stats/Health/Label
@onready var SpeedLabel: Label = $Stats/Speed/Label

func on_reset_stats() -> void:
	AttackLabel.text = str(Unit.attack)
	HealthLabel.text = str(Unit.health)
	SpeedLabel.text = str(Unit.speed)
	
	if Unit.attack < Unit.base_card.a: AttackLabel.modulate = DARK_RED
	elif Unit.attack == Unit.base_card.a: AttackLabel.modulate = Helper.BASE
	else: AttackLabel.modulate = BRIGHT_GREEN 
	
	if Unit.health < Unit.max_health: HealthLabel.modulate = DARK_RED
	elif Unit.health == Unit.max_health: HealthLabel.modulate = Helper.BASE
	else: HealthLabel.modulate = BRIGHT_GREEN
	
	if Unit.speed == 0: SpeedLabel.modulate = MEDIUM_GRAY
	elif Unit.speed <= Unit.max_speed: SpeedLabel.modulate = Helper.BASE
	else: SpeedLabel.modulate = BRIGHT_GREEN
	
	var unit_base_attack_offset: int = Unit.max_attack - Unit.base_card.a
	var unit_base_health_offset: int = Unit.max_health - Unit.base_card.h
	var unit_base_speed_offset: int = Unit.max_speed - Unit.base_card.s
	
	for stat in ["Attack", "Health", "Speed"]:
		var val: int = Unit["max_" + stat.to_lower()] - Unit.base_card[stat[0].to_lower()]
		get_node("HoverCard/Buffs/HBoxContainer/" + stat + "/Label").text = ("+" if val >= 0 else "") + str(val)
	
func on_reset_status_effects() -> void:
	pass

func on_reset_tool() -> void:
	pass

func _on_art_max_pressed():
	var units: Array = Unit.Units.on_units()
	for i in range(units.size()):
		if units[i] == Unit:
			Unit.Units.SpectateCamera.on_spectate("Unit", i)
			break

const HOVER_TIME_DELAY: float = 0.4
var is_hover: bool = false
func _on_art_max_mouse_entered(): on_initiate_hover_card(); is_hover = true
func _on_art_max_mouse_exited(): on_remove_hover_card(); is_hover = false

var HoverCard: Control
func on_initiate_hover_card() -> void:
	await get_tree().create_timer(HOVER_TIME_DELAY).timeout
	if is_hover and HoverCard == null:
		$HoverCard.visible = true
		var CardUI: Control = preload("res://assets/base_game/cards/card_ui/card_ui.tscn").instantiate()
		CardUI.Heroes = Heroes
		CardUI.set_info(Unit.base_card)
		HoverCard = CardUI
		$HoverCard.add_child(CardUI)
	
func on_remove_hover_card() -> void:
	if HoverCard != null:
		$HoverCard.visible = false
		HoverCard.queue_free()
		HoverCard = null

const HOVER_CARD_OFFSET := Vector2(-110, 70)
func _process(_delta: float) -> void:
	if visible and HoverCard != null:
		$HoverCard.position = get_global_mouse_position() + HOVER_CARD_OFFSET
