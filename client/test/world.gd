extends Node3D
var uid: int = 1
var current_cycle: int = 1

func _ready():
	for pillar in $Pillars.get_children():
		pillar.pillar_inputA.connect(on_pillar_inputA)
		pillar.pillar_inputB.connect(on_pillar_inputB)
	
func on_pillar_inputA(tile: Vector2):
	
	for child in $Cards.get_children():
		if child.tile == tile:
			$Cards.move_unit(child, Vector2(tile.x, tile.y + 1))
			return
			
	place_unit(tile)
	
func on_pillar_inputB(tile: Vector2):
	play_animation_on_field_model(tile)
	
func place_unit(tile: Vector2):
	$Cards.instance_model(28, tile, uid)
	uid += 1

func play_animation_on_field_model(tile: Vector2):
	for child in $Cards.get_children():
		if child.tile == tile:
			$Cards.play_anim(current_cycle, child)
