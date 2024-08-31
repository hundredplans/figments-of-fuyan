extends Node3D

@export var map_node_ball: PackedScene
@export var BALL_COUNT: int = 5
@export var BALL_Y: float = 1

func setInfo(other_location: MapLocation, map_location: MapLocation, map_location_to_node: Dictionary) -> void:
	var vector: Vector3 = map_location_to_node[other_location].getPosition() - map_location_to_node[map_location].getPosition()
	var progress: float = 0
	for i in range(BALL_COUNT):
		progress += 1.0 / float((BALL_COUNT + 1))
		var ball: Node3D = map_node_ball.instantiate()
		add_child(ball)
		ball.position = Vector3(vector.x * progress, BALL_Y, vector	.z * progress)
