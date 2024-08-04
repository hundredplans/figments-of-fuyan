class_name ObjectManagerGD
extends Node

var Tiles: TilesGD
var PlayerManager: PlayerManagerGD
var Vision: VisionGD
var LevelMap: LevelMapGD

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

func onStartPhaseStart() -> void:
	LevelMap.input_lock_updated.connect(onInputLockUpdated)

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
	var info: ObjectInteractTilesGD = onFindIObjectInfo(Tile.obj.id)
	if info == null: return
	
	var iobject: IObjectGD = info.iobject_script.new()
	for ability in info.abilities:
		ability.tiles = ability.tiles.map(func(x: Vector4): return Tiles.onRotatePositionLeft(x, Tile.obj.rotation))
		ability.tiles = ability.tiles.map(func(x: Vector4): return Tiles.position_to_tile(x + Tile.onTTpos()))
		ability.tiles = ability.tiles.filter(func(x: TileGD): return x.solid_status == 0)
		for _Tile in ability.tiles: if _Tile not in iobject.total_tiles: iobject.total_tiles.append(_Tile)
		
	interactables.append(iobject)
	iobject.setInfo(Tile, info)

func onFindIObject(Tile: TileGD) -> IObjectGD:
	for iobj in interactables:
		if iobj.BaseTile == Tile: return iobj
	return null

func onFindIObjectInfo(id: int) -> ObjectInteractTilesGD:
	for info in interactable_obj_resources:
		if info.id == id: return info
	return null

func onFindDObject(Tile: TileGD) -> DObjectGD:
	for dobj in destructables:
		if dobj.BaseTile == Tile: return dobj
	return null

var ActiveTile: TileGD
var object_highlight_movement_path: MovementPathGD

func onInputLockUpdated() -> void:
	var state: bool = LevelMap.verifyLock(LevelMapGD.HIGHLIGHT_OBJ)
	if !state: onHighlightObj(false, ActiveTile)
	else: onHighlightObj(true, HoveredObjectTile)
	

func setGlowMaterial(mat: Material) -> void:
	if ActiveTile.types[1].model != null:
		for mesh in ActiveTile.types[1].model.meshes:
			for surface in range(mesh.get_surface_override_material_count()):
				mesh.set_surface_override_material(surface, mat)

var dobject_material: ShaderMaterial = preload("res://assets/materials/tile_materials/object_outline_material/dobject_material.tres")
var iobject_material: ShaderMaterial = preload("res://assets/materials/tile_materials/object_outline_material/iobject_material.tres")
var HoveredObjectTile: Node3D
func onHighlightObj(state: bool, Tile: TileGD) -> void:
	HoveredObjectTile = Tile
	if state and ActiveTile == null and Tile in Vision.getTeamVision():
		var Unit: UnitGD = PlayerManager.getUnitSelected()
		var iobj: IObjectGD = onFindIObject(Tile)
		var dobj: DObjectGD = onFindDObject(Tile)
		
		var material: ShaderMaterial
		if iobj != null:
			material = iobject_material
			if Unit != null and Unit.Tile not in iobj.total_tiles:
				var tiles: Array = iobj.total_tiles.filter(func(x: TileGD): return x.Unit == null)
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

	for dobj in destructables.filter(func(x: DObjectGD): return x.has_method("onTrigger")):
		dobj.onTrigger(Unit, trigger, args)

func onRemoveIObject(iobject: IObjectGD) -> void:
	if iobject != null:
		interactables.erase(iobject)
		iobject.BaseTile.obj.id = 0
		iobject.BaseTile.types[1].model = null
		if "ObjModel" in iobject: iobject.ObjModel.queue_free()

func onRemoveDObject(dobject: DObjectGD) -> void:
	if dobject != null:
		destructables.erase(dobject)
		dobject.BaseTile.obj.id = 0
		dobject.BaseTile.types[1].model = null
		dobject.onDestroyed()
		if "ObjModel" in dobject: dobject.ObjModel.queue_free() 

func onCreateIObject(Tile: TileGD, id: int) -> void:
	if isTileObj(Tile): onRemoveIObject(onFindIObject(Tile))
	Tile.obj.id = id
	var model_path: String = "res://assets/models/objects/" + Helper._id_to[1][id] + ".tscn"
	var model: Node3D = load(model_path).instantiate()
	Tile.ModelManager.add_child(model)
	model.position.y += 0.9 if Tiles.is_ramp_tile(Tile) else 0.3
	Tile.types[1].model = model
	onAddInteractableObj(Tile)

func isTileObj(Tile: TileGD) -> bool: return Tile.obj.id > 0
