extends Node

#region Exports
@export var DEFAULT_LEVEL_SIZE: int = 5
@export var MAX_LEVEL_SIZE: int = 30
@export var SCROLL_DELAY: float = 0.2
@export var ROTATION_LOCK_DELAY: float = 0.15
@export var SpawnIdUIPacked: PackedScene
@export var TileObjectSearchResultPacked: PackedScene
@export var PanelButtonPacked: PackedScene
@export var BASE_ROTATION_TIMER: float = 0.25
@export_dir var TILE_OBJECTS_PATH: String
@export var AREA_ID_TO_SCRIPT: Array[IdToScript]
@export var saved_data_level_gdscript: GDScript

@onready var UI: Control = $UI
@onready var World: Node3D = %World
@onready var Camera: Camera3D = %Camera3D

@onready var ProgressEdit: LineEdit = %ProgressEdit
@onready var LevelNameEdit: LineEdit = %LevelNameEdit
@onready var SearchResultsPanel: PanelContainer = %SearchResultsPanel
#endregion
#region Globals
var is_camera_panning: bool = false

var all_tile_objects: Array
var all_tile_objects_to_words: Dictionary
var base_elevation: int = -1

var HoverStaticBody: StaticBody3D
var HoverModel: TileObjectGD

var base_tile_info: TileInfo
var selected_area_id: int = 1
var current_area_id: int = 1

#endregion
#region Helper Functions
func onConvertCoords(coords: Vector4i) -> Vector3:
	return Vector3((sqrt(3) * coords.x + sqrt(3) * coords.y * 0.5), coords.w * 0.6, coords.y * (3 / 2.0))
	
func onFindTile(coords: Vector4i) -> TileGD:
	for Tile in get_tree().get_nodes_in_group("TilesGD"):
		if Tile != HoverModel and Tile.getCoords() == coords: return Tile
	return null
	
@onready var TileObjectRay: RayCast3D = %TileObjectRay
func onFindMouseTileObject() -> TileObjectGD:
	Helper.setCameraRay(TileObjectRay, Camera)
	return Helper.getCollision(TileObjectRay.get_collider(), TileObjectGD)

func onFindMousePoint() -> Vector3:
	Helper.setCameraRay(TileObjectRay, Camera)
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
	
func onFindScriptById(id: int = current_area_id) -> GDScript:
	for id_to_scripts in AREA_ID_TO_SCRIPT:
		if id == id_to_scripts.id:
			return id_to_scripts.gdscript
	return null

#endregion
#region Base Functions
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		onSaveLevel()

func _ready() -> void:
	setBaseElevation(0)
	all_tile_objects = Helper.getFofInfoArray(TileObjectInfo)
	setAllTileObjectsToWords()
	setAreaOptionButtonItems()
	LoadLevels.visible = false
	SearchResultsPanel.visible = false
		
