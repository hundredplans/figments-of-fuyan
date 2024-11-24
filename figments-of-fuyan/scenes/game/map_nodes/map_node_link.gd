extends Node3D

@export var default_ball: PackedScene
@export var big_ball: PackedScene

@export var default_balls_meshes: Array[Mesh]
@export var big_ball_meshes: Array[Mesh]
@export var massive_ball_meshes: Array[Mesh]

@export var BALL_Y: float = 1
var vector: Vector3

var map_link: MapLink
var is_selected: bool

const PROGRESS_VALUES: Array = [0.2, 0.375, 0.5, 0.625, 0.8]


func setInfo(_vector: Vector3, _map_link: MapLink) -> void:
	vector = _vector
	map_link = _map_link
	
	position.y = BALL_Y
	onCreateBalls()

var BigBall: MapNodeBall
func onCreateBalls() -> void:
	var progress: float = 0
	for i in range(PROGRESS_VALUES.size()):
		progress = PROGRESS_VALUES[i]
		
		var mesh_node: Node3D
		if i != 2:
			mesh_node = default_ball.instantiate()
			if is_grey: mesh_node.mesh = default_ball_mesh_grey
			elif is_holy: mesh_node.mesh = default_ball_mesh_holy
			else: mesh_node.mesh = default_ball_mesh
			
			add_child(mesh_node)
			mesh_node.position = Vector3(vector.x * progress, 0, vector.z * progress)
			continue
			
		mesh_node = big_ball.instantiate()
		if is_grey: mesh_node.mesh = big_ball_mesh_grey
		elif is_holy: mesh_node.mesh = big_ball_mesh_holy
		else: mesh_node.mesh = big_ball_mesh
		BigBall = mesh_node
		
		add_child(mesh_node)
		mesh_node.position = Vector3(vector.x * progress, 0, vector.z * progress)
		mesh_node.setInfo(BigBall.BALL_TYPE.BIG)
		mesh_node.onTweenChain()

func onMapNodeSelected() -> void:
	is_selected = true
	onUpdate()
	BigBall.setInfo(BigBall.BALL_TYPE.MASSIVE)
	if is_grey: BigBall.mesh = massive_ball_mesh_grey
	elif is_holy: BigBall.mesh = massive_ball_mesh_holy
	else: BigBall.mesh = massive_ball_mesh

func onMapNodeDeselected() -> void:
	is_selected = false
	onUpdate()
	BigBall.setInfo(BigBall.BALL_TYPE.BIG)
	if is_grey: BigBall.mesh = massive_ball_mesh_grey
	elif is_holy: BigBall.mesh = massive_ball_mesh_holy
	else: BigBall.mesh = massive_ball_mesh
	
func onUpdate() -> void:
	BigBall.setInfo(BigBall.BALL_TYPE.BIG if !is_selected else BigBall.BALL_TYPE.MASSIVE)
	BigBall.mesh = onFindBallMesh()
	
func onFindBallMesh() -> void:
	var index: int = 0
	var arr: Array = default_balls_meshes
	if is_selected: massive_ball_meshes
