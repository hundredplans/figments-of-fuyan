extends Node

@onready var UI: Control = $UI
@onready var World: Node3D = %World
@onready var Camera: Camera3D = %Camera3D

@export var DEFAULT_LEVEL_SIZE: int = 5
@export var MAX_ELEVATION: int = 10
@export var MAX_LEVEL_SIZE: int = 30
@export var SCROLL_DELAY: float = 0.2
@export var ROTATION_LOCK_DELAY: float = 0.15
const TILE_OBJECTS_PATH: String = "res://resources/game/tile_object/info/"

var is_camera_panning: bool = false

var all_tile_objects: Array
var base_elevation: int = -1

var HoverStaticBody: StaticBody3D
var HoverModel: TileObjectGD

#region Helper Functions
func onConvertCoords(coords: Vector4i) -> Vector3:
	return Vector3((sqrt(3) * coords.x + sqrt(3) * coords.y * 0.5), coords.w * 0.6, coords.y * (3 / 2.0))
	
func onFindTile(coords: Vector4i) -> TileGD:
	for Tile in get_tree().get_nodes_in_group("Tiles"):
		if Tile != HoverModel and Tile.getCoords() == coords: return Tile
	return null
	
const RAY_LENGTH: int = 5000
@onready var TileObjectRay: RayCast3D = %TileObjectRay
func onFindMouseTileObject() -> TileObjectGD:
	TileObjectRay.position = Camera.position
	TileObjectRay.target_position = Camera.project_ray_normal(get_viewport().get_mouse_position()) * RAY_LENGTH
	TileObjectRay.force_raycast_update()
	return Helper.getCollision(TileObjectRay.get_collider(), TileObjectGD)

func onFindMousePoint() -> Vector3:
	TileObjectRay.position = Camera.position
	TileObjectRay.target_position = Camera.project_ray_normal(get_viewport().get_mouse_position()) * RAY_LENGTH
	TileObjectRay.force_raycast_update()
	if TileObjectRay.is_colliding(): return TileObjectRay.get_collision_point()
	return Vector3.ZERO

func onFindMouseTile() -> TileGD:
	var TileObject: TileObjectGD = onFindMouseTileObject()
	if TileObject != null and TileObject is TileGD: return TileObject
	return null

func getTilesBelow(Tile: TileGD) -> Array[TileGD]:
	var arr: Array[TileGD] = []
	var coords: Vector4i = Tile.getCoords()
	for w in range(Tile.getHeight() - 1, -1, -1):
		coords.w = w
		var _Tile: TileGD = onFindTile(coords)
		if _Tile != null: arr.append(_Tile)
	return arr

#endregion
#region Base Functions
func _ready() -> void:
	setBaseElevation(0)
	all_tile_objects = Array(DirAccess.get_files_at(TILE_OBJECTS_PATH)).\
		filter(func(x: String): return x.ends_with(".tres")).\
		map(func(x: String): return load(TILE_OBJECTS_PATH + x))
	onPlaceStartingTiles()
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if HoverModel != null and !(HoverModel is TileGD): onHoverModelHovered()
		
	if Input.is_action_just_pressed("FocusControl"):
		if !SaveLineEdit.has_focus(): 
			if SearchTileObject.has_focus(): onSearchTileObjectReleaseFocus()
			else: SearchTileObject.grab_focus()
		else: SaveLineEdit.release_focus()
	
	if !SaveLineEdit.has_focus() and !SearchTileObject.has_focus():
		if Input.is_action_just_pressed("SelectDeselect"):
			if HoverModel != null: onHoverModelDeselected()
			else: onLastHoverModelSelected()
		
		elif Input.is_action_just_pressed("TileFill"):
			if HoverModel == null:
				var TileObject: TileObjectGD = onFindMouseTileObject()
				if TileObject != null and TileObject is TileGD: onTileFill(TileObject)
				else: onChangeTileFillButtonState()
			else: onChangeTileFillButtonState()
			
		elif Input.is_action_just_pressed("TileLock"):
			onChangeTileLockButtonState()
			
		if Input.is_action_just_released("Delete"): deletion_elevation = -1; object_delete = false
			
		if !is_camera_panning:
			if Input.is_action_pressed("MainInput"):
				if HoverModel != null:
					if HoverModel is TileGD: onHoverModelPlaced()
					elif Input.is_action_just_pressed("MainInput"): onHoverModelPlaced()
				elif Input.is_action_just_pressed("MainInput"):
					var TileObject: TileObjectGD = onFindMouseTileObject()
					if TileObject != null:
						setBaseElevation(TileObject.getHeight())
				
			elif Input.is_action_pressed("Delete"):
				if HoverModel == null: onInputDeleteMouseTileObject()
				
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
				
			if !is_rotation_disabled:
				if Input.is_action_pressed("FastRotateLeft"):
					if HoverModel != null: onRotate(HoverModel, -1, false)
					else: onRotate(onFindMouseTileObject(), -1, false)
				elif Input.is_action_pressed("FastRotateRight"):
					if HoverModel != null: onRotate(HoverModel, 1, false)
					else: onRotate(onFindMouseTileObject(), 1, false)
				
				elif Input.is_action_pressed("RotateLeft"):
					if HoverModel != null: onRotate(HoverModel, -1)
					else: onRotate(onFindMouseTileObject(), -1)
					
				elif Input.is_action_pressed("RotateRight"):
					if HoverModel != null: onRotate(HoverModel, 1)
					else: onRotate(onFindMouseTileObject(), 1)
					
				
			if !is_scroll_disabled:
				if Input.is_action_just_pressed("ChangeVariationDown"):
					if HoverModel != null: onChangeHoverModelVariation(-1)
					else: onChangeMouseTileObjectVariation(-1)
					onDisableScroll()
				elif Input.is_action_just_pressed("ChangeVariationUp"):
					if HoverModel != null: onChangeHoverModelVariation(1)
					else: onChangeMouseTileObjectVariation(1)
					onDisableScroll()
		
