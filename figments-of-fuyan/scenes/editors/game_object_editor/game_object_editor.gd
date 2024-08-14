extends Node

#region Exports
@export var MAX_LEVEL_SIZE: int = 10
@export var MAX_ELEVATION: int = 10
@export var SCROLL_DELAY: float = 0.2
@export var TILE_OBJECTS_PATH: String = "res://resources/game/tile_object/info/"
#endregion
#region Globals
var all_tile_objects: Array = []
var all_game_objects: Array = []
@onready var World: Node3D = $World
@onready var GameObjectsContainer: VBoxContainer = %GameObjectsContainer
@onready var Camera: Camera3D = %Camera
#endregion
#region Helper

func onConvertCoords(coords: Vector4i) -> Vector3:
	return Vector3((sqrt(3) * coords.x + sqrt(3) * coords.y * 0.5), coords.w * 0.6, coords.y * (3 / 2.0))

@onready var TileRay: RayCast3D = %TileRay
func onFindMouseTileObject() -> TileGD:
	Helper.setCameraRay(TileRay, Camera)
	return Helper.getCollision(TileRay.get_collider(), TileGD)
	
func onFindTile(coords: Vector4i) -> TileGD:
	for Tile in get_tree().get_nodes_in_group("Tiles"):
		if Tile.getCoords() == coords: return Tile
	return null
	
func onFindTileObjectInfo(id: int) -> TileObjectInfoGD:
	return all_tile_objects.filter(func(x: TileObjectInfoGD): return x.id == id)[0]
#endregion
#region Base Functions
func _ready() -> void:
	all_tile_objects = Helper.getResourcesRecursive(TILE_OBJECTS_PATH, TileObjectInfoGD)
	all_tile_objects.sort_custom(func(x: TileObjectInfoGD, y: TileObjectInfoGD): return x.id < y.id)
	
	all_game_objects = all_tile_objects
	
	for info in all_game_objects:
		var button := Button.new()
		button.text = info.name
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.mouse_entered.connect(onMouseInUI.bind(true))
		button.mouse_exited.connect(onMouseInUI.bind(false))
		button.pressed.connect(onGameObjectInfoSelected.bind(info))
		GameObjectsContainer.add_child(button)
	onGameObjectInfoSelected(all_game_objects[0])
	
func _input(_event: InputEvent) -> void:
	if !is_camera_panning:
		if Input.is_action_just_pressed("ChangeVariationDown"):
			onChangeVariation(-1)
		elif Input.is_action_just_pressed("ChangeVariationUp"):
			onChangeVariation(1)
		elif Input.is_action_just_pressed("MainInput"):
			if !edit_tile_coords: onCreateRay()
			else:
				if HoverStaticBody != null: onPlaceTile()
		elif Input.is_action_just_pressed("Delete"):
			if edit_tile_coords: onDeleteTile()
		elif Input.is_action_just_pressed("ChangeElevationUp"):
			setBaseElevation(base_elevation + 1)
		elif Input.is_action_just_pressed("ChangeElevationDown"):
			setBaseElevation(base_elevation - 1)
		else:
			for num in range(10):
				if Input.is_action_just_pressed("ChangeElevation" + str(num)):
					if num == 0: num = 9
					else: num -= 1
					setBaseElevation(num)
					
	if Input.is_action_just_pressed("EditTileCoords"):
		if !EditTileCoords.disabled:
			EditTileCoords.button_pressed = !EditTileCoords.button_pressed
#endregion
#region Selecting Info
var SelectedModel: GameObjectGD
func onGameObjectInfoSelected(info: GameObjectInfoGD, data: GameObjectDataGD = info.createData()) -> void:
	if SelectedModel != null: SelectedModel.queue_free()
	get_tree().call_group("Tiles", "queue_free")
	SelectedModel = data.onLoad(World, info)
	onLoadPoints()
	onUpdateEditTileCoordsEnabled()
	
func onLoadPoints() -> void:
	if !edit_tile_coords:
		get_tree().call_group("Points", "queue_free")
		SelectedModel.onLoadPoints(World)
#endregion
#region Variations
var is_scroll_disabled: bool = false
func onChangeVariation(direction: int) -> void:
	if !is_scroll_disabled:
		SelectedModel.clampVariation(direction)
		onGameObjectInfoSelected(SelectedModel.info, SelectedModel.data)
		onDisableScroll()
	
func onDisableScroll() -> void:
	is_scroll_disabled = true
	await get_tree().create_timer(SCROLL_DELAY).timeout
	is_scroll_disabled = false
