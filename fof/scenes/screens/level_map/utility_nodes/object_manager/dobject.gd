class_name DObjectGD
extends Resource

var ObjectManager: ObjectManagerGD
var Tools: ToolsGD
var Tiles: TilesGD
var BaseTile: TileGD
var info: DObjectInfoGD
var Units: UnitsGD
var Combat: CombatGD
var ActionManager: ActionManagerGD
var Vision: VisionGD

var health: int = 0
var is_dead: bool = false

func _init() -> void:
	Helper.onCreateChildReferences(self)
	
func setInfo(_BaseTile: TileGD, _info: DObjectInfoGD) -> void:
	BaseTile = _BaseTile
	info = _info
	health = info.max_health
	onEnableAdjacentAttacks()
	
func onEnableAdjacentAttacks() -> void:
	for Tile in Tiles.getAdjacentTiles(BaseTile, 1, true).filter(func(x: TileGD): return x.solid_status == 0):
		for fneighbour in Tile.fneighbours:
			if fneighbour.Tile == BaseTile:
				fneighbour.movement_type = FneighbourGD.ATTACK_DOBJECT
				fneighbour.unit_height = 50
				fneighbour.is_solid = false

func _onAttacked(DMGInfo: DMGInfoGD) -> void:
	if health != -1:
		health -= DMGInfo.BaseDMG
		if health <= 0: is_dead = true
		
