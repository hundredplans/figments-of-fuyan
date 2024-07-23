extends Node

@export var type: String
@export var collision_points: PackedVector3Array

@export var bodies: Array[Node3D]
@export var meshes: Array[Node3D]

func playAnimation(ani_name: String) -> void:
	$AnimationPlayer.play(ani_name)
