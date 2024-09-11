class_name MapNodeBall extends MeshInstance3D

enum BALL_TYPE {BIG, MASSIVE}
var ball_type: BALL_TYPE = BALL_TYPE.BIG

@export_group("Big Ball")
@export var BIG_BALL_SPEED: float = 1
@export var BIG_BALL_MAX_DISTANCE: float = 0.2

@export_group("Massive Ball")
@export var MASSIVE_BALL_SPEED: float = 0.6
@export var MASSIVE_BALL_MAX_DISTANCE: float = 0.2
@export_group("")
var direction: int = -1

func _ready() -> void:
	onTweenChain()

func setInfo(_ball_type: BALL_TYPE) -> void:
	ball_type = _ball_type
	
func onTweenChain() -> void:
	direction *= -1
	var tween := get_tree().create_tween()
	var speed: float = BIG_BALL_SPEED if ball_type == BALL_TYPE.BIG else MASSIVE_BALL_SPEED
	var max_distance: float = BIG_BALL_MAX_DISTANCE if ball_type == BALL_TYPE.BIG else MASSIVE_BALL_MAX_DISTANCE
	tween.tween_property(self, "position:y", max_distance * direction, speed).as_relative().set_trans(Tween.TRANS_SINE)
	tween.finished.connect(onTweenChain)
