class_name TileGD
extends TileObjectGD

#region Global
enum OccupyStates {NULL, ALLY, ENEMY, NEUTRAL, ATTACKABLE_IOBJECT}
var occupied_objects: Array = []
var is_hovered: bool = false
var is_path_hovered: bool = false
var is_card_moving: bool = false
var is_action_lock: bool = false
var in_active_effect_range: bool = false
var in_active_effect_pickable: bool = false
var max_movement_height: float

var movement_path: MovementPathGD
var explored: ExploredGD
#endregion

#region Saved Data
var occupy_state: OccupyStates
var tile_fill: bool = false
#endregion

#region Is Checks
func isOccupied() -> bool:
	return get_tree().get_nodes_in_group("FieldCardsGD").any(func(x: CardGD): return x.Tile == self)
	
func isRamp() -> bool:
	return variation == 1
	
func isAdjacent(_coords: Vector4i, distance: int = 1) -> bool:
	return Game.getCoordsDistance(getCoords(), _coords) == distance
	
func isSolid() -> bool:
	return occupied_objects.any(func(x: ObjectGD): return x.isSolid())
	
func isDeepwater() -> bool:
	return info.id == 8
#endregion

#region Getters
func isAllySpawnTile() -> bool:
	var spawns: Array = get_tree().get_nodes_in_group("AllySpawnsGD")
	for spawn_object in spawns:
		if self in spawn_object.occupied_tiles: return true
	return false

func getSpawnTile() -> SpawnGD:
	var spawns: Array = get_tree().get_nodes_in_group("SpawnsGD")
	for spawn_object in spawns:
		if self in spawn_object.occupied_tiles: return spawn_object
	return null
func getHeight() -> int: return coords.w
func getCoordsHeightless() -> Vector3i: return Vector3i(coords.x, coords.y, coords.z)
func getCoords() -> Vector4i: return coords
func getLockRotation() -> bool: return true
func getCard() -> CardGD:
	for FieldCard in get_tree().get_nodes_in_group("FieldCardsGD"):
		if FieldCard.Tile == self: return FieldCard
	return null
func getCardPosition() -> Vector3:
	var base_position: Vector3 = getCardPositionBase()
	if variation == 1: base_position += Vector3(0, 0.6, 0)
	return base_position
	
func getCardPositionBase() -> Vector3:
	return position + Vector3(0, 0.3, 0)
	
func getHalfwayCardPosition(Tile: TileGD) -> Vector3:
	var this: Vector3 = getCardPositionBase()
	var other: Vector3 = Tile.getCardPositionBase()
	var y: float = this.y
	this += other
	this /= 2.0
	this.y = y
	return this

const HEX_SIZE: float = 0.6
	
func getTileFillPoints() -> Array:
	var points: Array = []
	var height: int = getHeight()
	if tile_fill and height > 0:
		for i in range(height): points += Game.tile_face_directions.map(func(x: Vector3): return Vector3(x.x, (i * 0.6) + 0.45 - position.y, x.z))
	return points
#endregion
#region Material Updates
func setMeshesMaterial(mat: Material = null, parent: Node3D = null) -> void:
	for mesh in getMeshes(parent):
		mesh.set_surface_override_material(0, mat)
		
func setOutlineMaterial() -> void:
	var mat: Material = null
	var display_movement_path: bool = getMovementPathDisplay()
	
	if in_active_effect_pickable:
		mat = load(info.ACTIVE_EFFECT_PICKABLE_MATERIAL)
	elif in_active_effect_range:
		mat = load(info.ACTIVE_EFFECT_RANGE_MATERIAL)
	elif (occupy_state != OccupyStates.NULL and vision_datastore.level_visible and !is_card_moving):
		match occupy_state:
			OccupyStates.ALLY: mat = load(info.ALLY_OCCUPY_MATERIAL)
			OccupyStates.ENEMY:
				if !display_movement_path: mat = load(info.ENEMY_OCCUPY_MATERIAL)
				else: mat = load(info.MOVEMENT_RANGE_ATTACKABLE_MATERIAL)
			OccupyStates.NEUTRAL, OccupyStates.ATTACKABLE_IOBJECT:
				if !display_movement_path: mat = load(info.NEUTRAL_OCCUPY_MATERIAL)
				else: mat = load(info.MOVEMENT_RANGE_ATTACKABLE_MATERIAL)
	elif is_path_hovered and !is_action_lock: mat = load(info.PATH_HOVERED_MATERIAL)
	elif is_hovered and !is_action_lock: mat = load(info.HOVERED_MATERIAL)
	elif display_movement_path and !is_action_lock: mat = load(info.MOVEMENT_RANGE_MATERIAL)
	elif !vision_datastore.level_visible: mat = load(info.GREYSCALE_MATERIAL)
		
	getMeshes()[0].set_surface_override_material(1, mat)