#endregion
#region Search + Select Tile Object Info
@onready var SearchTileObject: LineEdit = %SearchTileObject
@onready var SearchResultsContainer: VBoxContainer = %SearchResultsContainer
func onFindTileObjectInfo(id: int) -> TileObjectInfo:
	return all_tile_objects.filter(func(x: TileObjectInfo): return x.id == id)[0]
	
func _on_search_tile_object_text_changed(text: String):
	for button in SearchResultsContainer.get_children(): button.queue_free()
	if !text.is_empty():
		for info in all_tile_objects.filter(func(x: TileObjectInfo): return x.name.to_lower().begins_with(text.to_lower())):
			var button: Button = preload("res://scenes/editors/level_editor/tile_object_search_result.tscn").instantiate()
			SearchResultsContainer.add_child(button)
			button.setInfo(info)
			button.mouse_filter = Control.MOUSE_FILTER_STOP
			button.mouse_entered.connect(onMouseInUI.bind(true))
			button.mouse_exited.connect(onMouseInUI.bind(false))
			button.custom_pressed.connect(onTileObjectInfoSelected)

func onTileObjectInfoSelected(info: TileObjectInfo, data: TileObjectData = info.createData(), remove_last: bool = true) -> void:
	if remove_last and HoverModel != null: HoverModel.queue_free()
	
	HoverModel = data.onLoad(World, info)
	HoverModel.setRayPickable(true)
	HoverModel.position = Vector3(0, 10000, 0)
	HoverModel.setEmptyCollisionLayers()
	
	var coords := Vector4i.ZERO
	if HoverModel is TileGD and HoverStaticBody != null: coords = HoverStaticBody.coords
	elif !(HoverModel is TileGD):
		var Tile: TileGD = onFindMouseTile()
		if Tile != null: coords = Tile.getCoords()
		
	if coords != Vector4i.ZERO: HoverModel.setPosition(coords, onFindMousePoint())
	
	last_selected_info = LastSelectedInfo.new(HoverModel.info.id, HoverModel.data)
	HoverModel.setHalfTransparent()
	
func onSearchTileObjectReleaseFocus() -> void:
	SearchTileObject.release_focus()
	if SearchResultsContainer.get_child_count() > 0:
		onTileObjectInfoSelected(SearchResultsContainer.get_child(0).info)
#endregion
#region Hovering & Placing TileObjects
var last_selected_info: LastSelectedInfo
func onMouseExitTileStaticBody() -> void:
	HoverStaticBody = null

func onMouseEnterTileStaticBody(_HoverStaticBody: StaticBody3D) -> void:
	HoverStaticBody = _HoverStaticBody
	if HoverModel != null and HoverModel is TileGD:
		HoverModel.setCoords(HoverStaticBody.coords)

func onLastHoverModelSelected() -> void:
	if last_selected_info != null:
		onTileObjectInfoSelected(onFindTileObjectInfo(last_selected_info.id), last_selected_info.data)

func onHoverModelDeselected() -> void:
	if HoverModel != null:
		last_selected_info = LastSelectedInfo.new(HoverModel.info.id, HoverModel.data)
		HoverModel.queue_free()
		HoverModel = null
		
func onHoverModelHovered() -> void:
	var Tile: TileGD = onFindMouseTile()
	if Tile != null:
		HoverModel.setPosition(Tile.getCoords(), onFindMousePoint())
		
