extends Node3D

@export_group("Ball Scenes")
@export var default_ball: PackedScene
@export var big_ball: PackedScene

@export_group("Default Ball")
@export var default_ball_mesh: Mesh
@export var default_ball_mesh_holy: Mesh
@export_group("Big Ball")
@export var big_ball_mesh: Mesh
@export var big_ball_mesh_holy: Mesh
@export_group("Massive Ball")
@export var massive_ball_mesh: Mesh
@export var massive_ball_mesh_holy: Mesh
@export_group("")

@export var BALL_COUNT: int = 5
@export var BALL_Y: float = 1
var vector: Vector3
var is_holy: bool
var is_selected: bool

func setInfo(_vector: Vector3, _is_holy: bool) -> void:
	vector = _vector
	position.y = BALL_Y
	is_holy = _is_holy
	onCreateBalls()

var BigBall: MapNodeBall
func onCreateBalls() -> void:
	var progress: float = 0
	for i in range(BALL_COUNT):
		progress += 1.0 / float((BALL_COUNT + 1))
		
		var mesh_node: Node3D
		if i == floor(BALL_COUNT / 2.0):
			mesh_node = big_ball.instantiate()
			mesh_node.setInfo(BigBall.BALL_TYPE.BIG)
			
			if !is_holy: mesh_node.mesh = big_ball_mesh
			else: mesh_node.mesh = big_ball_mesh_holy
			BigBall = mesh_node
		else:
			mesh_node = default_ball.instantiate()
			if !is_holy: mesh_node.mesh = default_ball_mesh
			else: mesh_node.mesh = default_ball_mesh_holy
		
		add_child(mesh_node)
		mesh_node.position = Vector3(vector.x * progress, 0, vector.z * progress)

func onMapNodeSelected() -> void:
	is_selected = true
	BigBall.setInfo(BigBall.BALL_TYPE.MASSIVE)
	if !is_holy: BigBall.mesh = massive_ball_mesh
	else: BigBall.mesh = massive_ball_mesh_holy

func onMapNodeDeselected() -> void:
	is_selected = false
	BigBall.setInfo(BigBall.BALL_TYPE.BIG)
	if !is_holy: BigBall.mesh = big_ball_mesh
	else: BigBall.mesh = big_ball_mesh_holy
