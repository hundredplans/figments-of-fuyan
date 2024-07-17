class_name ObjectManagerGD
extends Node

var Tiles: TilesGD
var PlayerManager: PlayerManagerGD

const OBJECT_INTERACT_TILES: String = "res://scenes/screens/level_map/utility_nodes/object_manager/object_interact_tiles/"
var interactable_obj_resources: Array
var interactables: Array = []

func _ready() -> void:
	interactable_obj_resources = Array(DirAccess.get_files_at(OBJECT_INTERACT_TILES))\
	.filter(func(x: String): return x.ends_with("tres")).map(func(y: String):\
	return load(OBJECT_INTERACT_TILES + y))

func onAddInteractableObj(Tile: TileGD) -> void:
	for object_interactables in interactable_obj_resources:
		if object_interactables.id == Tile.obj.id:
			var tiles: Array = object_interactables.tiles.map(func(x: Vector4): return Tiles.position_to_tile(x + Tile.onTTpos()))
			var iobject: IObjectGD = object_interactables.iobject_script.new()
			interactables.append(iobject)
			iobject.setInfo(Tile, tiles, object_interactables)
			return
	
func onFindOccupiedIObjects(Unit: UnitGD) -> Array:
	return interactables.filter(func(x: IObjectGD): return x.onCondition(Unit))

func onFindIObject(Tile: TileGD) -> IObjectGD:
	for iobj in interactables:
		if iobj.BaseTile == Tile: return iobj
	return null

func onHighlightObj(state: bool, Tile: TileGD) -> void:
	var Unit: UnitGD = PlayerManager.getUnitSelected()
	if Unit != null:
		if state:
			var iobj: IObjectGD = onFindIObject(Tile)
			if iobj != null and Unit.Tile not in iobj.interactable_tiles:
				var tiles: Array = iobj.interactable_tiles.filter(func(x: TileGD): return x.Unit == null)
				tiles.sort_custom(func(x: TileGD, y: TileGD): return Tiles.tile_distance(x, Unit.Tile) < Tiles.tile_distance(y, Unit.Tile))
				if tiles.size() > 0:
					Tiles.onCreatePathHovered(tiles[0])
		else:
			Tiles.onRemovePathHovered()

func onTrigger(Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	for iobj in interactables.filter(func(x: IObjectGD): return x.has_method("onTrigger")):
		iobj.onTrigger(Unit, trigger, args)
