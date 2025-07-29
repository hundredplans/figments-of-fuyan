extends IObjectGD

var is_open: bool
var last_seen_open: bool
var CollisionShape: CollisionShape3D

const ABILITY_DELAY: float = 2.0
const SHORT_MAX_MOVEMENT_HEIGHT: float = 1.0
const TALL_MAX_MOVEMENT_HEIGHT: float = 2.5

#region Data Loading
func onLoadDataLevel() -> void:
	super()
	for ExistingBody in Helper.getNodeTypeRecursive(self, StaticBody3D):
		ExistingBody.queue_free()
	
	var StaticBody := StaticBody3D.new()
	getMeshes()[0].add_child(StaticBody)
	
	CollisionShape = CollisionShape3D.new()
	StaticBody.add_child(CollisionShape)
	
	onAfterLoadModel()
	
	if is_open: onDoorIsOpen(last_seen_open)
	else: onDoorIsClosed(!last_seen_open)
	AniPlayer.animation_finished.connect(func(__: String): onIdle())
	
	if isLevelVisible(): onIdle()

func onSave() -> SavedDataIObject:
	ability_save['is_open'] = is_open
	ability_save['last_seen_open'] = last_seen_open
	return super()
	
#endregion

#region Process
func onProcessAction(action: Action) -> void:
	super(action)
#endregion

#region Helper
func onIdle() -> void:
	if vision_datastore.level_visible:
		AniPlayer.play("Idle" if !is_open else "IdleAbility")

func isSolid() -> bool:
	return !is_open
	
func isTall() -> bool:
	return variation == 0
	
func onUpdateLevelVisible() -> void:
	super()
	if isLevelVisible():
		if last_seen_open and !is_open: onDoorIsClosed()
		elif !last_seen_open and is_open: onDoorIsOpen()
		onIdle()
	else:
		AniPlayer.stop()
#endregion
	
#region Valid / Disabled
func getValidActiveEffects(Card: CardGD) -> Array: # Returns the ability effects the Card can view
	var Tile: TileGD = getTile()
	
	if Card.getTile().getHeight() != getTile().getHeight(): return []
	
	if is_open and get_tree().get_nodes_in_group("FieldCardsGD").any(func(x: CardGD): return x.Tile == Tile): return []
	if !isAdjacent(Card.getCoords()): return []

	return [getActiveEffect("Close Door") if is_open else getActiveEffect("Open Door")]
#endregion
	
#region Active Effect
func getActiveEffectTiles(_active_effect: ActiveEffectDatastore, _Card: CardGD) -> ActiveEffectTiles:
	return ActiveEffectTiles.new([getTile()], [getTile()])
	
func onActiveEffect(active_effect: ActiveEffectDatastore, _PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles, Card: CardGD) -> void:
	var animation_action := AnimationAction.new(self, "Ability", !is_open)
	animation_action.setActionDelay(ABILITY_DELAY)
	
	var actions: Array = [animation_action, VisionAction.new(Game.inVisionRangeCards(Card.getTile(), true))]
	for owned_active_effect in active_effects.filter(func(x: ActiveEffectDatastore): return x != active_effect):
		actions.append(ChangeActiveEffectUsedAction.new(owned_active_effect, true))
	actions.append(CameraChangeAction.new(Card))
	onPushAction(actions)
		
func onActiveEffectPre(active_effect: ActiveEffectDatastore, PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles, Card: CardGD) -> void:
	if active_effect.name == "Open Door":
		if isLevelVisible(): last_seen_open = true
		is_open = true
		onDoorIsOpen(false)
		
	elif active_effect.name == "Close Door":
		if isLevelVisible(): last_seen_open = false
		is_open = false
		onDoorIsClosed(false)
	onForceAction(CameraChangeAction.new(self))
	onForceAction(ChangeTileRotationAction.new(Card, Game.getRelativeTileRotation(Card.Tile, PickedTile)))
#endregion

#region Door
# Have to set the collision shape aswell as animation position
func onDoorIsOpen(set_door_position: bool = true) -> void:
	var collision_position_shape: CollisionPositionShape = load(info.PALM_DOOR_TALL_OPEN_MESH_PATH if isTall() else info.PALM_DOOR_SHORT_OPEN_MESH_PATH)
	CollisionShape.shape = collision_position_shape.collision_shape
	CollisionShape.position = collision_position_shape.position
	if set_door_position:
		AniPlayer.set_current_animation("Ability")
		AniPlayer.stop()
		AniPlayer.seek(AniPlayer.get_animation("Ability").length, true)
	
func onDoorIsClosed(set_door_position: bool = true) -> void:
	var collision_position_shape: CollisionPositionShape = load(info.PALM_DOOR_TALL_CLOSED_MESH_PATH if isTall() else info.PALM_DOOR_SHORT_CLOSED_MESH_PATH)
	CollisionShape.shape = collision_position_shape.collision_shape
	CollisionShape.position = collision_position_shape.position
	if set_door_position:
		AniPlayer.set_current_animation("Ability")
		AniPlayer.stop()
		AniPlayer.seek(0, true)
#endregion

func getMaxMovementHeight() -> float:
	return SHORT_MAX_MOVEMENT_HEIGHT if !isTall() else TALL_MAX_MOVEMENT_HEIGHT

const GET_CLOSE_TO_DOOR_INCENTIVE: float = 0.3
func onIObjectSpecificTransforms(tiles_to_value: Dictionary, _DFL: DefaultFightLogic) -> void:
	if is_open: return
	for Tile in tiles_to_value:
		if Game.isAdjacent(Tile, getTile()):
			tiles_to_value[Tile] += GET_CLOSE_TO_DOOR_INCENTIVE

# When possible open the door, never close it
func onAIAbilityChecker(active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _DFL: DefaultFightLogic) -> TileGD:
	return active_effect_tiles.pickable_tiles[0] if !is_open and active_effect.name == "Open Door" else null
