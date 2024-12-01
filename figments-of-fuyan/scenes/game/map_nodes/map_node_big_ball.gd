class_name MapNodeBall extends MeshInstance3D

enum BallType {BIG, MASSIVE}
var ball_type: BallType

@export_group("Big Ball")
@export var BIG_BALL_SPEED: float = 1
@export var BIG_BALL_MAX_DISTANCE: float = 0.2

@export_group("Massive Ball")
@export var MASSIVE_BALL_SPEED: float = 0.6
@export var MASSIVE_BALL_MAX_DISTANCE: float = 0.2
@export_group("")

var direction: int = -1
var ActiveTween: Tween
var map_link: MapLink
	
var ball_type_swap: bool
func setInfo(_map_link: MapLink) -> void:
	map_link = _map_link
	position.y = -getMaxDistance() * 0.5
	onUpdate()
	
func onUpdate() -> void:
	ball_type = BallType.BIG if !map_link.is_selected else BallType.MASSIVE
	if map_link.is_finished:
		if ActiveTween != null: ActiveTween.stop()
		position.y = 0
	
func onTweenChain() -> void:
	if map_link.is_finished: return
	direction *= -1
	ActiveTween = get_tree().create_tween()
	var speed: float = BIG_BALL_SPEED if ball_type == BallType.BIG else MASSIVE_BALL_SPEED
	var max_distance: float = getMaxDistance()
	
	ActiveTween.tween_property(self, "position:y", max_distance * direction, speed).as_relative().set_trans(Tween.TRANS_SINE)
	ActiveTween.finished.connect(onTweenChain)
	
func getMaxDistance() -> float:
	return BIG_BALL_MAX_DISTANCE if ball_type == BallType.BIG else MASSIVE_BALL_MAX_DISTANCE
