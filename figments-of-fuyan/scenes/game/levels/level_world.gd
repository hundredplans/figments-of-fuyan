extends Node3D

#region Exports
@export var SpawnParticlePacked: PackedScene
#endregion

#region Globals
var level: LevelGD
var save_file: SaveFileGD
var area: AreaGD
var UI: Control
#endregion

#region Signals
signal active_effect_activated
signal active_effect_deselected
signal active_effect_selected
#endregion

#region Onready
@onready var CameraManager: Node3D = %CameraManager
@onready var WorldEnv: WorldEnvironment = %WorldEnvironment
@onready var AniPlayer: AnimationPlayer = %AnimationPlayer
#endregion

#region Base Functions
#func _ready() -> void:
	#CameraManager.setCameraType(false)
	
func setInfo(_save_file: SaveFileGD) -> void:
	save_file = _save_file
	area = save_file.area
	level = area.active_level
	
	setEnvironment()
	add_child(area.info.default_light.instantiate())
	
	level.phase_changed.connect(onPhaseChanged)
	level.awakened.connect(onCardAwakened)
	level.request_camera_data.connect(CameraManager.setCameraSaveables.bind(level))
	level.turn_state_changing.connect(onTurnStateChanging)
	level.camera_change_action.connect(onCameraChange)
	level.game_ended.connect(onGameEnded)
	level.game_started.connect(onGameStarted)
	level.camera_change_pre.connect(onCameraChangePre)
	level.spectate_group.connect(CameraManager.onSpectateGroup)
	level.set_last_ally_spectate_object.connect(setLastAllySpectateObjectForLevel)
	level.request_camera_position_update.connect(onRequestCameraPositionUpdate)
	level.vision_changed.connect(onVisionChanged)
	
	CameraManager.camera_position_updated.connect(onCameraPositionUpdated)
	CameraManager.create_camera_action.connect(onCreateCameraChangeAction)
	CameraManager.setInfo(level.level_camera_data)
	
	UI.action_lock.connect(CameraManager.setActionLock)
	UI.action_lock.connect(onUpdateActionLock)
	UI.mouse_signal.connect(onMouseInUI)
	UI.camera_button_pressed.connect(CameraManager.onSwapCameraType)
	UI.camera_direction_changed.connect(CameraManager.onChangeCameraInDirection)
	UI.vision_mode_changed.connect(onVisionModeChanged)
	UI.active_effect_box_pressed.connect(onActiveEffectBoxPressed)
	UI.create_movement_range.connect(onCreateMovementRange)
	
	UI.dragged_begin.connect(onCardDraggedBegin)
	UI.dragged_end.connect(onCardDraggedEnd)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		onUpdateMousePosition()
	
func _process(_delta: float) -> void:
	if MouseHoverTile != null:
		if Input.is_action_just_pressed("MainInput"): onTilePressed()
		elif Input.is_action_just_pressed("InspectCard"): onTileInspected()
	
#endregion

#region Hover Tile
@onready var MouseRaycast: RayCast3D = %MouseRaycast
const RAY_LENGTH: int = 5000
var MouseHoverTile: TileGD

func onUpdateMousePosition() -> void:
	onHoverTile(true)

func onHoverTile(is_mouse_hover: bool = false) -> void:
	var Tile: TileGD = getMouseHoverTile()
	var enable_hover: bool = !getActionLock() and !getMouseInUI() and !camera_panning
	
	if !(Tile == MouseHoverTile and is_mouse_hover):
		if (!is_mouse_hover or enable_hover) and MouseHoverTile != null:
			MouseHoverTile.onHovered(false)
			MouseHoverTile = null
		
		if enable_hover and Tile != null:
			MouseHoverTile = Tile
			MouseHoverTile.onHovered(true)
			
		if in_vision_mode: onVisionModeTileHovered(MouseHoverTile)

