extends Node3D

@onready var Tile: TileGD = get_parent()
var HeightDropLabel: Node3D = null
var fall_damage: int = 0

func onManageHeightDropLabel(Unit: UnitGD) -> void:
	if Unit != null:
		if (HeightDropLabel == null or HeightDropLabel.is_queued_for_deletion()):
			if fall_damage > 0 and "PathHovered" in Tile.tile_outlines:
				HeightDropLabel = preload("res://scenes/screens/level_map/height_drop_label.tscn").instantiate()
				add_child(HeightDropLabel)
				HeightDropLabel.position.y += (0.6 if Tile.Tiles.is_ramp_tile(Tile) else 0.0)
				HeightDropLabel.look_at(\
				Vector3(Unit.global_position.x, Unit.global_position.y + Unit.height.eye, Unit.global_position.z))
				
				HeightDropLabel.get_node("DMGSprite").texture = \
				preload("res://assets/base_game/cards/game_card/art/bbcode/HEALTH.png")\
				if Unit.health - fall_damage > 0 else\
				preload("res://scenes/screens/level_map/red_skull.png")
				
				HeightDropLabel.get_node("Label3D").text = str(fall_damage)
		else: HeightDropLabel.queue_free()
		
var PastPath: Node3D
func onPastPath(rots: Array, nums: Array) -> void:
	if Tile.tile.type in [0, 1]:
		PastPath = preload("res://scenes/screens/level_map/utility_nodes/tiles/past_path.tscn").instantiate()
		add_child(PastPath)
		PastPath.Tile = Tile
		PastPath.onCreatePastPath(rots, nums)
	else:
		PastPath = preload("res://scenes/screens/level_map/utility_nodes/tiles/past_path_ramp.tscn").instantiate()
		add_child(PastPath)
		PastPath.Tile = Tile
		PastPath.onCreatePastPath(rots, nums)
	
func onRemovePastPath() -> void:
	if PastPath != null:
		PastPath.queue_free()

func onSetHeightDropInfo(movement_path: MovementPathGD, fneighbour: FneighbourGD) -> void:
	fall_damage = 0
	if movement_path.fall_damages.has(fneighbour.Tile):
		fall_damage = movement_path.fall_damages[fneighbour.Tile]