#endregion
#region Collision Layers
func setDefaultCollisionLayers() -> void:
	setCollisionLayers(24)
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
	return SavedDataTile.new(info.id, false, public_id, coords, tile_rotation, vision_datastore, variation, tile_fill, occupy_state, explored)

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
	explored = ExploredGD.new()
	
func onProcessAction(_action: Action) -> void:
	pass
#endregion
#region Occupied Objects
func setOccupiedObject(object: ObjectGD) -> void:
	occupied_objects.append(object)
	max_movement_height = max(max_movement_height, object.getMaxMovementHeight())
	
func getAttackableIObjects() -> Array:
	return occupied_objects.filter(func(x: ObjectGD): return x is IObjectGD)
#endregion
#region Hover
func onHovered(state: bool) -> void:
	if is_hovered != state:
		is_hovered = state
		setOutlineMaterial()
		
		if !getMovementPathDisplay(): return
		for i in range(movement_path.tiles.size()):
			var Tile: TileGD = movement_path.tiles[i]
			Tile.setPathHovered(state)
			
			if i > 0:
				var PreviousTile: TileGD = movement_path.tiles[i - 1]
				var damage: int = Tile.getFallDamage(PreviousTile)
				if damage > 0:
					Tile.setFallDamageWorldEffect(state, PreviousTile, damage)
		
#endregion
#region Occupied By Unit
func onOccupy(Card: CardGD, instant: bool) -> void:
	if Card == null: occupy_state = OccupyStates.NULL
	elif Card.team == 0: occupy_state = OccupyStates.ALLY
	elif Card.team == 1: occupy_state = OccupyStates.ENEMY
	elif Card.team == 2: occupy_state = OccupyStates.NEUTRAL
	
	if instant: setOutlineMaterial()
	
func onOccupyByIObject(_IObject: IObjectGD) -> void:
	occupy_state = OccupyStates.ATTACKABLE_IOBJECT
	setOutlineMaterial()
#endregion

#region Movement Range / Path Hovered
func setPathHovered(state: bool) -> void:
	is_path_hovered = state
	setOutlineMaterial()

func getMovementPathDisplay() -> bool:
	return movement_path != null and movement_path.display
	
func setMovementPathDisplay(state: bool) -> void:
	if movement_path != null and movement_path.display != state:
		movement_path.display = state
		setOutlineMaterial()
		
func setMovementPath(_movement_path: MovementPathGD) -> void:
	if movement_path != _movement_path:
		movement_path = _movement_path
		setOutlineMaterial()
	
func getMovementPathSize() -> int:
	if movement_path == null: return -1
	return movement_path.tiles.size()
	
func getMovementPathTiles() -> Array:
	return movement_path.tiles
	
func isBelowMaxMovementHeight(Card: CardGD) -> bool:
	if max_movement_height == 0: return true
	return Card.info.top + Card.position.y < (max_movement_height + getCardPosition().y)
#endregion

#region Ramps
func isValidRampRelation(Tile: TileGD) -> bool:
	var relative_tile_rotation: int = Game.getRelativeTileRotation(self, Tile)
	return (relative_tile_rotation == (tile_rotation + 2) % 6) or (relative_tile_rotation == (tile_rotation + 5) % 6)
#endregion

#region Fall Damage
func getFallDamage(Tile: TileGD) -> int:
	var height_diff: int = Tile.getHeight() - getHeight()
	return floor((height_diff - 3) / 2.0) if height_diff >= Game.FALL_DAMAGE_BEGIN_HEIGHT else 0
	
var FallDamageEffect: Node3D
func setFallDamageWorldEffect(state: bool, PreviousTile: TileGD, damage: int) -> void:
	if FallDamageEffect != null: FallDamageEffect.queue_free()
	if state and damage > 0:
		FallDamageEffect = load(info.FALL_DAMAGE_EFFECT_SCENE_PATH).instantiate()
		add_child(FallDamageEffect)
		
		set_spectate_card.emit(self)
		FallDamageEffect.setInfo(self, PreviousTile, SpectateCard, damage)
		
#endregion

#region Vision
func getVisibleGroup() -> Array:
	var visible_group: Array = [self]
	
	for Obj in occupied_objects:
		visible_group.append(Obj)
			
	var Card: CardGD = Game.getFieldCard(self)
	if Card != null: visible_group.append(Card)
	return visible_group

#endregion

#region Action Lock
func onUpdateActionLock(state: bool) -> void:
	is_action_lock = state
	setOutlineMaterial()
#endregion

#region Active Effect
func setInActiveEffectRange(state: bool) -> void:
	in_active_effect_range = state
	setOutlineMaterial()

func setInActiveEffectPickable(state: bool) -> void:
	in_active_effect_pickable = state
	setOutlineMaterial()
	
func isActiveEffectPickable() -> bool:
	return in_active_effect_pickable
#endregion