func getMouseHoverTile() -> TileGD:
	var viewport: Viewport = get_viewport()
	if viewport != null:
		var to: Vector3 = CameraManager.CurrentCamera.project_ray_normal(viewport.get_mouse_position()) * RAY_LENGTH
		
		MouseRaycast.position = CameraManager.CurrentCamera.position
		MouseRaycast.target_position = to
		MouseRaycast.force_raycast_update()
		
		if MouseRaycast.is_colliding():
			var Tile: TileGD = Helper.getCollision(MouseRaycast.get_collider(), TileGD)
			if Tile.is_in_group("LevelTilesGD"):
				return Tile
	return null
#endregion

#region Action Lock / Mouse in UI
func getActionLock() -> bool:
	return UI.getActionLock()
	
func onUpdateActionLock(state: bool) -> void:
	onHoverTile()
	
	if state: onHideMovementRange() # ; onActiveEffectDeselected()
	else: onCreateMovementRange(level.getAllySpectateObject())
	
func getMouseInUI() -> bool:
	return mouse_in_ui
	
var mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	mouse_in_ui = state
	CameraManager.onMouseInUI(state)
	onHoverTile()
	
var camera_panning: bool
func onCameraPanning(state: bool) -> void:
	camera_panning = state
	onHoverTile()
#endregion
	
#region Phases
func onPhaseChanged(phase: Game.Phases, previous_phase: Game.Phases, _instant: bool = false) -> void:
	match phase:
		Game.Phases.START: CameraManager.onSpectateSpawn(); onSpawnFX(true)
		Game.Phases.HAND:
			if previous_phase != Game.Phases.START:
				CameraManager.onSpectateSpawn()
			onSpawnFX(true)
		Game.Phases.PLAYER:
			onSpawnFX(false)
			if Game.ActionManagerReference.onFindFirstAction(CameraChangeAction) != null: return
			CameraManager.onSpectateAllies()
#endregion
	
#region SpawnFX
func onSpawnFX(state: bool) -> void:
	get_tree().call_group("SpawnParticles", "onSpawnFX", state)	
#endregion

#region Awakening
func onCardAwakened(Card: CardGD) -> void:
	if Card.isEnemy(0): return
	onSpawnFX(true)
#endregion

#region Tile Pressing
func onTilePressed() -> void:
	var Tile: TileGD = MouseHoverTile
	
	if Tile.isActiveEffectPickable() and current_active_effect != null:
		onActiveEffectActivated(Tile)
	elif Tile.getMovementPathDisplay():
		var Card: CardGD = level.getAllySpectateObject()
		if Card != null:
			level.onPushAction(MovementAction.new(Card, Tile.getMovementPathTiles()))
	elif Tile.isOccupied() and Tile.isLevelVisible() and Tile.getCard().isLevelVisible():
		onCreateCameraChangeAction(Tile.getCard())
	
func onTileInspected() -> void:
	var Tile: TileGD = MouseHoverTile
	var Card: CardGD = Tile.getCard()
	if Card != null and Card.isLevelVisible():
		Card.setInspectable(true, UI)
		Card.onInspectCard()
#endregion

#region Camera
func getLastAllySpectateObject() -> CardGD:
	return CameraManager.getLastAllySpectateObject()
	
func setLastAllySpectateObjectForLevel() -> void:
	level.LastAllySpectateObject = getLastAllySpectateObject()

func onRequestCameraPositionUpdate() -> void:
	CameraManager.onUpdateCameraPosition()
	
func onCameraPositionUpdated(pos: Vector3) -> void:
	get_tree().call_group("FieldCardsGD", "onCameraPositionUpdated", pos)
	
func onCameraChange(SpectateObject: GameObjectGD, OldSpectateObject: GameObjectGD) -> void:
	if OldSpectateObject is CardGD and OldSpectateObject.isAlive(): OldSpectateObject.onSpectated(false)
	if SpectateObject is CardGD and SpectateObject.isAlive(): SpectateObject.onSpectated(true)
	CameraManager.onCameraChange(SpectateObject)
	
	setLevelVisibleNotInVisionForSpectateObject(SpectateObject)
	
func onCameraChangePre(_SpectateObject: GameObjectGD, _OldSpectateObject: GameObjectGD) -> void:
	if !CameraManager.isCycle():
		onActiveEffectDeselected()
	
func onCreateCameraChangeAction(SpectateObject: GameObjectGD) -> void:
	if level.is_ended: return
	level.onPushAction(CameraChangeAction.new(SpectateObject))
