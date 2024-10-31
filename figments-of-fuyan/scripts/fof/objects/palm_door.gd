extends IObjectGD

var is_open: bool
var last_seen_open: bool
var CollisionShape: CollisionShape3D

func onLoadData(data: SavedData) -> void:
	super(data)
	var StaticBody := StaticBody3D.new()
	getMeshes()[0].add_child(StaticBody)
	
	CollisionShape = CollisionShape3D.new()
	StaticBody.add_child(CollisionShape)
	
	if is_open: onDoorIsOpen(last_seen_open)
	else: onDoorIsClosed(!last_seen_open)
	onAfterLoadModel()
	
	AniPlayer.animation_finished.connect(func(__: String): onIdle())

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is LevelVisibleAction and self in action.game_objects:
			onUpdateVisible(action.state)
	
func getValidActiveEffects(Card: CardGD) -> Array: # Returns the ability effects the Card can view
	return [getActiveEffect("Close Door") if is_open else getActiveEffect("Open Door")] if isAdjacent(Card.getCoords()) else []
	
func getActiveEffect(effect_name: String) -> ActiveEffectDatastore:
	for active_effect in active_effects:
		if active_effect.name == effect_name: return active_effect
	return null
	
func getActiveEffectTiles(_active_effect: ActiveEffectDatastore, Card: CardGD) -> ActiveEffectTiles:
	return ActiveEffectTiles.new([Card.Tile], [Card.Tile])
	
func onActiveEffect(_active_effect: ActiveEffectDatastore, PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles) -> void:
	onPushAction(VisionAction.new([Game.getFieldCard(PickedTile)] + Game.inVisionCards(PickedTile.getCoords())))
		
func onActiveEffectPre(active_effect: ActiveEffectDatastore, _PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles) -> void:
	if active_effect.name == "Open Door":
		if level_visible: AniPlayer.play("Ability"); last_seen_open = true
		is_open = true
		onDoorIsOpen(false)
		
	elif active_effect.name == "Close Door":
		if level_visible: AniPlayer.play_backwards("Ability"); last_seen_open = false
		is_open = false
		onDoorIsClosed(false)

func onSave() -> SavedDataIObject:
	ability_save['is_open'] = is_open
	ability_save['last_seen_open'] = last_seen_open
	return super()

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
	
func isTall() -> bool:
	return variation == 0
	
func onUpdateVisible(state: bool) -> void:
	if state: # If visible
		if last_seen_open and !is_open: onDoorIsClosed()
		elif !last_seen_open and is_open: onDoorIsOpen()
		onIdle()
	else:
		AniPlayer.stop()

func onIdle() -> void:
	if level_visible:
		AniPlayer.play("Idle" if !is_open else "IdleAbility")

func isSolid() -> bool:
	return !is_open
