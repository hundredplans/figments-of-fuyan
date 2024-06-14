extends Control

const HOVER_TIME_DELAY: float = 0.4
@export var HOVER_CARD_OFFSET := Vector2(50, -150)

@onready var Buffs: Control = $BuffManager
@export var ArtPop: TextureButton

var Unit: UnitGD
var HoverCard: Control
var is_hover: bool = false

func _ready():
	ArtPop.mouse_entered.connect(on_initiate_hover_card)
	ArtPop.mouse_exited.connect(on_remove_hover_card)
	Buffs.visible = false

func on_initiate_hover_card() -> void:
	is_hover = true
	await get_tree().create_timer(HOVER_TIME_DELAY).timeout
	if is_hover and HoverCard == null:
		var GameCard: GameCardGD = preload("res://assets/base_game/cards/game_card/game_card.tscn").instantiate()
		GameCard.set_info(Unit.base_card)
		HoverCard = GameCard
		add_child(GameCard)
		global_position = get_global_mouse_position() + HOVER_CARD_OFFSET
		Buffs.visible = true
	
func on_remove_hover_card() -> void:
	is_hover = false
	if HoverCard != null:
		HoverCard.queue_free()
		HoverCard = null
		Buffs.visible = false

func _process(_delta: float) -> void:
	if HoverCard != null:
		global_position = get_global_mouse_position() + HOVER_CARD_OFFSET
		global_position.y = min(global_position.y, 600)

func onUpdateStat(_stat: int, stat_changed: String) -> void:
	Buffs.onUpdateStat(stat_changed)
