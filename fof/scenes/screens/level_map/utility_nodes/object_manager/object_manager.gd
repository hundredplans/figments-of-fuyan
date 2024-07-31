class_name ObjectManagerGD
extends Node

var Tiles: TilesGD
var PlayerManager: PlayerManagerGD

const OBJECT_INTERACT_TILES: String = "res://scenes/screens/level_map/utility_nodes/object_manager/object_interact_tiles/"
const DESTRUCTABLES_INFOS_PATH: String = "res://scenes/screens/level_map/utility_nodes/object_manager/dobjects_info/"
var interactable_obj_resources: Array
var interactables: Array = []

var all_destructables_info: Array = []
var destructables: Array = []

func _ready() -> void:
	interactable_obj_resources = Array(DirAccess.get_files_at(OBJECT_INTERACT_TILES))\
	.filter(func(x: String): return x.ends_with("tres")).map(func(y: String):\
	return load(OBJECT_INTERACT_TILES + y))
	
	all_destructables_info = Array(DirAccess.get_files_at(DESTRUCTABLES_INFOS_PATH))\
	.filter(func(x: String): return x.ends_with("tres")).map(func(y: String):\
	return load(DESTRUCTABLES_INFOS_PATH + y))

func onFindDestructableInfo(id: int) -> DObjectInfoGD:
	for info in all_destructables_info: if info.id == id: return info
	return null

func setDestructableObj(Tile: TileGD) -> void:
	var info: DObjectInfoGD = onFindDestructableInfo(Tile.obj.id)
	if info != null:
		var dobject: DObjectGD = info.dobject_script.new()
		destructables.append(dobject)
		dobject.setInfo(Tile, info)

func onAddInteractableObj(Tile: TileGD) -> void:
	for object_interactables in interactable_obj_resources:
		if object_interactables.id == Tile.obj.id:
			var tiles: Array = object_interactables.tiles
			for i in range(Tile.obj.rotation):
				tiles = tiles.map(func(x: Vector4): return Tiles.onRotateAroundCenter(x))
				
			tiles = tiles.map(func(x: Vector4): return Tiles.position_to_tile(x + Tile.onTTpos()))
			tiles = tiles.filter(func(x: TileGD): return x.solid_status == 0)
			#Tiles.admin_highlight_tiles(tiles)
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

func onFindDObject(Tile: TileGD) -> DObjectGD:
	for dobj in destructables:
		if dobj.BaseTile == Tile: return dobj
	return null

var ActiveTile: TileGD
var object_highlight_movement_path: MovementPathGD

func setGlowMaterial(mat: Material) -> void:
	if ActiveTile.types[1].model != null:
		for mesh in ActiveTile.types[1].model.meshes:
			for surface in range(mesh.get_surface_override_material_count()):
				mesh.set_surface_override_material(surface, mat)

var dobject_material: ShaderMaterial = preload("res://assets/materials/tile_materials/object_outline_material/dobject_material.tres")
var iobject_material: ShaderMaterial = preload("res://assets/materials/tile_materials/object_outline_material/iobject_material.tres")
func onHighlightObj(state: bool, Tile: TileGD) -> void:
	if state and ActiveTile == null:
		var Unit: UnitGD = PlayerManager.getUnitSelected()
		var iobj: IObjectGD = onFindIObject(Tile)
		var dobj: DObjectGD = onFindDObject(Tile)
		
		var material: ShaderMaterial
		if iobj != null:
			material = iobject_material
			if Unit != null and Unit.Tile not in iobj.interactable_tiles:
				var tiles: Array = iobj.interactable_tiles.filter(func(x: TileGD): return x.Unit == null)
				tiles.sort_custom(func(x: TileGD, y: TileGD): return Tiles.tile_distance(x, Unit.Tile) < Tiles.tile_distance(y, Unit.Tile))
				
				if tiles.size() > 0: object_highlight_movement_path = Tiles.onCreatePathHovered(tiles[0])
		elif dobj != null: material = dobject_material
		if material != null: ActiveTile = Tile; setGlowMaterial(material)
		
	elif !state and ActiveTile != null and Tile == ActiveTile:
		setGlowMaterial(null)
		ActiveTile = null
		
		if object_highlight_movement_path != null:
			Tiles.onRemovePathHovered(object_highlight_movement_path.getTiles())
		
func onMultitileObjHovered(state: bool, Tile: TileGD) -> void:
	var _ActiveTile: TileGD = null
	for _Tile in Tile.obj.multi_tile:
		var iobj: IObjectGD = onFindIObject(_Tile)
		if iobj != null:
			onHighlightObj(state, _Tile)
			return
		
func onMouseEntersUI(state: bool) -> void:
	if ActiveTile != null: onHighlightObj(!state, ActiveTile)

func onTrigger(Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	for iobj in interactables.filter(func(x: IObjectGD): return x.has_method("onTrigger")):
		iobj.onTrigger(Unit, trigger, args)

func onRemoveIObject(iobject: IObjectGD) -> void:
	interactables.erase(iobject)
	iobject.BaseTile.obj.id = 0
	iobject.BaseTile.types[1].model = null
	if "ObjModel" in iobject: iobject.ObjModel.queue_free()

func onCreateIObject(Tile: TileGD, id: int) -> void:
	pass
