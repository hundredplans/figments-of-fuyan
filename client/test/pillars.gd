extends Node3D

func _ready():
	for _i in range(1, 6):
		for _j in range(1, 10):
			var pillar: Node3D = preload("res://test/default_pillar.tscn").instantiate()
			add_child(pillar)
			pillar.on_pillar_instanced(Vector2(_i, _j))