func setAllTileObjectsToWords() -> void:
	for info in all_tile_objects:
		all_tile_objects_to_words[info] = Array(info.name.split(" ")).map(func(x: String): return x.to_lower())
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if HoverModel != null and !(HoverModel is TileGD): onHoverModelHovered()
		
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("FocusControl"):
		var focus_owner := get_viewport().gui_get_focus_owner()
		if focus_owner == null or (focus_owner is not LineEdit or focus_owner == SearchTileObject):
			if SearchTileObject.has_focus(): onSearchTileObjectReleaseFocus()
			else: SearchTileObject.grab_focus()
		elif focus_owner != null and focus_owner is LineEdit:
			focus_owner.release_focus()
		
	if !get_viewport().gui_get_focus_owner() is LineEdit:
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
			
		elif Input.is_action_just_released("SetSpawnID"):
			var spawn_object: SpawnGD
			if HoverModel != null and HoverModel is SpawnGD: spawn_object = HoverModel
			
			var TileObject: TileObjectGD = onFindMouseTileObject()
			if TileObject is SpawnGD: spawn_object = TileObject
			
			if spawn_object != null: onCreateSetSpawnIdUI(spawn_object)
			
		if Input.is_action_just_released("Delete"): deletion_elevation = -1; object_delete = false
			
		if !is_camera_panning:
			if Input.is_action_pressed("MainInput"):
				if HoverModel != null:
					if HoverModel is TileGD: onHoverModelPlaced()
					elif Input.is_action_just_pressed("MainInput"): onHoverModelPlaced()
				elif Input.is_action_just_pressed("MainInput"):
					var TileObject: TileObjectGD = onFindMouseTileObject()
					if TileObject != null and TileObject is TileGD:
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
				
			if Input.is_action_just_released("RotateLeft") or Input.is_action_just_released("RotateRight"):
				TemporaryRotationObject = null
				
			if !is_rotation_disabled:
				if Input.is_action_just_pressed("RotateLeft") or Input.is_action_just_pressed("RotateRight"):
					TemporaryRotationObject = HoverModel if HoverModel != null else onFindMouseTileObject()
				
				if Input.is_action_pressed("RotateLeft") and TemporaryRotationObject != null:
					onRotate(TemporaryRotationObject, -1)
					
				elif Input.is_action_pressed("RotateRight") and TemporaryRotationObject != null:
					onRotate(TemporaryRotationObject, 1)
				
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
		var infos: Array = all_tile_objects_to_words.keys()
		if text != "all":
			infos = infos.filter(func(x: TileObjectInfo): return all_tile_objects_to_words[x]\
				.any(func(y: String): return y.begins_with(text.to_lower())))
					
		for info in infos:
			var panel_button: Control = TileObjectSearchResultPacked.instantiate()
			SearchResultsContainer.add_child(panel_button)
			panel_button.setInfo(info)
			panel_button.mouse_in_ui.connect(onMouseInUI)
			panel_button.custom_pressed.connect(onTileObjectInfoSelected)
			
	SearchResultsPanel.visible = !text.is_empty()

func onTileObjectInfoSelected(data: SavedData, remove_last: bool = true) -> void:
	if remove_last and HoverModel != null: HoverModel.queue_free()
	onReleaseLineEditFocus()
	
	if data is SavedDataTile: data.is_decoration = is_decoration
	HoverModel = SavedData.onLoadModel(data, World)
	HoverModel.setRayPickable(true)
	HoverModel.position = Vector3(0, 10000, 0)
	HoverModel.setCollisionLayers(0)
	HoverModel.setHalfTransparent()
	
	var coords := Vector4i(0, 0, 0, -1)
	if HoverModel is TileGD and HoverStaticBody != null: coords = HoverStaticBody.coords
	elif !(HoverModel is TileGD):
		var Tile: TileGD = onFindMouseTile()
		if Tile != null: coords = Tile.getCoords()
		
	if coords != Vector4i(0, 0, 0, -1):
		if HoverModel is TileGD: HoverModel.setCoords(coords)
		elif HoverModel is ObjectGD: HoverModel.setPosition(coords, onFindMousePoint(), tile_lock_force)
	LastSelectedData = HoverModel.onSave()
	
func onSearchTileObjectReleaseFocus() -> void:
	SearchTileObject.release_focus()
	if SearchResultsContainer.get_child_count() > 0:
		onTileObjectInfoSelected(SearchResultsContainer.get_child(0).getData())
#endregion
#region Hovering & Placing TileObjects
var LastSelectedData: SavedData
func onMouseExitTileStaticBody() -> void:
	HoverStaticBody = null

func onMouseEnterTileStaticBody(_HoverStaticBody: StaticBody3D) -> void:
	HoverStaticBody = _HoverStaticBody
	if HoverModel != null and HoverModel is TileGD:
		HoverModel.setCoords(HoverStaticBody.coords)

func onLastHoverModelSelected() -> void:
	if LastSelectedData != null:
		onTileObjectInfoSelected(LastSelectedData)

func onHoverModelDeselected() -> void:
	if HoverModel != null:
		LastSelectedData = HoverModel.onSave()
		HoverModel.queue_free()
		HoverModel = null
		
func onHoverModelHovered() -> void:
	var Tile: TileGD = onFindMouseTile()
	if Tile != null:
		HoverModel.setPosition(Tile.getCoords(), onFindMousePoint(), tile_lock_force)
		