#endregion
		
#region Movement Range
func onHideMovementRange() -> void:
	get_tree().call_group("LevelTilesGD", "setMovementPathDisplay", false)
	get_tree().call_group("FieldCardsGD", "setEnemyInMovementRange", false)
	
func onCreateMovementRange(Card: CardGD) -> void:
	if level.phase != Game.Phases.PLAYER:
		if level.phase == Game.Phases.HAND:
			onHideMovementRange()
		return
	if Card == null or !Card.isAlly() or Card.turn_state == Game.TurnStates.PASSED: return
	
	Game.getsetMovementRange(Card)
#endregion

#region Turn State
func onTurnStateChanging(Card: CardGD, action: ChangeTurnStateAction) -> void:
	if Card.isAlly(0) and Card.turn_state == Game.TurnStates.PASSED and !isActionTiedToAwakenAction(action):
		var ally_cards: Array = Game.getAllyUnits(0).filter(func(x: CardGD): return x.turn_state == Game.TurnStates.INACTIVE)
		if ally_cards.is_empty(): return
		ally_cards.sort_custom(func(x: CardGD, y: CardGD): return Game.getCoordsDistance(x.getCoords(), Card.getCoords()) < Game.getCoordsDistance(y.getCoords(), Card.getCoords()))
		onCreateCameraChangeAction(ally_cards[0])
		
func isActionTiedToAwakenAction(action: ChangeTurnStateAction) -> bool:
	if action.owner is AwakenAction:
		return true
	if action.owner is not StatusEffectGD:
		return false
	if action.owner.info.id == 3:
		return true
	return false
#endregion

#region Vision
var original_vision: Dictionary
var default_vision: Dictionary
var cards_vision_mode: Dictionary # Dict of Card: CardVisionMode
var in_vision_mode: bool
func onVisionModeChanged(state: bool) -> void:
	in_vision_mode = state
	LastCardVisionMode = null
	var all_cards: Array = get_tree().get_nodes_in_group("FieldCardsGD")
	if state:
		original_vision = {}
		default_vision = {}
		
		for GameObject in get_tree().get_nodes_in_group("LevelTileObjectsGD") + all_cards:
			var level_visible: bool = GameObject.isLevelVisible()
			original_vision[GameObject] = level_visible
			GameObject.setLevelVisible(level_visible)
			default_vision[GameObject] = false if GameObject is not CardGD else level_visible
			GameObject.setLevelVisible(default_vision[GameObject])
			
		for Card in all_cards:
			Card.setLevelVisibleNotInVision(false)
	else:
		for GameObject in original_vision:
			GameObject.setLevelVisible(original_vision[GameObject])
			
		setLevelVisibleNotInVisionForSpectateObject()
		
		original_vision = {}
		default_vision = {}
	
var LastCardVisionMode: CardGD
func onVisionModeTileHovered(Tile: TileGD) -> void:
	if !in_vision_mode: return
	var all_cards: Array = get_tree().get_nodes_in_group("FieldCardsGD")
	if LastCardVisionMode != null and Tile != LastCardVisionMode.Tile: # New Unit
		LastCardVisionMode = null
		for GameObject in default_vision:
			GameObject.setLevelVisible(default_vision[GameObject])
			if GameObject is CardGD:
				GameObject.setLevelVisibleNotInVision(false)
				
		for OtherCard in all_cards: OtherCard.setLevelVisibleNotInVision(OtherCard not in default_vision)
		
	if Tile == null: return
	
	var Card: CardGD = Game.getFieldCard(Tile)
	if Card == null or !Card.isLevelVisible(): return
	if Card == LastCardVisionMode: return
		
	var ally_vision: Array = Game.getTeamVision(0)
	LastCardVisionMode = Card
	
	var new_vision: Array = LastCardVisionMode.getVisibleGameObjects()
	for GameObject in new_vision.filter(func(x: GameObjectGD): return x in ally_vision):
		GameObject.setLevelVisible(true)
		if GameObject is CardGD:
			GameObject.setLevelVisibleNotInVision(true)
			
	for OtherCard in all_cards: OtherCard.setLevelVisibleNotInVision(OtherCard not in new_vision)

