class_name ObjectManagerGD
extends Node

var Tiles: TilesGD

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
	
func getInteractableObjects(Unit: UnitGD) -> Array:
	return interactables.filter(func(x: IObjectGD): return x.onCondition(Unit))