func onHoverModelPlaced() -> void:
	if HoverModel is TileGD:
		onDeleteTileObject(onFindTile(HoverModel.getCoords()))
	
	HoverModel.setRayPickable(false)
	HoverModel.setDefaultCollisionLayers()
	HoverModel.setRegularMaterial()
	
	if HoverModel is TileGD and tile_fill_enabled:
		onTileFill(HoverModel)
	
	var save_data: SavedData = HoverModel.onSave()
	if save_data is SavedDataTile: save_data.tile_fill = false
	
	onTileObjectInfoSelected(save_data, false)
		
func onPlaceBaseTile(coords: Vector4i) -> TileGD:
	var tile_data: SavedDataTile = SavedDataTile.new(base_tile_info.id, false, 0, coords)
	tile_data.is_decoration = is_decoration
	return SavedData.onLoadModel(tile_data, World)
	
#endregion
#region Elevation

@onready var BaseElevationLabel: Label = %BaseElevationLabel
func setBaseElevation(_base_elevation: int) -> void:
	if _base_elevation != base_elevation:
		base_elevation = max(_base_elevation, 0)
		BaseElevationLabel.text = "Elevation: " + str(base_elevation)
		get_tree().call_group("TileStaticBody", "queue_free")
		
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
	add_child(TileStaticBody)

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
	onTileObjectInfoSelected(HoverModel.onSave(), true)
	
func onChangeMouseTileObjectVariation(direction: int) -> void:
	var TileObject: TileObjectGD = onFindMouseTileObject()
	if TileObject != null:
		TileObject.clampVariation(direction)
		TileObject.onLoadModel()
		
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
		if TileObject is TileGD and TileObject.tile_fill:
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
var TemporaryRotationObject: TileObjectGD
var is_rotation_disabled: bool = false
func onRotate(TileObject: TileObjectGD, direction: int) -> void:
	if TileObject != null:
		if TileObject.getLockRotation(): onDisableRotation()
		TileObject.onRotateDirection(direction)
	
func onDisableRotation() -> void:
	is_rotation_disabled = true
	get_tree().create_timer(ROTATION_LOCK_DELAY).timeout.connect(func(): is_rotation_disabled = false)
	
#endregion
#region TileFill
var tile_fill_enabled: bool = true
@onready var TileFillButton: CheckBox = %TileFillButton

func onTileFill(Tile: TileGD, state: bool = !Tile.tile_fill) -> void:
	var action: String = Tile.onCreateTileFill(state)
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
#region Load Buttons
const LEVEL_PATH: String = "res://resources/fof/levels/"
const DECORATION_PATH: String = "res://resources/datastore/decorations/"
@onready var SaveLineEdit: LineEdit = %SaveLineEdit
@onready var AreaOptionButton: OptionButton = %AreaOptionButton
@onready var LoadLevelContainer: Container = %LoadLevelContainer
@onready var LoadLevels: Control = %LoadLevels

func _on_load_button_pressed():
	LoadLevels.visible = !LoadLevels.visible
	if LoadLevels.visible:
		SearchTileObject.text = ""
		SearchTileObject.text_changed.emit("")
		onHoverModelDeselected()
		onApplyLevelFilters()
			
func _on_hide_load_level_button_pressed():
	LoadLevels.visible = false
		
func _on_search_tile_object_focus_entered():
	LoadLevels.visible = false
#endregion
#region MouseInUI
var was_last_selected: bool = false
func onMouseInUI(state: bool) -> void:
	if state:
		was_last_selected = HoverModel != null
		onHoverModelDeselected()
	else:
		if was_last_selected: onLastHoverModelSelected()
#endregion
#region Area Option Button
func setAreaOptionButtonItems() -> void:
	var index: int = 0
	for area_info in Helper.getFofInfoArray(AreaInfo):
		AreaOptionButton.add_item(area_info.name, area_info.id)
		if area_info.id == current_area_id:
			onAreaOptionButtonSelected(index)
		index += 1
	
#endregion

