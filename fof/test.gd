extends Node3D

const SCALE_UP_TIME: float = 0.75
const FINAL_SCALE_COCUS := Vector3(2, 2, 2)
@onready var CocusPocus: Node3D = %CocusPocus
func _ready():
	await get_tree().create_timer(3).timeout
	var ScaleTween := create_tween()
	ScaleTween.tween_property(CocusPocus, "scale", FINAL_SCALE_COCUS, SCALE_UP_TIME).set_trans(Tween.TRANS_ELASTIC)
	
	var PosTween := create_tween()
	PosTween.tween_property(CocusPocus, "position:y", 0, SCALE_UP_TIME).set_trans(Tween.TRANS_ELASTIC)

	var ScaleTwoTween := create_tween()
	ScaleTwoTween.tween_property($Model, "scale:y", 0.001, SCALE_UP_TIME).set_trans(Tween.TRANS_ELASTIC)