func onHoverModelPlaced() -> void:
	if HoverModel is TileGD:
		onDeleteTileObject(onFindTile(HoverModel.getCoords()))
		
	HoverModel.setRayPickable(false)
	HoverModel.setDefaultCollisionLayers()
	HoverModel.setRegularMaterial()
	
	if HoverModel is TileGD and tile_fill_enabled:
		onTileFill(HoverModel)
	
	onTileObjectInfoSelected(HoverModel.info, HoverModel.data.getDuplicate(), false)
		
func onPlaceStartingTiles() -> void:
	var info: TileObjectInfo = onFindTileObjectInfo(1)
	for x in range(-DEFAULT_LEVEL_SIZE, (DEFAULT_LEVEL_SIZE + 1)):
		for y in range(max(-DEFAULT_LEVEL_SIZE, -x - DEFAULT_LEVEL_SIZE), min(DEFAULT_LEVEL_SIZE, -x + DEFAULT_LEVEL_SIZE) + 1):
			onPlaceBaseTile(Vector4i(x, y, -x-y, 0), info)

func onPlaceBaseTile(coords: Vector4i, info: TileObjectInfo = onFindTileObjectInfo(1)) -> TileGD:
	var data := TileDataGD.new(1, coords)
	var Model: TileGD = data.onLoad(World, info)
	Model.setRegularMaterial()
	return Model
	
#endregion
#region Elevation
@onready var TilePlaneElevation: Node3D = %TilePlaneElevation
@onready var BaseElevationLabel: Label = %BaseElevationLabel
func setBaseElevation(_base_elevation: int) -> void:
	if _base_elevation != base_elevation:
		base_elevation = clamp(_base_elevation, 0, MAX_ELEVATION)
		BaseElevationLabel.text = "Elevation: " + str(base_elevation)
	
		for child in TilePlaneElevation.get_children():
			TilePlaneElevation.remove_child(child)
			child.queue_free()
		
		for x in range(-MAX_LEVEL_SIZE, (MAX_LEVEL_SIZE + 1)):
			for y in range(max(-MAX_LEVEL_SIZE, -x - MAX_LEVEL_SIZE), min(MAX_LEVEL_SIZE, -x + MAX_LEVEL_SIZE) + 1):
				var coords := Vector4i(x, y, -x-y, base_elevation)
				onPlaceTileStaticBody(coords)
		
@export var tile_static_body: PackedScene
func onPlaceTileStaticBody(coords: Vector4i) -> void:
	var TileStaticBody: StaticBody3D = tile_static_body.instantiate()
	TileStaticBody.position = onConvertCoords(coords)
	TileStaticBody.coords = coords
	TileStaticBody.mouse_exited.connect(onMouseExitTileStaticBody)
	TileStaticBody.mouse_entered.connect(onMouseEnterTileStaticBody.bind(TileStaticBody))
	TilePlaneElevation.add_child(TileStaticBody)

func onFindTileStaticBody(coords: Vector4i) -> StaticBody3D:
	for StaticBody in get_tree().get_nodes_in_group("TileStaticBody"):
		if StaticBody.coords == coords: return StaticBody
	return null
#endregion
#region External Setters
func _on_camera_3d_camera_panning(_is_camera_panning: bool):
	is_camera_panning = _is_camera_panning
#endregion
#region Variations
var is_scroll_disabled: bool = false
func onChangeHoverModelVariation(direction: int) -> void:
	HoverModel.clampVariation(direction)
	onTileObjectInfoSelected(HoverModel.info, HoverModel.data, true)
	
func onChangeMouseTileObjectVariation(direction: int) -> void:
	var TileObject: TileObjectGD = onFindMouseTileObject()
	if TileObject != null:
		var data: TileObjectData = TileObject.data
		var info: TileObjectInfo = TileObject.info
		TileObject.clampVariation(direction)
		TileObject.queue_free()
		data.onLoad(World, info)
		
func onDisableScroll() -> void:
	is_scroll_disabled = true
	await get_tree().create_timer(SCROLL_DELAY).timeout
	is_scroll_disabled = false
#endregion
#region Deleting
var object_delete: bool = false
var deletion_elevation: int = -1
func onDeleteTileObject(TileObject: TileObjectGD) -> void:
	if TileObject != null:
		TileObject.queue_free()
		if TileObject is TileGD and TileObject.data.tile_fill:
			var coords: Vector4i = TileObject.getCoords()
			coords.w = 0
			onPlaceBaseTile(coords)
	
func onInputDeleteMouseTileObject() -> void:
	var TileObject: TileObjectGD = onFindMouseTileObject()
	if TileObject != null:
		if TileObject is TileGD and !object_delete:
			if deletion_elevation == -1: deletion_elevation = TileObject.getHeight()
			if TileObject.getHeight() == deletion_elevation:
				onDeleteTileObject(TileObject)
		elif Input.is_action_just_pressed("Delete"): onDeleteTileObject(TileObject); object_delete = true
