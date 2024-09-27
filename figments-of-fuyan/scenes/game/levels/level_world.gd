extends Node3D

#region Exports
@export var SpawnParticlePacked: PackedScene
#endregion

#region Globals
signal camera_updated

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
	level.card_moving.connect(onCardMoving)
	level.card_finished_moving.connect(onCardFinishedMoving)
	CameraManager.setInfo(level.level_camera_data)
	CameraManager.camera_updated.connect(onCameraUpdated)
	UI.action_lock.connect(CameraManager.setActionLock)
	UI.action_lock.connect(onUpdateActionLock)
	UI.card_selected.connect(onCardSelected)
	UI.mouse_signal.connect(onMouseInUI)
	UI.camera_button_pressed.connect(CameraManager.onSwapCameraType)
	UI.camera_direction_changed.connect(CameraManager.onChangeCameraInDirection)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		onUpdateMousePosition()
	
	if HoverTile != null:
		if Input.is_action_just_pressed("MainInput"): onTilePressed()
		elif Input.is_action_just_pressed("InspectCard"): onTileInspected()
	
#endregion

#region Hover Tile
@onready var MouseRaycast: RayCast3D = %MouseRaycast
const RAY_LENGTH: int = 5000
var MouseHoverTile: TileGD # Ignores action lock
var HoverTile: TileGD # Doesn't ignore action lock

func onUpdateMousePosition() -> void:
	setMouseHoverTile()
	onHoverTile()

func onHoverTile(disable: bool = false) -> void:
	if !getActionLock() and !getMouseInUI() and !camera_panning:
		if MouseHoverTile != null: MouseHoverTile.onHovered(true); HoverTile = MouseHoverTile
		return
	if MouseHoverTile != null: MouseHoverTile.onHovered(false); HoverTile = null

func setMouseHoverTile() -> void:
	var to: Vector3 = CameraManager.CurrentCamera.project_ray_normal(get_viewport().get_mouse_position()) * RAY_LENGTH
	
	MouseRaycast.position = CameraManager.CurrentCamera.position
	MouseRaycast.target_position = to
	MouseRaycast.force_raycast_update()
	
	if MouseRaycast.is_colliding():
		if MouseHoverTile != null: MouseHoverTile.onHovered(false)
		MouseHoverTile = Helper.getCollision(MouseRaycast.get_collider(), TileGD)
		return
	MouseHoverTile = null
#endregion

#region Action Lock / Mouse in UI
func getActionLock() -> bool:
	return UI.getActionLock()
	
func onUpdateActionLock(state: bool) -> void:
	onHoverTile()
	for btn in get_tree().get_nodes_in_group("ActionLockDisabled"):
		if btn is Button: btn.disabled = state
		elif btn is HighlightTxButton: btn.setDisabled(state)
		
	if state: onRemoveMovementRange()
	
func getMouseInUI() -> bool:
	return UI.mouse_in_ui
	
func onMouseInUI(state: bool) -> void:
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
		Game.Phases.HAND: onSpawnFX(true)
		Game.Phases.PLAYER:
			onSpawnFX(false)
			CameraManager.onSpectateAllies()
			onCreateMovementRange(CameraManager.getCardSpectateObject())
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
	CameraManager.onSpectateCard(Card)
#endregion

#region Tile Pressing
func onTilePressed() -> void:
	var Tile: TileGD = HoverTile
	if Tile.isAllySpawnTile() and !Tile.isOccupied():
		var HandCard: CardGD = UI.getSelectedCard()
		if HandCard != null:
			level.onAppendAction(PlayCardAction.new(HandCard, Tile))
	elif Tile.isOccupied() and Tile.isLevelVisible(): CameraManager.onSpectateCard(Tile.getCard())
	elif Tile.is_movement_range:
		var Card: CardGD = CameraManager.getCardSpectateObject()
		if Card != null:
			level.onAppendAction(MovementAction.new(Card, Tile))
	
func onTileInspected() -> void:
	var Tile: TileGD = HoverTile
	var Card: CardGD = Tile.getCard()
	if Card != null:
		Card.setInspectable(true, UI)
		Card.onInspectCard()
#endregion

#region Camera
func onCameraUpdated(SpectateObject: Variant, OldSpectateObject: Variant) -> void:
	camera_updated.emit(SpectateObject, OldSpectateObject)
	
	if OldSpectateObject is CardGD: OldSpectateObject.onSpectated(false)
	if SpectateObject is CardGD: SpectateObject.onSpectated(true)
	
	if SpectateObject is CardGD and SpectateObject.isAlly() and SpectateObject.turn_state == Game.TurnStates.INACTIVE and level.phase == Game.Phases.PLAYER and !getActionLock():
		onCreateMovementRange(SpectateObject)
		
#endregion
		
#region Movement Range
func onRemoveMovementRange() -> void:
	get_tree().call_group("LevelTilesGD", "onRemoveMovementRange")

func onCreateMovementRange(Card: CardGD) -> void:
	onRemoveMovementRange()
	if Card == null or !Card.isAlly(): return
	
	var CenterTile: TileGD = Card.Tile
	var speed: int = Card.getMovementSpeed()
	var tiles: Array = Game.getAdjacentOrCloserTiles(Card.Tile, speed) # Gather all tiles
	tiles = tiles.filter(func(x: TileGD): return !x.occupied_objects.any(func(y: ObjectGD): return y.isSolid())) # Check for solidity
	
	for Tile in tiles:
		var astar := AStar3D.new()
		# Limits tiles to those in movement range
		var add_to_astar_tiles: Array = tiles.filter(func(x: TileGD): return Game.getCoordsDistance(Tile.getCoords(), x.getCoords()) <= speed)
		add_to_astar_tiles.append(CenterTile)
		for _Tile in add_to_astar_tiles: astar.add_point(_Tile.get_instance_id(), _Tile.getCoordsHeightless())
		
		for StartTile in add_to_astar_tiles:
			for EndTile in add_to_astar_tiles.filter(func(x: TileGD): return Game.isAdjacent(x, StartTile)):
				var height_diff: int = StartTile.getHeight() - EndTile.getHeight()
				if StartTile.variation == 1:
					if StartTile.isValidRampRelation(EndTile):
						astar.connect_points(StartTile.get_instance_id(), EndTile.get_instance_id(), false)
					
				elif EndTile.variation == 1:
					if EndTile.isValidRampRelation(StartTile):
						astar.connect_points(StartTile.get_instance_id(), EndTile.get_instance_id(), false)
					
				elif abs(height_diff) <= 1:
					astar.connect_points(StartTile.get_instance_id(), EndTile.get_instance_id(), false)
					
		var point_path: Array = astar.get_id_path(CenterTile.get_instance_id(), Tile.get_instance_id())
		Tile.movement_path = point_path.map(func(x: int): return instance_from_id(x))
		
		if !point_path.is_empty(): Tile.setMovementRange(true)
	
#endregion

#region Movement
func onCardMoving(_Card: CardGD) -> void:
	onRemoveMovementRange()
	
func onCardFinishedMoving(Card: CardGD) -> void:
	onCreateMovementRange(Card)
#endregion
