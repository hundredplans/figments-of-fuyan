extends Node
@export var GameCard: GameCardGD

var old_position: Vector2
var offset: Vector2
var initial_pos: Vector2
var is_held: bool = false

func _ready() -> void:
	if GameCard != null: setInfo(GameCard)

func setInfo(_GameCard: GameCardGD) -> void:
	GameCard = _GameCard
	GameCard.CardButton.button_down.connect(onGameCardButtonDown)
	GameCard.CardButton.button_up.connect(onGameCardButtonUp)

func onGameCardButtonDown() -> void:
	initial_pos = GameCard.position
	is_held = true
	offset = get_viewport().get_mouse_position() - GameCard.global_position
	old_position = get_viewport().get_mouse_position() - offset
	
func onGameCardButtonUp() -> void:
	is_held = false
	GameCard.position = initial_pos
	
const NATURAL_SCALE_DEBUFF := Vector2.ONE
var extra_scale: float
func _process(delta: float) -> void:
	if GameCard.scale < Vector2.ONE:
		GameCard.scale += (NATURAL_SCALE_DEBUFF * delta * (1 / GameCard.scale.x))
	
	if is_held:
		GameCard.global_position = get_viewport().get_mouse_position() - offset
		var speed: float = abs((old_position.x - GameCard.global_position.x) * 0.001)
		GameCard.scale -= Vector2(speed, speed)
		if GameCard.scale < Vector2(0.01, 0.01): GameCard.scale = Vector2(0.01, 0.01)
		old_position = GameCard.global_position