#endregion
#region Rotating
var is_rotation_disabled: bool = false
func onRotate(TileObject: TileObjectGD, direction: int, is_slow_rotate_speed: bool = true) -> void:
	if TileObject != null:
		if TileObject.info.lock_rotation:
			TileObject.onLockRotateDirection(direction)
			onDisableRotation()
		else: TileObject.onRotateDirection(direction, is_slow_rotate_speed)
	
func onDisableRotation() -> void:
	is_rotation_disabled = true
	await get_tree().create_timer(ROTATION_LOCK_DELAY).timeout
	is_rotation_disabled = false
#endregion
#region TileFill
var tile_fill_enabled: bool = true
@onready var TileFillButton: CheckBox = %TileFillButton

func onTileFill(Tile: TileGD) -> void:
	var action: String = Tile.onCreateTileFill(!Tile.data.tile_fill)
	match action:
		"CREATE":
			var coords: Vector4i = Tile.getCoords()
			coords.w = 0
			onPlaceBaseTile(coords)
		"DESTROY":
			var tiles_below: Array = getTilesBelow(Tile)
			for _Tile in tiles_below: onDeleteTileObject(_Tile)
			
func onTileFillButtonPressed():
	tile_fill_enabled = !tile_fill_enabled

func onChangeTileFillButtonState() -> void:
	tile_fill_enabled = !tile_fill_enabled
	TileFillButton.set_pressed_no_signal(tile_fill_enabled)
#endregion

#region Tile Lock
@onready var TileLockButton: CheckBox = %TileLockButton
var tile_lock_force: bool = false
func onTileLockButtonPressed():
	tile_lock_force = !tile_lock_force
	
func onChangeTileLockButtonState() -> void:
	tile_lock_force = !tile_lock_force
	TileLockButton.set_pressed_no_signal(tile_lock_force)
#endregion

#region Saving
const LEVEL_PATH: String = "res://resources/game/levels/"
@onready var SaveLineEdit: LineEdit = %SaveLineEdit
@onready var AreaLineEdit: LineEdit = %AreaLineEdit
func _on_save_button_pressed():
	var level_name: String = SaveLineEdit.text
	if !level_name.is_empty():
		var data: Array[TileObjectData] = []
		data.assign(get_tree().get_nodes_in_group("TileObjects").map(func(x: TileObjectGD): return x.data))
		
		var valid_name: String = await getValidLevelName(level_name) + ".tres"
		var path: String = LEVEL_PATH + valid_name
		var level_info := LevelInfo.new()
		
		var id: int = 0 if !FileAccess.file_exists(path) else load(path).id
		
		level_info.setInfo(level_name, int(AreaLineEdit.text), data, id)
		
		if level_name.is_empty(): level_name = valid_name
		ResourceSaver.save(level_info, path)
	
func getValidLevelName(text: String) -> String:
	if !text.is_valid_filename() and !text.is_empty(): 
		UI.modulate = Color(1, 0, 0)
		await get_tree().create_timer(1).timeout
		UI.modulate = Color(1, 1, 1)
	return text.to_snake_case()
#endregion

#region Loading

@onready var LoadLevelContainer: Container = %LoadLevelContainer
@onready var LoadLevels: Control = %LoadLevels
func _on_load_button_pressed():
	LoadLevels.visible = !LoadLevels.visible
	for child in LoadLevelContainer.get_children(): child.queue_free()
	if LoadLevels.visible:
		SearchTileObject.text = ""
		SearchTileObject.text_changed.emit("")
		onHoverModelDeselected()
		var levels: Array = Helper.getResourcesRecursive(LEVEL_PATH, LevelInfo)
		for level in levels:
			var button := Button.new()
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.text = level.name
			button.pressed.connect(onLoadLevel.bind(level))
			button.mouse_filter = Control.MOUSE_FILTER_STOP
			button.mouse_entered.connect(onMouseInUI.bind(true))
			button.mouse_exited.connect(onMouseInUI.bind(false))
			LoadLevelContainer.add_child(button)

func _on_hide_load_level_button_pressed():
	LoadLevels.visible = false

func onLoadLevel(level_info: LevelInfo) -> void:
	_on_save_button_pressed()
	onHoverModelDeselected()
	
	SaveLineEdit.text = level_info.name
	AreaLineEdit.text = str(level_info.area_id)
	
	for tile_object in get_tree().get_nodes_in_group("TileObjects"): tile_object.queue_free()
	
	for tile_object_data in level_info.data:
		tile_object_data.onLoad(World)
		
func _on_search_tile_object_focus_entered():
	LoadLevels.visible = false
#endregion
var was_last_selected: bool = false
func onMouseInUI(state: bool) -> void:
	if state:
		was_last_selected = HoverModel != null
		onHoverModelDeselected()
	else:
		if was_last_selected: onLastHoverModelSelected()
#region
