extends Node3D

signal champion_hovered
signal champion_unhovered
signal champion_pressed
const UNIT_SCALE: float = 0.15

func setInfo(Unit: UnitGD) -> void:
	Unit.position = Vector3.ZERO
	Unit.setRayPickable(true)
	Unit.setScaleUniform(UNIT_SCALE)
	Unit.onIdle()
	
	Unit.mouse_entered.connect(onUnitMouseEntered)
	Unit.mouse_exited.connect(onUnitMouseExited)
	
var ChampionHovered: UnitGD
func onUnitMouseEntered(Unit: UnitGD) -> void:
	champion_hovered.emit(Unit)
	ChampionHovered = Unit

func onUnitMouseExited(Unit: UnitGD) -> void:
	champion_unhovered.emit(Unit)
	ChampionHovered = null
	
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("MainInput") and ChampionHovered != null:
		champion_pressed.emit(ChampionHovered)
	
