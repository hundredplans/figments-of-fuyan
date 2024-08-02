class_name MovementPathGD
extends Resource

var OriginTile: TileGD
var DestinationTile: TileGD
var fneighbours: Array # Array of fneighbour, fall dmg
var fall_damages: Dictionary # Dictionary that associates each tile to a specific fall dmg
var vis_array: Array = []

func _init(_Tile: TileGD) -> void:
	OriginTile = _Tile

static func onFindTile(Tile: TileGD, movement_paths: Array) -> MovementPathGD:
	for movement_path in movement_paths: if movement_path.DestinationTile == Tile: return movement_path
	return null

static func onFindEnterVisionIndex(movement_path: MovementPathGD) -> int:
	for i in range(movement_path.vis_array.size()):
		if movement_path.vis_array[i].total_vision == VisInfoGD.ENTER:
			return i
	return -1

static func onFneighboursTiles(_fneighbours: Array):
	return _fneighbours.map(func(x: FneighbourGD): return x.Tile)

func isVisArrayInvis() -> bool:
	return vis_array.all(func(x: VisInfoGD): return x.isNull() or x.total_vision == VisInfoGD.INVISIBLE)
	
static func onFindAttackPath(movement_paths: Array) -> Array:
	return movement_paths.filter(func(x: MovementPathGD): return x.isAttack())

static func onFindEnemyInAttackPaths(attack_paths: Array) -> Array:
	return attack_paths.map(func(x: MovementPathGD): return x.DestinationTile.Unit)

func onVisInfoByFneighbour(fneighbour: FneighbourGD) -> VisInfoGD:
	for i in range(fneighbours.size()):
		if fneighbour == fneighbours[i]:
			return vis_array[i]
	return VisInfoGD.new()

func onReentersVision(vis_info: VisInfoGD) -> bool:
	var begin_count: bool = false
	for key in vis_array:
		if key == vis_info: begin_count = true
		elif begin_count and key.total_vision != VisInfoGD.INVISIBLE: return true
	return false

func getTiles() -> Array:
	return fneighbours.map(func(x: FneighbourGD): return x.Tile)

func isAttack() -> bool: return fneighbours.any(func(x: FneighbourGD): return x.AttackTarget != null)
func isAttackTargetUnit() -> bool: return fneighbours.any(func(x: FneighbourGD): return x.AttackTarget != null and x.AttackTarget is UnitGD)