#region Level Shenaningans
var loaded: Variant # Level / Decoration
func onNewEmptyLevel() -> void:
	onSaveLevel()
	SaveLineEdit.text = ""
	
	current_area_id = selected_area_id
	base_tile_info = Helper.getFofInfoID(AreaInfo, current_area_id).base_tile_info
	
	for tile_object in get_tree().get_nodes_in_group("TileObjectsGD"):
		tile_object.onClear()
		
	if is_overworld:
		loaded = DecorationDatastore.new()
		
		var OVERWORLD_MAP_SIZE: int = 27
		var Y_MAX: int = 9
		for x in range(-OVERWORLD_MAP_SIZE, (OVERWORLD_MAP_SIZE + 1)):
			for y in range(max(-OVERWORLD_MAP_SIZE, -x - OVERWORLD_MAP_SIZE), min(OVERWORLD_MAP_SIZE, -x + OVERWORLD_MAP_SIZE) + 1):
				if abs(y) <= Y_MAX: onPlaceBaseTile(Vector4i(x, y, -x-y, 0))
		return
		
	loaded = Helper.getFofInfoID(AreaInfo, selected_area_id).base_level_script.new()
	for x in range(-DEFAULT_LEVEL_SIZE, (DEFAULT_LEVEL_SIZE + 1)):
		for y in range(max(-DEFAULT_LEVEL_SIZE, -x - DEFAULT_LEVEL_SIZE), min(DEFAULT_LEVEL_SIZE, -x + DEFAULT_LEVEL_SIZE) + 1):
			onPlaceBaseTile(Vector4i(x, y, -x-y, 0))
	
func onNewEmptyLevelDecoration() -> void:
	setDecoration(true)
	setIsOverworld(false)
	onNewEmptyLevel()
	
func onNewEmptyLevelRegular() -> void:
	setDecoration(false)
	setIsOverworld(false)
	onNewEmptyLevel()
	
func onNewEmptyLevelOverworld() -> void:
	setDecoration(true)
	setIsOverworld(true)
	onNewEmptyLevel()
	
func onSaveLevel() -> void:
	var level_name: String = SaveLineEdit.text
	if level_name.is_empty(): return
	if !is_decoration:
		if loaded is DecorationDatastore:
			loaded = Helper.getFofInfoID(AreaInfo, current_area_id).base_level_script.new()
			
		if level_name != loaded.name:
			var new_level: LevelInfo = onFindLevelByName(level_name)
			if new_level != null: loaded = new_level
			else: loaded = loaded.get_script().new()

		loaded.data = []
		for child in get_tree().get_nodes_in_group("TileObjectsGD"):
			var data: SavedData = child.onSave()
			data.public_id = 0
			loaded.data.append(data)

		if level_name == loaded.name:
			ResourceSaver.save(loaded)
			return
		
		loaded.setInfo(level_name, AreaOptionButton.get_selected_id())
		loaded.setSpawnPropertiesAutoValues(get_tree().get_nodes_in_group("TileObjectsGD"))
		loaded.id = Helper.getFirstNonConsecutiveId(LevelInfo)
		
		loaded.gdscript = onFindScriptById()
		loaded.saved_data = saved_data_level_gdscript
		
		var path: String = LEVEL_PATH + level_name.to_snake_case() + ".tres"
		loaded.resource_path = path
		ResourceSaver.save(loaded)
		return
	
	if loaded is not DecorationDatastore: loaded = DecorationDatastore.new()
	loaded.name = level_name
	loaded.data = []
	for child in get_tree().get_nodes_in_group("TileObjectsGD"):
		var data: SavedData = child.onSave()
		data.public_id = 0
		loaded.data.append(data)

	ResourceSaver.save(loaded, DECORATION_PATH + loaded.name + ".tres")
		
