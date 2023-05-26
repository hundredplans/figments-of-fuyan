extends Node3D

func instance_model(cid: int, tile: Vector2, uid: int) -> void:

	var field_card: Node3D = load("res://assets/cards/%s/field_model.blend" % cid).instantiate()
	field_card.set_script(preload("res://test/cards/field_model.gd"))
	field_card.tile = tile
	field_card.uid = uid
	add_child(field_card)
	field_card.set_position(Vector3(tile.x * 2, 4, tile.y * 2))
	
	var _aniplayer: AnimationPlayer = field_card.get_node("AnimationPlayer")
	_aniplayer.animation_finished.connect(on_animation_finished.bind(field_card))
	_aniplayer.set_default_blend_time(0.3)
	
	play_anim(5, field_card)

func play_anim(animation_id: int, field_card: Node3D) -> void:
	
	print(animation_id)
	var match_animation_name: Dictionary = {
		1: "Idle",
		2: "Walk",
		3: "Attack",
		4: "Death",
		5: "Place",
		6: "Ability",
		7: "Attack_Horizontal"
	}
	
	field_card.get_node("AnimationPlayer").play(match_animation_name[animation_id])

func on_animation_finished(_animation_name: String, field_card: Node3D):
	play_anim(1, field_card)

func move_unit(unit: Node3D, tile: Vector2):
	if tile.x < 6 and tile.x > 0 and tile.y < 10 and tile.y > 0:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(unit, "global_position", Vector3(tile.x * 2, 4, tile.y * 2), 0.5)
		play_anim(2, unit)
		unit.tile = tile
