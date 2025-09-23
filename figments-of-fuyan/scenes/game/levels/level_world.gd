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
	
	add_child(area.info.default_light.instantiate())
	
	level.phase_changed.connect(onPhaseChanged)
	level.awakened.connect(onCardAwakened)
	level.request_camera_data.connect(CameraManager.setCameraSaveables.bind(level))
	level.turn_state_changing.connect(onTurnStateChanging)
	level.camera_change_action.connect(onCameraChange)
	level.camera_change_pre.connect(onCameraChangePre)
	level.spectate_group.connect(CameraManager.onSpectateGroup)
	level.set_last_ally_spectate_object.connect(setLastAllySpectateObjectForLevel)
	level.request_camera_position_update.connect(onRequestCameraPositionUpdate)
	level.vision_changed.connect(onVisionChanged)
	level.load_env.connect(setEnvironment)
	
	CameraManager.camera_position_updated.connect(onCameraPositionUpdated)
	CameraManager.create_camera_action.connect(onCreateCameraChangeAction)
	CameraManager.camera_change_finish.connect(onCameraChangeFinish)
	CameraManager.setInfo(level.level_camera_data)
	
	UI.active_effect_pressed.connect(onActiveEffectPressed)
	UI.action_lock.connect(CameraManager.setActionLock)
	UI.action_lock.connect(onUpdateActionLock)
	UI.mouse_signal.connect(onMouseInUI)
	UI.camera_button_pressed.connect(CameraManager.onSwapCameraType)
	UI.camera_direction_changed.connect(CameraManager.onChangeCameraInDirection)
	UI.vision_mode_changed.connect(onVisionModeChanged)
	UI.create_movement_range.connect(onCreateMovementRange)
	
	UI.drag_end.connect(onCardDraggedEnd)
	area.process_action.connect(onProcessAction)
	
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
	
	if state: onHideMovementRange(); onActiveEffectDeselected()
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
		Game.Phases.START:
			onSpawnFX(true)
		Game.Phases.PLAYER:
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
#endregion

#region Tile Pressing
func onTilePressed() -> void:
	var Tile: TileGD = MouseHoverTile
	
	if Tile.isActiveEffectPickable() and ActiveEffectItem != null:
		onActiveEffectActivated(Tile)
	elif Tile.getMovementPathDisplay():
		var Card: CardGD = level.getAllySpectateObject()
		if Card != null:
			level.onPushAction(MovementAction.new(Card, Tile.getMovementPathTiles()))
	elif Tile.isOccupied() and Tile.isLevelVisible() and Tile.getCard().isLevelVisible():
		onCreateCameraChangeAction(Tile.getCard())
	elif Tile.getOccupiedObjects().any(func(x: ObjectGD): return x is SpawnGD and x.variation == 0) and Tile.isLevelVisible():
		onCreateCameraChangeAction(Tile.getOccupiedObjects().filter(func(x: ObjectGD): return x is SpawnGD and x.variation == 0)[0])
	
func onTileInspected() -> void:
	var Tile: TileGD = MouseHoverTile
	var Card: CardGD = Tile.getCard()
	if Card != null and Card.onCanCreateInspectScreen() and Card.isLevelVisible():
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
	
func onCameraChangeFinish(SpectateObject: GameObjectGD) -> void:
	UI.onCameraChangeFinish(SpectateObject)
	
func onCameraChangePre(_SpectateObject: GameObjectGD, _OldSpectateObject: GameObjectGD) -> void:
	if !CameraManager.isCycle():
		onActiveEffectDeselected()
	
func onCreateCameraChangeAction(SpectateObject: GameObjectGD) -> void:
	if level.is_ended: return
	level.onPushAction(CameraChangeAction.new(SpectateObject))
#endregion
		
#region Movement Range
func onHideMovementRange() -> void:
	if get_tree() == null: return
	get_tree().call_group("LevelTilesGD", "setMovementPathDisplay", false)
	get_tree().call_group("FieldCardsGD", "setEnemyInMovementRange", false)
	
func onCreateMovementRange(Card: CardGD) -> void:
	if level.phase == Game.Phases.PLAYER:
		if Card == null or !Card.isAlly() or Card.turn_state == Game.TurnStates.PASSED or ActiveEffectItem != null: return
		Card.getsetMovementRange()
