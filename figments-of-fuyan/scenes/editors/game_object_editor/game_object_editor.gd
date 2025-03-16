extends Node

#region Exports
@export var MAX_LEVEL_SIZE: int = 10
@export var MAX_ELEVATION: int = 10
@export var SCROLL_DELAY: float = 0.2
#endregion
#region Globals
var all_tile_objects: Array = []
var all_card_objects: Array = []
var all_game_objects: Array = []
@onready var World: Node3D = $World
@onready var GameObjectsContainer: VBoxContainer = %GameObjectsContainer
@onready var Camera: Camera3D = %Camera
@onready var ScrollCont: ScrollContainer = %ScrollContainer
#endregion
#region Helper

func onConvertCoords(coords: Vector4i) -> Vector3:
	return Vector3((sqrt(3) * coords.x + sqrt(3) * coords.y * 0.5), coords.w * 0.6, coords.y * (3 / 2.0))

@onready var TileRay: RayCast3D = %TileRay
func onFindMouseTileObject() -> TileGD:
	Helper.setCameraRay(TileRay, Camera)
	return Helper.getCollision(TileRay.get_collider(), TileGD)
	
func onFindTile(coords: Vector4i) -> TileGD:
	for Tile in get_tree().get_nodes_in_group("TilesGD"):
		if Tile.getCoords() == coords: return Tile
	return null
	
func onFindTileObjectInfo(id: int) -> TileObjectInfo:
	return all_tile_objects.filter(func(x: TileObjectInfo): return x.id == id)[0]
#endregion
#region Base Functions
func _ready() -> void:
	all_tile_objects = Helper.getFofInfoArray(TileObjectInfo)
	all_tile_objects.sort_custom(func(x: TileObjectInfo, y: TileObjectInfo): return x.id < y.id)
	
	all_card_objects = Helper.getFofInfoArray(CardInfo)
	all_card_objects = all_card_objects.filter(func(x: CardInfo): return x.id < 100)
	all_card_objects.sort_custom(func(x: CardInfo, y: CardInfo): return x.id < y.id)
	
	all_game_objects = all_tile_objects + all_card_objects
	
	for info in all_game_objects:
		var button := Button.new()
		button.text = info.name
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.mouse_entered.connect(onMouseInUI.bind(true))
		button.mouse_exited.connect(onMouseInUI.bind(false))
		
		var data: SavedData = info.saved_data.new(info.id)
		if info is TileInfo: button.theme_type_variation = "BlueButton"
		elif info is CardInfo: button.theme_type_variation = "YellowButton"
			
		button.pressed.connect(onGameObjectInfoSelected.bind(data))
		GameObjectsContainer.add_child(button)
	onGameObjectInfoSelected(getGameObjectData(all_game_objects[0]))
	ScrollCont.get_v_scroll_bar().mouse_entered.connect(onMouseInUI.bind(true))
	ScrollCont.get_v_scroll_bar().mouse_exited.connect(onMouseInUI.bind(false))
	
func getGameObjectData(info: Variant) -> SavedData:
	if info is TileInfo: return SavedDataTile.new(info.id)
	elif info is ObjectInfo: return SavedDataObject.new(info.id)
	elif info is CardInfo: return SavedDataCard.new(info.id)
	return null

func _process(_delta: float) -> void:
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
func onGameObjectInfoSelected(data: SavedData) -> void:
	get_tree().call_group("GameObjectsGD", "queue_free")
	
	SelectedModel = SavedData.onLoadModel(data, World)
	if SelectedModel is CardGD:
		SelectedModel.onCreateModel()
		SelectedModel.getModel().rotation.y = 0
	
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
	if SelectedModel is not CardGD and !is_scroll_disabled and !mouse_in_ui:
		SelectedModel.clampVariation(direction)
		onGameObjectInfoSelected(SelectedModel.onSave())
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
	EditTileCoords.disabled = SelectedModel is not ObjectGD
	if EditTileCoords.button_pressed:
		if EditTileCoords.disabled: onDisableEditTileCoords()
		else: onEnableEditTileCoords()

func onDisableEditTileCoords() -> void:
	get_tree().call_group("TileStaticBody", "queue_free")
	get_tree().call_group("TilesGD", "queue_free")
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
		var Tile: TileGD = SavedData.onLoadModel(SavedDataTile.new(1, false, 0, HoverStaticBody.coords), World)
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