func onLoadLevel(loaded_info: Variant) -> void:
	onSaveLevel()
	loaded = loaded_info
	
	current_area_id = selected_area_id
	base_tile_info = Helper.getFofInfoID(AreaInfo, current_area_id).base_tile_info
	
	setIsOverworld(loaded.name.contains("Overworld"))
	setDecoration(loaded is DecorationDatastore)
	
	onHoverModelDeselected()
	SaveLineEdit.text = loaded.name
	
	if loaded is LevelInfo:
		var area_id: int = loaded.area_id
		for idx in range(AreaOptionButton.item_count):
			if AreaOptionButton.get_item_id(idx) == area_id:
				AreaOptionButton.select(idx)
				break
	
	for tile_object in get_tree().get_nodes_in_group("TileObjectsGD"):
		tile_object.onClear()
	
	for data in loaded.data:
		SavedData.onLoadModel(data, World)
	
func onAreaOptionButtonSelected(_index: int = 0) -> void:
	selected_area_id = AreaOptionButton.get_selected_id()
	
func onFindLevelByName(level_name: String) -> LevelInfo:
	for level in Helper.getFofInfoArray(LevelInfo):
		if level.name == level_name: return level
	return null
#endregion 

#region Decorations
var is_decoration: bool
	
func setDecoration(state: bool) -> void:
	is_decoration = state
#endregion

#region Overworld
var is_overworld: bool
func setIsOverworld(state: bool) -> void:
	is_overworld = state
#endregion

#region Set Spawn ID
func onCreateSetSpawnIdUI(Spawn: SpawnGD) -> void:
	var SpawnIdUI: Control = SpawnIdUIPacked.instantiate()
	UI.add_child(SpawnIdUI)
	SpawnIdUI.setInfo(Spawn)
	SpawnIdUI.mouse_in_ui.connect(onMouseInUI)
#endregion

#region Level Filters
func _on_progress_edit_text_changed(new_text: String) -> void:
	onApplyLevelFilters()
	
func _on_level_name_edit_text_changed(new_text: String) -> void:
	onApplyLevelFilters()
	
# Set prog to 0 for decorations only and -1 for overworld only
func onApplyLevelFilters() -> void:
	for child in LoadLevelContainer.get_children():
		LoadLevelContainer.remove_child(child)
		child.queue_free()
		
	var progress: int = int(ProgressEdit.text) if ProgressEdit.text != "-" else -1
	var decorations: Array = []
	if !ProgressEdit.text.is_empty() and progress <= 0:
		decorations = Array(DirAccess.get_files_at(DECORATION_PATH))\
			.map(func(x: String): return load(DECORATION_PATH + x))
			
		if progress == -1:
			decorations = decorations.filter(func(x: DecorationDatastore): return x.name.ends_with("Overworld"))
		
	var levels: Array = []
	
	if ProgressEdit.text.is_empty() or progress > 0:
		levels = Helper.getFofInfoArray(LevelInfo)
	
	if !ProgressEdit.text.is_empty():
		levels = levels.filter(func(x: LevelInfo): return progress >= x.progress_min and progress <= x.progress_max)
	levels = levels.filter(func(x: LevelInfo): return x.area_id == selected_area_id)
	var name_text: String = LevelNameEdit.text.to_lower()
	
	levels += decorations
	levels = levels.filter(func(x: Variant):\
		return x.name.to_lower().begins_with(name_text))
	
	for type in levels:
		var button := onCreateLoadLevelButton(type.name, type)
		if type is DecorationDatastore:
			button.theme_type_variation = "YellowPanelContainer"
			
func onCreateLoadLevelButton(button_name: String, pressed_info: Variant) -> PanelContainer:
	var panel_button: PanelContainer = PanelButtonPacked.instantiate()
	LoadLevelContainer.add_child(panel_button)
	panel_button.setText(button_name)
	panel_button.mouse_in_ui.connect(onMouseInUI)
	panel_button.pressed.connect(onLoadLevelButtonPressed.bind(pressed_info))
	return panel_button
	
func onLoadLevelButtonPressed(pressed_info: Variant) -> void:
	onReleaseLineEditFocus()
	onLoadLevel(pressed_info)
#endregion

#region UI
func onReleaseLineEditFocus() -> void:
	var focus_owner := get_viewport().gui_get_focus_owner()
	if focus_owner != null and focus_owner is LineEdit:
		focus_owner.release_focus()
	
	
