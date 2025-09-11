extends Node3D

@export var default_ball: PackedScene
@export var big_ball: PackedScene

@export var default_ball_meshes: Array[Mesh]
@export var big_ball_meshes: Array[Mesh]
@export var massive_ball_meshes: Array[Mesh]

@export var BALL_Y: float = 1

var vector: Vector3
var map_link: MapLink
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
			add_child(mesh_node)
			mesh_node.position = Vector3(vector.x * progress, 0, vector.z * progress)
			mesh_node.setInfo(map_link)
			mesh_node.onTweenChain()
			continue
			
		BigBall = big_ball.instantiate()
		add_child(BigBall)
		BigBall.setInfo(map_link)
		
		BigBall.position = Vector3(vector.x * progress, 0, vector.z * progress)
		BigBall.onTweenChain()
	onUpdate()

func onMapNodeSelected() -> void:
	map_link.is_selected = true
	onUpdate()

func onMapNodeDeselected() -> void:
	map_link.is_selected = false
	onUpdate()
	
func onUpdate() -> void:
	BigBall.onUpdate()
	BigBall.mesh = onFindBallMesh()
	
	for child in get_children():
		if child == BigBall: continue
		child.mesh = onFindBallMesh(true)
	
func onFindBallMesh(is_small: bool = false) -> Mesh:
	var index: int = 0
	if map_link.is_finished: index = 1
	elif map_link.is_holy: index = 2
	
	var arr: Array = default_ball_meshes
	if !is_small:
		arr = big_ball_meshes
		if map_link.is_selected: arr = massive_ball_meshes
	return arr[index]
