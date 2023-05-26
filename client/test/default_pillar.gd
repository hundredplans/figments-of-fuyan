extends Node3D
var listen: bool = false
var tile := Vector2.ZERO
signal pillar_inputA
signal pillar_inputB

func _ready():
	$MouseCollision.connect("mouse_entered", func(): listen = true)
	$MouseCollision.connect("mouse_exited", func(): listen = false)
	
func on_pillar_instanced(sent_tile:Vector2) -> void:
	set_name("%s-%s" % [sent_tile.x, sent_tile.y])
	tile = sent_tile
	set_position(Vector3(tile.x * 2, 0, tile.y * 2))
	
func _process(_delta):
	if listen and Input.is_action_just_pressed("InputA"):
		pillar_inputA.emit(tile)
		
	elif listen and Input.is_action_just_pressed("InputB"):
		pillar_inputB.emit(tile)
