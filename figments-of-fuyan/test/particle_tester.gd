extends Node3D

func _ready() -> void:
	
	var mesh_one = preload("res://assets/models/general/numbers/particle_numbers/eight.tres")
	var mesh_two = preload("res://assets/models/general/numbers/particle_numbers/plus.tres")
	await get_tree().create_timer(2).timeout
	$NumbersParticle.draw_pass_1 = mesh_two
	$NumbersParticle.draw_pass_2 = mesh_one
	$NumbersParticle.emitting = true
