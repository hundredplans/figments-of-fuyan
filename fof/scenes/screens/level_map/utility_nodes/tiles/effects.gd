extends Node3D

@onready var Tile: TileGD = get_parent()
var HeightDropLabel: Node3D = null
var hovered_type: Variant = Vector2.ZERO

func on_manage_height_drop_label(UnitSelected: UnitGD) -> void:
	if HeightDropLabel == null or HeightDropLabel.is_queued_for_deletion():
		if hovered_type.x == 4 and hovered_type.z != 0:
			for state in Tile.tile_state:
				if state == "PathHovered":
					HeightDropLabel = preload("res://scenes/screens/level_map/height_drop_label.tscn").instantiate()
					add_child(HeightDropLabel)
					HeightDropLabel.look_at(\
					Vector3(UnitSelected.global_position.x, UnitSelected.global_position.y + UnitSelected.height.eye, UnitSelected.global_position.z))
					
					HeightDropLabel.get_node("DMGSprite").texture = \
					preload("res://assets/base_game/cards/game_card/art/bbcode/HEALTH.png")\
					if UnitSelected.health - hovered_type.z > 0 else\
					preload("res://scenes/screens/level_map/red_skull.png")
					
					HeightDropLabel.get_node("Label3D").text = str(hovered_type.z)
					return
	else: HeightDropLabel.queue_free()
