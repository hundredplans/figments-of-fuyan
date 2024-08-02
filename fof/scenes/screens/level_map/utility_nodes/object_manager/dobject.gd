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
var Boons: BoonsGD

var ObjModel: Node3D
var health: int = 0
var is_dead: bool = false

func _init() -> void:
	Helper.onCreateChildReferences(self)
	
func setInfo(_BaseTile: TileGD, _info: DObjectInfoGD) -> void:
	BaseTile = _BaseTile
	info = _info
	health = info.max_health
	ObjModel = BaseTile.types[1].model
	
	onEnableAdjacentAttacks()
	
var original_fneighbours: Array = []
func onEnableAdjacentAttacks() -> void:
	for Tile in Tiles.getAdjacentTiles(BaseTile, 1, true).filter(func(x: TileGD): return x.solid_status == 0):
		for fneighbour in Tile.fneighbours:
			if fneighbour.Tile == BaseTile:
				var old_fneighbour: FneighbourGD = fneighbour.duplicate()
				original_fneighbours.append({"Tile": BaseTile, "old_fneighbour": old_fneighbour, "fneighbour": fneighbour})
				
				fneighbour.movement_type = FneighbourGD.ATTACK_DOBJECT
				fneighbour.unit_height = 50
				fneighbour.is_solid = false

func onDestroyed() -> void:
	for info in original_fneighbours:
		var ofn = info.old_fneighbour
		info.old_fneighbour.AttackTarget = info.fneighbour.AttackTarget
		info.old_fneighbour.Tile = info.fneighbour.Tile
		
		info.Tile.fneighbours.erase(info.fneighbour)
		info.Tile.fneighbours.append(info.old_fneighbour)

func _onAttacked(DMGInfo: DMGInfoGD) -> void:
	if health != -1 and !is_dead:
		health -= DMGInfo.BaseDMG
		if health <= 0: is_dead = true

func onAttacked(_DMGInfo: DMGInfoGD) -> void: return
func onDeath() -> void:
	ObjModel.get_node("AnimationPlayer").play("Death")

func onAfterAttacked() -> void: return
func onAfterDeath() -> void: ObjectManager.onRemoveDObject(self)
