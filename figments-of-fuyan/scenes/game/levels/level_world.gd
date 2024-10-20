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

#region Onready
@onready var CameraManager: Node3D = %CameraManager
#endregion

#region Base Functions
func _ready() -> void:
	CameraManager.setCameraType(false)
	
func setInfo(_save_file: SaveFileGD) -> void:
	save_file = _save_file
	area = save_file.area
	level = area.active_level
	
	level.phase_changed.connect(onPhaseChanged)
	level.awakened.connect(onCardAwakened)
	level.request_camera_data.connect(CameraManager.setCameraSaveables.bind(level))
	level.turn_state_changing.connect(onTurnStateChanging)
	level.camera_change_action.connect(onCameraChange)
	
	CameraManager.camera_position_updated.connect(onCameraPositionUpdated)
	CameraManager.create_camera_action.connect(onCreateCameraChangeAction)
	CameraManager.setInfo(level.level_camera_data)
	
	UI.action_lock.connect(CameraManager.setActionLock)
	UI.action_lock.connect(onUpdateActionLock)
	UI.card_selected.connect(onCardSelected)
	UI.mouse_signal.connect(onMouseInUI)
	UI.camera_button_pressed.connect(CameraManager.onSwapCameraType)
	UI.camera_direction_changed.connect(CameraManager.onChangeCameraInDirection)
	UI.vision_mode_changed.connect(onVisionModeChanged)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		onUpdateMousePosition()
	
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
	var to: Vector3 = CameraManager.CurrentCamera.project_ray_normal(get_viewport().get_mouse_position()) * RAY_LENGTH
	
	MouseRaycast.position = CameraManager.CurrentCamera.position
	MouseRaycast.target_position = to
	MouseRaycast.force_raycast_update()
	
	if MouseRaycast.is_colliding():
		return Helper.getCollision(MouseRaycast.get_collider(), TileGD)
	return null
#endregion

#region Action Lock / Mouse in UI
func getActionLock() -> bool:
	return UI.getActionLock()
	
func onUpdateActionLock(state: bool) -> void:
	onHoverTile()
	
	if state: onHideMovementRange()
	else: onCreateMovementRange(level.getAllySpectateObject())
	
func getMouseInUI() -> bool:
	return mouse_in_ui
	
var mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	mouse_in_ui = state
	onHoverTile()
	
var camera_panning: bool
func onCameraPanning(state: bool) -> void:
	camera_panning = state
	onHoverTile()
#endregion
	
#region Phases
func onPhaseChanged(phase: Game.Phases, _instant: bool = false) -> void:
	match phase:
		Game.Phases.START: CameraManager.onSpectateSpawn(); onSpawnFX(true)
		Game.Phases.HAND: CameraManager.onSpectateAllies(); onSpawnFX(true)
		Game.Phases.PLAYER:
			onSpawnFX(false)
			CameraManager.onSpectateAllies()
#endregion
	
#region SpawnFX
func onSpawnFX(state: bool) -> void:
	get_tree().call_group("SpawnParticles", "queue_free")
	if state:
		for Obj in get_tree().get_nodes_in_group("AllySpawnsGD"):
			for Tile in Obj.occupied_tiles.filter(func(x: TileGD): return !x.isOccupied()):
				var SpawnParticle: GPUParticles3D = SpawnParticlePacked.instantiate()
				SpawnParticle.position = Tile.position
				add_child(SpawnParticle)
#endregion

#region Card Selected
func onCardSelected(selected: bool) -> void:
	if selected: CameraManager.onSpectateSpawn()
	else: CameraManager.onSpectateAllies()
#endregion

#region Awakening
func onCardAwakened(Card: CardGD) -> void:
	onSpawnFX(true)
	onCreateCameraChangeAction(Card)
#endregion

#region Tile Pressing
func onTilePressed() -> void:
	var Tile: TileGD = MouseHoverTile
	if Tile.getMovementPathDisplay():
		var Card: CardGD = level.getAllySpectateObject()
		if Card != null:
			level.onAppendAction(MovementAction.new(Card, Tile))
	elif Tile.isOccupied() and Tile.isLevelVisible(): onCreateCameraChangeAction(Tile.getCard())
	elif Tile.isAllySpawnTile() and !Tile.isOccupied():
		var HandCard: CardGD = UI.getSelectedCard()
		if HandCard != null:
			level.onAppendAction(PlayCardAction.new(HandCard, Tile))
	
func onTileInspected() -> void:
	var Tile: TileGD = MouseHoverTile
	var Card: CardGD = Tile.getCard()
	if Card != null and Card.level_visible:
		Card.setInspectable(true, UI)
		Card.onInspectCard()
#endregion

#region Camera
func onCameraPositionUpdated(pos: Vector3) -> void:
	get_tree().call_group("FieldCardsGD", "onCameraPositionUpdated", pos)
	
func onCameraChange(SpectateObject: GameObjectGD, OldSpectateObject: GameObjectGD) -> void:
	if OldSpectateObject is CardGD: OldSpectateObject.onSpectated(false)
	if SpectateObject is CardGD: SpectateObject.onSpectated(true)
	CameraManager.onCameraChange(SpectateObject)
	
func onCreateCameraChangeAction(SpectateObject: GameObjectGD) -> void:
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
	if Card == null or !Card.isAlly(): return
	
	Game.getsetMovementRange(Card)
#endregion

#region Turn State
func onTurnStateChanging(Card: CardGD) -> void:
	if Card.isAlly(0) and Card.turn_state == Game.TurnStates.PASSED:
		var ally_cards: Array = Game.getAllyUnits(0).filter(func(x: CardGD): return x.turn_state == Game.TurnStates.INACTIVE)
		if ally_cards.is_empty(): return
		ally_cards.sort_custom(func(x: CardGD, y: CardGD): return Game.getCoordsDistance(x.getCoords(), Card.getCoords()) < Game.getCoordsDistance(y.getCoords(), Card.getCoords()))
		onCreateCameraChangeAction(ally_cards[0])
#endregion

#region Vision Mode
var original_vision: Dictionary
var in_vision_mode: bool
func onVisionModeChanged(state: bool) -> void:
	in_vision_mode = state
	LastCardVisionMode = null
	previous_vision = {}
	
	if state:
		for GameObject in get_tree().get_nodes_in_group("LevelTileObjectsGD") + get_tree().get_nodes_in_group("FieldCardsGD"):
			var level_visible: bool = GameObject.getLevelVisible()
			original_vision[GameObject] = level_visible
			GameObject.setLevelVisible(false if GameObject is not CardGD else level_visible)
	elif !state:
		for GameObject in original_vision:
			GameObject.setLevelVisible(original_vision[GameObject])
	
var LastCardVisionMode: CardGD
var previous_vision: Dictionary
func onVisionModeTileHovered(Tile: TileGD) -> void:
	if LastCardVisionMode != null and Tile != LastCardVisionMode.Tile:
		LastCardVisionMode = null
		for GameObject in previous_vision:
			GameObject.setLevelVisible(previous_vision[GameObject])
		previous_vision = {}
		
	if Tile == null: return
	var Card: CardGD = Game.getFieldCard(Tile)
	if Card == null or !Card.getLevelVisible(): return
		
	var ally_vision: Array = Game.getTeamVision(0)
	LastCardVisionMode = Card
	for GameObject in LastCardVisionMode.getVisibleGameObjects():
		if GameObject in ally_vision:
			previous_vision[GameObject] = GameObject.getLevelVisible()
			GameObject.setLevelVisible(true)
#endregion
	
