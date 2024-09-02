extends Node3D

@export var ball_holy_path_material: Material
@export var ball_default_material: Material
@export var BALL_COUNT: int = 5
@export var BALL_Y: float = 1
var vector: Vector3

func setInfo(_vector: Vector3) -> void:
	vector = _vector
	position.y = BALL_Y
	onCreateLink(map_node_big_ball)

func onCreateLink(big_ball_mesh: Mesh) -> void:
	for ball in get_children(): ball.queue_free()
	var progress: float = 0
	for i in range(BALL_COUNT):
		progress += 1.0 / float((BALL_COUNT + 1))
		
		var mesh_node := MeshInstance3D.new()
		add_child(mesh_node)
		
		var mesh: Mesh
		if i == 2: mesh = big_ball_mesh
		else: mesh = ball; mesh_node.script = 
		
		mesh_node.mesh = mesh
		
		
		mesh.position = Vector3(vector.x * progress, 0, vector.z * progress)

func onMapNodeSelected() -> void:
	onCreateLink(map_node_massive_ball)