#endregion
#region Creating Points
@onready var Ray: RayCast3D = %Ray
func onCreateRay() -> void:
	Helper.setCameraRay(Ray, Camera)
	if Ray.is_colliding():
		if Ray.get_collider().name == "PointBody": Ray.get_collider().get_parent()._queue_free()
		else:
			var collision: GameObjectGD = Helper.getCollision(Ray.get_collider(), GameObjectGD)
			collision.onCreatePoint(World, Ray.get_collision_point())
			
#endregion
#region Camera
var is_camera_panning: bool = false
func _on_camera_camera_panning(state: bool):
	is_camera_panning = state
#endregion
#region Tile Coords
@onready var EditTileCoords: CheckBox = %EditTileCoords
var edit_tile_coords: bool = false
func onUpdateEditTileCoordsEnabled() -> void:
	EditTileCoords.disabled = !(SelectedModel is ObjectGD)
	if EditTileCoords.button_pressed:
		if EditTileCoords.disabled: onDisableEditTileCoords()
		else: onEnableEditTileCoords()

func onDisableEditTileCoords() -> void:
	get_tree().call_group("TileStaticBody", "queue_free")
	get_tree().call_group("Tiles", "queue_free")
	edit_tile_coords = false
	EditTileCoords.set_pressed_no_signal(false)
	onLoadPoints()
	
func onEditTileCoordsPressed(state: bool) -> void:
	if !state: onDisableEditTileCoords()
	else: onEnableEditTileCoords()
	
func onEnableEditTileCoords() -> void:
	edit_tile_coords = true
	get_tree().call_group("Points", "queue_free")
	get_tree().call_group("Tiles", "queue_free")
	SelectedModel.onLoadTilesCoords(World, onFindTileObjectInfo(1))
	onCreateTileStaticBodies()
#endregion
#region Elevation
@onready var BaseElevationLabel: Label = %BaseElevationLabel
@export var tile_static_body: PackedScene
var base_elevation: int = 0
func onCreateTileStaticBodies() -> void:
	get_tree().call_group("TileStaticBody", "queue_free")
	for x in range(-MAX_LEVEL_SIZE, (MAX_LEVEL_SIZE + 1)):
		for y in range(max(-MAX_LEVEL_SIZE, -x - MAX_LEVEL_SIZE), min(MAX_LEVEL_SIZE, -x + MAX_LEVEL_SIZE) + 1):
				var coords := Vector4i(x, y, -x-y, base_elevation)
				onPlaceTileStaticBody(coords)
			
func onPlaceTileStaticBody(coords: Vector4i) -> void:
	var TileStaticBody: StaticBody3D = tile_static_body.instantiate()
	TileStaticBody.position = onConvertCoords(coords)
	TileStaticBody.coords = coords
	TileStaticBody.mouse_exited.connect(onMouseExitTileStaticBody)
	TileStaticBody.mouse_entered.connect(onMouseEnterTileStaticBody.bind(TileStaticBody))
	add_child(TileStaticBody)
	
func setBaseElevation(_base_elevation: int) -> void:
	if _base_elevation != base_elevation:
		base_elevation = clamp(_base_elevation, 0, MAX_ELEVATION)
		BaseElevationLabel.text = "Elevation: " + str(base_elevation)
		get_tree().call_group("TileStaticBody", "queue_free")
		onCreateTileStaticBodies()
#endregion
#region Hovering & Placing Tiles
var HoverStaticBody: Node3D
func onMouseExitTileStaticBody() -> void:
	HoverStaticBody = null

func onMouseEnterTileStaticBody(_HoverStaticBody: StaticBody3D) -> void:
	HoverStaticBody = _HoverStaticBody
	
func onPlaceTile() -> void:
	if !onFindTile(HoverStaticBody.coords) and !mouse_in_ui:
		var info: TileInfoGD = onFindTileObjectInfo(1)
		var data: TileDataGD = info.createData()
		var Tile: TileGD = data.onLoad(World, info)
		
		Tile.setRayPickable(false)
		Tile.setPosition(HoverStaticBody.coords)
		Tile.setHalfTransparent()
		SelectedModel.onSaveTile(Tile.getCoords())
#endregion
#region Deleting
func onDeleteTile(Tile: TileGD = onFindMouseTileObject()) -> void:
	if Tile != null:
		Tile.queue_free()
		SelectedModel.onDeleteTile(Tile.getCoords())
#endregion
#region Mouse in ui
var mouse_in_ui: bool = false
func onMouseInUI(state: bool) -> void:
	mouse_in_ui = state
#endregion
