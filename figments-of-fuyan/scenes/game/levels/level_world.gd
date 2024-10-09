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
	CameraManager.camera_position_updated.connect(onCameraPositionUpdated)
	
	UI.action_lock.connect(CameraManager.setActionLock)
	UI.action_lock.connect(onUpdateActionLock)
	UI.card_selected.connect(onCardSelected)
	UI.mouse_signal.connect(onMouseInUI)
	UI.camera_button_pressed.connect(CameraManager.onSwapCameraType)
	UI.camera_direction_changed.connect(CameraManager.onChangeCameraInDirection)
	
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
	for btn in get_tree().get_nodes_in_group("ActionLockDisabled"):
		if btn is Button: btn.disabled = state
		elif btn is HighlightTxButton: btn.setDisabled(state)
		
	if state: onHideMovementRange()
	
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
	var Tile: TileGD = MouseHoverTile
	if Tile.getMovementPathDisplay():
		var Card: CardGD = CameraManager.getCardSpectateObject()
		if Card != null:
			level.onAppendAction(MovementAction.new(Card, Tile))
	elif Tile.isOccupied() and Tile.isLevelVisible(): CameraManager.onSpectateCard(Tile.getCard())
	elif Tile.isAllySpawnTile() and !Tile.isOccupied():
		var HandCard: CardGD = UI.getSelectedCard()
		if HandCard != null:
			level.onAppendAction(PlayCardAction.new(HandCard, Tile))
	
func onTileInspected() -> void:
	var Tile: TileGD = MouseHoverTile
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
	else: onHideMovementRange()
		
func onCameraPositionUpdated(pos: Vector3) -> void:
	get_tree().call_group("FieldCardsGD", "onCameraPositionUpdated", pos)
#endregion
		
#region Movement Range
func onHideMovementRange() -> void:
	get_tree().call_group("LevelTilesGD", "setMovementPathDisplay", false)
	get_tree().call_group("FieldCardsGD", "setEnemyInMovementRange", false)

func onCreateMovementRange(Card: CardGD) -> void:
	onHideMovementRange()
	if Card == null or !Card.isAlly(): return
	
	var CenterTile: TileGD = Card.Tile
	var speed: int = min(Card.getMovementSpeed(), 5)
	var tiles: Array = Game.getAdjacentOrCloserTiles(Card.Tile, speed) # Gather all tiles
	
	var all_cards_tiles: Array = get_tree().get_nodes_in_group("FieldCardsGD").map(func(x: CardGD): return x.Tile)
	
	tiles = tiles.filter(func(x: TileGD): return !x.occupied_objects.any(func(y: ObjectGD): return y.isSolid()) and x not in all_cards_tiles) # Check for solidity
	for Tile in tiles:
		var astar := AStar3D.new()
		# Limits tiles to those in movement range
		var add_to_astar_tiles: Array = tiles.filter(func(x: TileGD): return Game.getCoordsDistance(Tile.getCoords(), x.getCoords()) <= speed)
		add_to_astar_tiles.append(CenterTile)
		for _Tile in add_to_astar_tiles: astar.add_point(_Tile.get_instance_id(), _Tile.getCoordsHeightless())
		
		for StartTile in add_to_astar_tiles:
			for EndTile in add_to_astar_tiles.filter(func(x: TileGD): return Game.isAdjacent(x, StartTile)):
				var height_diff: int = EndTile.getHeight() - StartTile.getHeight()
				if StartTile.isRamp():
					if StartTile.isValidRampRelation(EndTile):
						astar.connect_points(StartTile.get_instance_id(), EndTile.get_instance_id(), false)
					
				elif EndTile.isRamp():
					if EndTile.isValidRampRelation(StartTile):
						astar.connect_points(StartTile.get_instance_id(), EndTile.get_instance_id(), false)
					
				elif height_diff <= 1:
					astar.connect_points(StartTile.get_instance_id(), EndTile.get_instance_id(), false)
					
		var valid_path: bool = false
		var point_path: Array = []
		var movement_path: Array = []
		while(!valid_path):
			point_path = astar.get_id_path(CenterTile.get_instance_id(), Tile.get_instance_id())
			if point_path.is_empty(): break
			if point_path.size() > speed + 1:
				astar.disconnect_points(point_path[point_path.size() - 1], point_path[point_path.size() - 2])
				continue
			
			movement_path = point_path.map(func(x: int): return instance_from_id(x))
			if !onSurviveFallDamage(Card, movement_path, point_path, astar): continue
			valid_path = true
			
		if valid_path: Tile.setMovementPath(MovementPathGD.new(movement_path))
	
	var available_tiles: Array = tiles.filter(func(x: TileGD): return x.getMovementPathDisplay())
	available_tiles.append(CenterTile)
	
	var attackables: Array = Card.getAttackablesInRange()
	for GameObject in attackables:
		var coords: Vector4i = GameObject.getCoords()
		var tiles_in_range: Array = available_tiles.filter(func(x: TileGD): return Game.getCoordsDistance(x.getCoords(), GameObject.getCoords()) <= GameObject.getAttackRange())
		if !tiles_in_range.is_empty():
			var AttackableTile: TileGD
			if CenterTile not in tiles_in_range:
				tiles_in_range.sort_custom(func(x: TileGD, y: TileGD): return x.getMovementPathSize() < y.getMovementPathSize())
				AttackableTile = tiles_in_range[0]
			else: AttackableTile = CenterTile
				
			var attackable_path_tiles: Array =  AttackableTile.movement_path.tiles.duplicate() if AttackableTile != CenterTile else []
			if GameObject is CardGD:
				attackable_path_tiles.append(GameObject.Tile)
				GameObject.Tile.setMovementPath(MovementPathGD.new(attackable_path_tiles))
				GameObject.setEnemyInMovementRange(true)
	
func onSurviveFallDamage(Card: CardGD, movement_path: Array, point_path: Array, astar: AStar3D) -> bool:
	Card.temp_fall_damage = 0
	for i in range(1, movement_path.size()):
		var fall_damage: int = movement_path[i].getFallDamage(movement_path[i - 1])
		if fall_damage > 0:
			var survive_fall_damage: bool = Card.isCardSurviveFallDamage(fall_damage)
			if !survive_fall_damage and i != movement_path.size() - 1:
				astar.disconnect_points(point_path[i - 1], point_path[i])
				return false
	return true
#endregion

#region Movement
func onCardMoving(_Card: CardGD) -> void:
	onHideMovementRange()
	
func onCardFinishedMoving(Card: CardGD) -> void:
	onCreateMovementRange(Card)
#endregion