func setLevelVisibleNotInVisionForSpectateObject(SpectateObject: GameObjectGD = level.getSpectateObject()) -> void:
	var spectate_vision: Array = SpectateObject.getVisibleFieldCards() if SpectateObject != null and SpectateObject is CardGD else []
	var is_spectate_vision_empty: bool = spectate_vision.is_empty()
	
	for Card in get_tree().get_nodes_in_group("FieldCardsGD"):
		var is_level_visible: bool = Card.isLevelVisible()
		var is_card_in_spectate_vision: bool = Card in spectate_vision
		var level_visible_not_in_vision: bool = is_level_visible and !is_card_in_spectate_vision and !is_spectate_vision_empty and Card != SpectateObject
		Card.setLevelVisibleNotInVision(level_visible_not_in_vision)
			
func onVisionChanged() -> void:
	setLevelVisibleNotInVisionForSpectateObject()
#endregion
	
#region Active Effects
var current_active_effect: ActiveEffectDatastore
var current_active_effect_tiles: ActiveEffectTiles

func onActiveEffectBoxPressed(active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles) -> void:
	if current_active_effect != active_effect:
		if current_active_effect != null: onActiveEffectDeselected()
		current_active_effect = active_effect
		current_active_effect_tiles = active_effect_tiles
		onActiveEffectSelected()
	else:
		onActiveEffectDeselected()

func onActiveEffectSelected() -> void:
	onHideMovementRange()
	for Tile in current_active_effect_tiles.in_range_tiles:
		Tile.setInActiveEffectRange(true)
		
	for Tile in current_active_effect_tiles.pickable_tiles:
		Tile.setInActiveEffectPickable(true)
		
	if current_active_effect.camera_type == ActiveEffectDatastore.CameraTypes.CYCLE:
		var cards: Array = current_active_effect_tiles.pickable_tiles.map(func(x: TileGD): return Game.getFieldCard(x))
		CameraManager.setCycleObjects(cards)
	
	active_effect_selected.emit()
		
func onActiveEffectDeselected() -> void:
	if current_active_effect != null:
		for Tile in current_active_effect_tiles.in_range_tiles:
			Tile.setInActiveEffectRange(false)
			
		for Tile in current_active_effect_tiles.pickable_tiles:
			Tile.setInActiveEffectPickable(false)
			
		if current_active_effect.camera_type == ActiveEffectDatastore.CameraTypes.CYCLE:
			CameraManager.onRemoveCycleObjects()
			
		current_active_effect = null
		current_active_effect_tiles = null
		active_effect_deselected.emit()
		
func onActiveEffectActivated(Tile: TileGD) -> void:
	level.onPushAction(ActiveEffectUsedAction.new(current_active_effect, Tile, current_active_effect_tiles, level.getSpectateObject()))
	active_effect_activated.emit(current_active_effect)
	onActiveEffectDeselected()
	
func isActiveEffectCurrent() -> bool:
	return current_active_effect != null
#endregion

#region Pass
func onPassButtonPressed() -> void:
	onActiveEffectDeselected()
#endregion

#region Game Changers
func onGameEnded(_rewards: Rewards) -> void:
	CameraManager.onGameEnded()
	
func onGameStarted() -> void:
	CameraManager.onGameStarted()
#endregion

#region Environment
func setEnvironment() -> void:
	WorldEnv.environment = area.info.base_environment if level.fight_type == Game.FightTypes.REGULAR else area.info.elite_environment
#endregion

#region Dragged
func onCardDraggedBegin(_CardUI: Control) -> void:
	if level.getSpectateObject() is not SpawnGD:
		CameraManager.onSpectateSpawn(level.getAllySpectateObject())
		
func onCardDraggedEnd(Card: CardGD, _dragged_position: Vector2, CardUI: Control) -> void:
	var Tile: TileGD = getMouseHoverTile()
	if Tile != null and Tile.isAllySpawnTile() and !Tile.isOccupied() and !getMouseInUI():
		level.onAppendAction(PlayCardAction.new(Card, Tile))
		CardUI.queue_free()
#endregion
