class_name TileGD
extends TileObjectGD

#region Global
enum OccupyStates {NULL, ALLY, ENEMY, NEUTRAL}
var occupied_objects: Array = []
#endregion

#region Saved Data
var occupy_state: OccupyStates
var tile_fill: bool = false
var is_hovered: bool = false
var is_path_hovered: bool = false
var is_movement_range: bool = false
var is_movement_range_attackable: bool = false
var movement_path: Array
#endregion

#region Is Checks
func isAllySpawnTile() -> bool:
	var ally_spawns: Array = get_tree().get_nodes_in_group("AllySpawnsGD")
	return occupied_objects.any(func(x: ObjectGD): return x in ally_spawns)

func getAllySpawnTile() -> SpawnGD:
	var ally_spawns: Array = get_tree().get_nodes_in_group("AllySpawnsGD")
	for spawn_object in ally_spawns:
		if self in spawn_object.occupied_tiles: return spawn_object
	return null

func isOccupied() -> bool:
	return get_tree().get_nodes_in_group("FieldCardsGD").any(func(x: CardGD): return x.Tile == self)
#endregion

#region Getters
func getHeight() -> int: return coords.w
func getCoordsHeightless() -> Vector3i: return Vector3i(coords.x, coords.y, coords.z)
func getCoords() -> Vector4i: return coords
func getLockRotation() -> bool: return true
func getCard() -> CardGD:
	for FieldCard in get_tree().get_nodes_in_group("FieldCardsGD"):
		if FieldCard.Tile == self: return FieldCard
	return null
func getCardPosition() -> Vector3:
	return (position + Vector3(0, 0.3, 0)) if variation == 0 else (position + Vector3(0, 0.9, 0))
#endregion
#region Material Updates
func setMeshesMaterial(mat: Material = null) -> void:
	for mesh in getMeshes():
		mesh.set_surface_override_material(0, mat)
		
func setOutlineMaterial() -> void:
	var mat: Material = null
	if occupy_state != OccupyStates.NULL:
		match occupy_state:
			OccupyStates.ALLY: mat = load(info.ALLY_OCCUPY_MATERIAL)
			OccupyStates.ENEMY: mat = load(info.ENEMY_OCCUPY_MATERIAL)
			OccupyStates.NEUTRAL: mat = load(info.NEUTRAL_OCCUPY_MATERIAL)
	elif is_path_hovered: mat = load(info.PATH_HOVERED_MATERIAL)
	elif is_hovered: mat = load(info.HOVERED_MATERIAL)
	elif !level_visible: mat = load(info.GREYSCALE_MATERIAL)
	elif is_movement_range: mat = load(info.MOVEMENT_RANGE_MATERIAL)
	elif is_movement_range_attackable: mat = load(info.MOVEMENT_RANGE_ATTACKABLE_MATERIAL)
		
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
	setOutlineMaterial()
	
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
func onHovered(state: bool) -> void:
	if is_hovered != state:
		is_hovered = state
		setOutlineMaterial()
		
		if is_movement_range:
			for Tile in movement_path: Tile.setPathHovered(state)
		
#endregion
#region Occupied By Unit
func onOccupy(Card: CardGD, instant: bool) -> void:
	if Card == null: occupy_state = OccupyStates.NULL
	elif Card.team == 0: occupy_state = OccupyStates.ALLY
	elif Card.team == 1: occupy_state = OccupyStates.ENEMY
	elif Card.team == 2: occupy_state = OccupyStates.NEUTRAL
	
	if instant: setOutlineMaterial()
#endregion

#region Movement Range / Path Hovered
func onRemoveMovementRange() -> void:
	if is_movement_range or is_movement_range_attackable:
		is_movement_range = false
		is_movement_range_attackable = false
		setOutlineMaterial()

func setMovementRange(state: bool) -> void:
	is_movement_range = state
	setOutlineMaterial()

func setPathHovered(state: bool) -> void:
	is_path_hovered = state
	setOutlineMaterial()

#endregion

#region Ramps
func isValidRampRelation(Tile: TileGD) -> bool:
	return true
	var relative_tile_rotation: int = Game.getRelativeTileRotation(self, Tile) 
	return (relative_tile_rotation == (tile_rotation - 1) % 6) or (relative_tile_rotation == (tile_rotation - 4) % 6)
