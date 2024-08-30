extends Node3D

signal champion_hovered
signal champion_unhovered
signal champion_pressed
const UNIT_SCALE: float = 0.15

func setInfo(Card: CardGD) -> void:
	Card.position = Vector3.ZERO
	Card.setRayPickable(true)
	Card.setScaleUniform(UNIT_SCALE)
	Card.onIdle()
	
	Card.mouse_entered.connect(onUnitMouseEntered)
	Card.mouse_exited.connect(onUnitMouseExited)
	
var ChampionHovered: CardGD
func onUnitMouseEntered(Card: CardGD) -> void:
	champion_hovered.emit(Card)
	ChampionHovered = Card

func onUnitMouseExited(Card: CardGD) -> void:
	champion_unhovered.emit(Card)
	ChampionHovered = null
	
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("MainInput") and ChampionHovered != null:
		champion_pressed.emit(ChampionHovered)
	
