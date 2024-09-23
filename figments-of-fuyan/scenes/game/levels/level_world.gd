extends Node3D

#region Exports
@export var SpawnParticlePacked: PackedScene
#endregion

#region Globals
signal push_action
signal append_action

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
	CameraManager.setInfo(level.level_camera_data)
	UI.action_lock.connect(CameraManager.setActionLock)
	UI.action_lock.connect(onUpdateActionLock)
	UI.card_selected.connect(onCardSelected)
	UI.mouse_signal.connect(onMouseInUI)
	UI.camera_direction_changed.connect(CameraManager.onChangeCameraInDirection)
	
	push_action.connect(Game.ActionManagerReference.onPushAction)
	append_action.connect(Game.ActionManagerReference.onAppendAction)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		onUpdateMousePosition()
	
	if Input.is_action_just_pressed("MainInput") and HoverTile != null: onTilePressed()
	
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
	
func onUpdateActionLock(_state: bool) -> void:
	onHoverTile()
	
func getMouseInUI() -> bool:
	return UI.mouse_in_ui
	
func onMouseInUI(state: bool) -> void:
	onHoverTile()
	
var camera_panning: bool
func _on_free_look_camera_camera_panning(state: bool) -> void:
	camera_panning = state
	onHoverTile()
#endregion
	
#region Phases
func onPhaseChanged(phase: Game.Phases, _instant: bool = false) -> void:
	match phase:
		Game.Phases.START: CameraManager.onSpectateSpawn(); onSpawnFX(true)
		Game.Phases.HAND: onSpawnFX(true)
		_: onSpawnFX(false); CameraManager.onSpectateAllies()
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
			append_action.emit(PlayCardAction.new(HandCard, Tile))
#endregion
