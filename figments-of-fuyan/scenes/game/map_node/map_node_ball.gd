class_name MapNodeBall extends MeshInstance3D

enum BALL_TYPE {DEFAULT, BIG, MASSIVE}
var ball_type: BALL_TYPE = BALL_TYPE.DEFAULT

@export_group("Big Ball")
@export var BIG_BALL_SPEED: float = 0.2
@export var BIG_BALL_MAX_DISTANCE: float = 0.1

@export_group("Massive Ball")
@export var MASSIVE_BALL_SPEED: float = 0.4
@export var MASSIVE_BALL_MAX_DISTANCE: float = 0.1
@export_group("")

@export_group("Meshes")
@export var ball: Mesh
@export var big_ball: Mesh
@export var massive_ball: Mesh
@export_group("")

var direction: int = 1

func setInfo(_ball_type: int) -> void:
	ball_type = _ball_type
	match ball_type:
		BALL_TYPE.DEFAULT: mesh = ball
		BALL_TYPE.BIG: mesh = big_ball
		BALL_TYPE.MASSIVE: mesh = massive_ball

func _process(delta: float) -> void:
	if ball_type != BALL_TYPE.DEFAULT:
		var speed: float = BIG_BALL_SPEED if ball_type == BALL_TYPE.BIG else MASSIVE_BALL_SPEED
		var max_distance: float = BIG_BALL_MAX_DISTANCE  if ball_type == BALL_TYPE.MASSIVE else MASSIVE_BALL_MAX_DISTANCE
		position.y += delta * speed * direction
		if abs(position.y) > max_distance: direction *= -1
