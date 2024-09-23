class_name TileGD
extends TileObjectGD

#region Global
enum OccupyStates {NULL, ALLY, ENEMY, NEUTRAL}
var occupied_objects: Array = []
#endregion

#region Saved Data
var occupy_state: OccupyStates
var tile_fill: bool = false
#endregion
#region Is Checks
func isAllySpawnTile() -> bool:
	var ally_spawns: Array = get_tree().get_nodes_in_group("AllySpawnsGD")
	return occupied_objects.any(func(x: ObjectGD): return x in ally_spawns)

func isOccupied() -> bool:
	return get_tree().get_nodes_in_group("FieldCardsGD").any(func(x: CardGD): return x.Tile == self)
#endregion
#region Getters
func getHeight() -> int: return coords.w
func getCoordsHeightless() -> Vector3i: return Vector3i(coords.x, coords.y, coords.z)
func getCoords() -> Vector4i: return coords
func getLockRotation() -> bool: return true
#endregion
#region Material Updates
func setMeshesMaterial(mat: Material = null) -> void:
	for mesh in getMeshes():
		mesh.set_surface_override_material(0, mat)
		
func setOutlineMaterial(mat: Material = null, set_by_occupy_material: bool = false) -> void:
	if mat == null:
		if !level_visible: mat = load(info.GREYSCALE_MATERIAL)
		elif !set_by_occupy_material: onApplyOccupyMaterial(); return
		
	getMeshes()[0].set_surface_override_material(1, mat)
#endregion
#region Collision Layers
func setDefaultCollisionLayers() -> void:
	for body in getStaticBodies():
		body.collision_layer = 24
#endregion
#region Tile Fill
var TileFill: Node3D
func onCreateTileFill(state: bool) -> String:
	if getHeight() == 0: return "NULL"
	
	tile_fill = state
	if TileFill != null: TileFill.queue_free()
	if tile_fill:
		TileFill = info.tile_fill.instantiate()
		add_child(TileFill)
		TileFill.global_position.y = 0
		TileFill.scale.y = getHeight()
		return "DESTROY"
	return "CREATE"
#endregion
#region Save / Load
func onSave() -> SavedDataGameObject:
	return SavedDataTile.new(info.id, false, coords, tile_rotation, level_visible, variation, tile_fill, occupy_state)

func onLoadData(data: SavedData) -> void:
	super(data)
	onLoadModel()
	onCreateTileFill(data.tile_fill)
	occupy_state = data.occupy_state
	add_to_group("TilesGD")
	
func onLoadModel() -> void:
	super()
	setCoords(coords)
	setTileRotation(tile_rotation)
	
func onLoadDataLevel() -> void:
	super()
	onApplyOccupyMaterial()
	
func onProcessAction(action: Action) -> void:
	if action.post:
		if action is ChangePhaseAction and action.phase == Game.Phases.START:
			setLevelVisible(isAllySpawnTile())

func setLevelVisible(state: bool, avoid_recursion: bool = false) -> void:
	super(state)
	if !avoid_recursion:
		for object in occupied_objects: object.setLevelVisible(state, true)
#endregion
#region Occupied Objects
func setOccupiedObject(object: ObjectGD) -> void:
	occupied_objects.append(object)
#endregion
#region Hover
var is_hovered: bool
func onHovered(state: bool) -> void:
	if is_hovered != state:
		is_hovered = state
		setOutlineMaterial(load(info.HOVERED_MATERIAL) if state else null)
#endregion
#region Occupied By Unit
func onOccupy(Card: CardGD, instant: bool) -> void:
	if Card == null: occupy_state = OccupyStates.NULL
	elif Card.team == 0: occupy_state = OccupyStates.ALLY
	elif Card.team == 1: occupy_state = OccupyStates.ENEMY
	elif Card.team == 2: occupy_state = OccupyStates.NEUTRAL
	
	if instant:
		onApplyOccupyMaterial()
		
func onApplyOccupyMaterial() -> void:
	var mat: Material
	match occupy_state:
		OccupyStates.ALLY: mat = load(info.ALLY_OCCUPY_MATERIAL)
		OccupyStates.ENEMY: mat = load(info.ENEMY_OCCUPY_MATERIAL)
		OccupyStates.NEUTRAL: mat = load(info.NEUTRAL_OCCUPY_MATERIAL)
		OccupyStates.NULL: mat = null
	setOutlineMaterial(mat, true)
#endregion