#endregion

#region Turn State
func onTurnStateChanging(Card: CardGD, action: ChangeTurnStateAction) -> void:
	if !getActionLock() and Card.isAlly(0) and Card.turn_state == Game.TurnStates.PASSED and !isActionTiedToAwakenAction(action):
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
var ActiveEffectItem: Variant
var current_active_effect_tiles: ActiveEffectTiles

func onActiveEffectPressed(item: Variant, active_effect_tiles: ActiveEffectTiles) -> void:
	if (item is not ActiveIObjects and item != ActiveEffectItem) or (item is ActiveIObjects and (ActiveEffectItem == null or ActiveEffectItem is not ActiveIObjects)):
		if ActiveEffectItem != null: onActiveEffectDeselected()
		ActiveEffectItem = item
		current_active_effect_tiles = active_effect_tiles
		onActiveEffectSelected()
	else: onActiveEffectDeselected()

func onActiveEffectSelected() -> void:
	onHideMovementRange()
	for Tile in current_active_effect_tiles.in_range_tiles:
		Tile.setInActiveEffectRange(true)
		
	for Tile in current_active_effect_tiles.pickable_tiles:
		Tile.setInActiveEffectPickable(true)
	
	active_effect_selected.emit()
		
func onActiveEffectDeselected() -> void:
	if ActiveEffectItem != null:
		for Tile in current_active_effect_tiles.in_range_tiles:
			Tile.setInActiveEffectRange(false)
			
		for Tile in current_active_effect_tiles.pickable_tiles:
			Tile.setInActiveEffectPickable(false)
			
		ActiveEffectItem = null
		current_active_effect_tiles = null
		active_effect_deselected.emit()
		onCreateMovementRange(level.getAllySpectateObject())
	
func onActiveEffectActivated(Tile: TileGD) -> void:
	var _ActiveEffectItem: Variant = ActiveEffectItem
	var _current_active_effect_tiles: ActiveEffectTiles = current_active_effect_tiles
	var Card: CardGD = null
	if ActiveEffectItem is ActiveIObjects:
		_ActiveEffectItem = ActiveEffectItem.getIObjectFromTile(Tile)
		_current_active_effect_tiles = ActiveEffectItem.getActiveEffectTilesFromTile(Tile)
		Card = ActiveEffectItem.getCard()
	level.onPushAction(ActiveEffectUsedAction.new(_ActiveEffectItem, Tile, _current_active_effect_tiles, Card))
	onActiveEffectDeselected()
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
func setEnvironment(env: Environment = null) -> void:
	if env == null:
		if level.fight_type in [Game.FightTypes.MINIBOSS, Game.FightTypes.BOSS]:
			var BossCard: EpicCardGD = level.getBoss()
			if BossCard != null:
				env = BossCard.getEnvironmentFromInfo()
			
		if env == null: # If doesn't find boss card / doesn't have a set environment
			env = area.info.base_environment
	WorldEnv.environment = env
#endregion

#region Dragged
func onCardDraggedEnd(CardUI: Control) -> void:
	var Tile: TileGD = getMouseHoverTile()
	if Tile != null and Tile.isAllySpawnTile() and !Tile.isOccupied():
		level.onAppendAction(PlayCardAction.new(CardUI.Card, Tile))
		CardUI.queue_free()
#endregion

func onProcessAction(action: Action) -> void:
	if action.post:
		if action is ChangeEnvironmentAction:
			onChangeEnvironment(action)
		elif action is StartLevelAction:
			onGameStarted()
			
func onChangeEnvironment(action: ChangeEnvironmentAction) -> void:
	setEnvironment(action.environment)
	
func onMinimapCreated() -> void:
	visible = false
	CameraManager.setCurrent(false)
	
func onMinimapExited() -> void:
	visible = true
	CameraManager.setCurrent(true)
	
	var ChampionCard: CardGD = Game.getSaveFile().getChampionCard()
	ChampionCard.onRemoveModel()
	if !ChampionCard.is_in_group("FieldCardsGD"): return
	
	ChampionCard.onCreateModel()
	ChampionCard.onIdle()
	ChampionCard.position = ChampionCard.getTile().getCardPosition()
	ChampionCard.onCreateFieldInfo()
