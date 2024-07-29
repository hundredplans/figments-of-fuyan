extends Node3D

@onready var Tile: TileGD = get_parent()
var DeathPathLabel: Node3D
var fall_damage: int = 0

func onRemoveDeathPathLabel() -> void:
	if DeathPathLabel != null: DeathPathLabel.queue_free()

func onManageDeathPathLabel(Unit: UnitGD, type: String, is_remove: bool) -> void:
	if Unit != null:
		if DeathPathLabel != null:
			if is_remove and type in ["PathHovered", "MovementRange"]:
				DeathPathLabel.queue_free()
			return
		elif "PathHovered" in Tile.tile_outlines:
			if fall_damage > 0:
				onTriggerDeathPathLabel(Unit, fall_damage, FALL)
			elif Tile.isDeepWater() and Tile.Tiles.onCanDrown(Unit):
				onTriggerDeathPathLabel(Unit, 0, DROWN)
		
enum {
	DROWN,
	FALL,
}
		
func onTriggerDeathPathLabel(Unit: UnitGD, damage: int, type: int) -> void:
	DeathPathLabel = preload("res://scenes/screens/level_map/death_path_label.tscn").instantiate()
	add_child(DeathPathLabel)
	DeathPathLabel.position.y += (0.6 if Tile.Tiles.is_ramp_tile(Tile) else 0.0)
	DeathPathLabel.look_at(\
	Vector3(Unit.global_position.x, Unit.global_position.y + Unit.height.eye, Unit.global_position.z))
	
	DeathPathLabel.get_node("DMGSprite").texture = \
	preload("res://assets/base_game/cards/game_card/art/bbcode/HEALTH.png")\
	if (Unit.health - damage > 0 and type == FALL) else\
	preload("res://scenes/screens/level_map/red_skull.png")
	
	if type == FALL: DeathPathLabel.get_node("Label3D").text = str(fall_damage)
	else: DeathPathLabel.get_node("Label3D").text = ""
		
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
	if movement_path.fall_damages.has(fneighbour.Tile) and !(movement_path.isAttack() and fneighbour.Tile == movement_path.DestinationTile):
		fall_damage = movement_path.fall_damages[fneighbour.Tile]
