extends Control
signal load_world
signal equip_sky

signal fileloader_state
@onready var ItemTypes: Control = $BuildMenu/LoadedMenu/ItemTypes
@onready var Tabs: HBoxContainer = $BuildMenu/Tabs/Tabs
@onready var BuildMenu = $BuildMenu
@onready var Items = $BuildMenu/LoadedMenu/Items
@onready var BackArrow = $BuildMenu/LoadedMenu/PRBackArrow
@onready var BuildMenuWorld = $BuildMenu/LoadedMenu/ItemsViewer/ItemViewport/BuildMenuWorld
@onready var ModelItem: Node3D = $BuildMenu/LoadedMenu/ModelViewer/ViewmodelViewport/ViewmodelWorld/Model

@onready var HeightButtons: Control = $UtilityMenu/Buttons/WallButtons
@onready var ElevationButtons: Control = $UtilityMenu/Buttons/ElevationButtons

@export var INFO_MENU_MOVE_SPEED: float = 6
@export var BUILD_MENU_MOVE_SPEED: float = 4

var SelectionBox: Node

@onready var mblockers: Array = [$BuildMenu, $UtilityMenu, $HistoryMenu, $InfoMenu]
var block_screen: bool = false
var active_tile: Node3D
var active_remove_state: int = 0
var level_difficulty: int = 1
var mblocker_rects: Array = []

const RAY_LENGTH: int = 1000
const TID: int = 5
const FILE_LOADER_NAME: String = "Level"

var file_loader_loaded: bool = false
var loaded_area: AreaInfoGD
var loaded_level: bool = false
var World: Node3D = preload("res://scenes/world/editor_world/editor_world.tscn").instantiate()

var build_menu_positions := Vector2.ZERO
var build_weight: float = 0

const SPIN_MODEL_SPEED: int = 50
var spin_model: bool = false
var info_weight: float = 0
var info_menu_positions := Vector2.ZERO
var info_menu_is_moving: int = 0
var build_menu_is_moving: int = 0
var default_level_size: int = [3, 5, 7, 9, 12, 15, 20, 25][Settings.level_size]
var level_size: int = 0

var selected_item_type: int = 0
var active_tile_state: int = 0
var max_item_types: int = 0

var current_history: Array = []
var erased_history: Array = []
var item_rects: Array = []

var keep_rotation: Array = [0, 0, 0, 0]
var old_mpos: Vector2

func _ready() -> void:
	on_load_item_properties()
	on_load_favorites()
	for i in [["DefaultWallHeight", HeightButtons.get_children()], ["LevelEditorElevation", ElevationButtons.get_children()]]:
		for btn in i[1]:
			btn.pressed.connect(Settings["set_" + i[0].to_lower()].bind(int(str(btn.name))))
			btn.pressed.connect(Settings.update_settings_info.bind(int(str(btn.name)), "Preferences", i[0]))
			btn.pressed.connect(set_heightbuttons_modulate)
			if i[0] == "LevelEditorElevation":
				btn.pressed.connect(setup_elevation)
	
	for btn in [$BuildMenu/LoadedMenu/PRLeftArrow, $BuildMenu/LoadedMenu/PRRightArrow, $HistoryMenu/PRLeft, $HistoryMenu/PRRight]:
		Helper.create_button_clickmask(btn)
		btn.pressed.connect((func(): AudioMaster.play_sfx("Woosh")))
	BuildMenu.get_node("WarningLabel").text = "Make sure to load in an area, silly!"
	BuildMenu.get_node("Tabs").visible = false
	BuildMenu.get_node("LoadedMenu").visible = false
	BuildMenu.position.y += BuildMenu.size.y
	reset_mblocker_rects()
	setup_elevation()
	set_heightbuttons_modulate()
	
func isLineEditsFocused() -> bool:
	return [LevelName, FolderName, IDEdit].any(func(x: LineEdit): return x.has_focus())

func _process(delta: float) -> void:
	if spin_model:
		ModelItem.rotation_degrees.y += delta * SPIN_MODEL_SPEED
	
	if !isLineEditsFocused():
		for input in [1,2,3,4,5,6,7]:
			if max_item_types > 0 and Input.is_action_just_pressed("ShiftNumber" + str(input)):
				on_type_button_pressed(input - 1)
				reset_infos(true)
				if active_tile: on_hover_tile(active_tile)
			
			elif input < 5 and Input.is_action_just_pressed("Number" + str(input)):
				on_load_tab(input - 1)

	if build_menu_is_moving == 0 and Input.is_action_just_pressed("Tab"):
		build_menu_is_moving = -1 if BuildMenu.position.y > 1000 else 1
		build_menu_positions = Vector2(BuildMenu.position.y, BuildMenu.position.y + (BuildMenu.size.y * build_menu_is_moving))
		build_weight = 0
		
	if build_menu_is_moving != 0:
		var adjusted_weight: float = clamp(build_weight * BUILD_MENU_MOVE_SPEED, 0, 1)
		var pos: float = lerp(build_menu_positions.x, build_menu_positions.y, adjusted_weight)
		BuildMenu.position.y = pos
		build_weight += delta
		
		if adjusted_weight >= 1:
			build_menu_is_moving = 0
			reset_mblocker_rects()

	if Input.is_action_just_released("Remove"):
		reset_active_tile_state(4)
			
	if Input.is_action_just_pressed("ClearSelection") and selected_item_pos:
		deselect_item()
	
	var disable_interact: bool = false
	if active_tile != null and active_tile.can_press:
		if Input.is_action_just_pressed(Helper.interact_button()): on_tile_interact(active_tile); disable_interact = true
		elif Input.is_action_pressed("LeftClick"): on_tile_select()
		
		if !block_screen:
			if Input.is_action_pressed("Remove"): on_tile_remove(active_tile) 
			elif Input.is_action_pressed("RotateLeft"): on_tile_rotate(active_tile, -1)
			elif Input.is_action_pressed("RotateRight"): on_tile_rotate(active_tile, 1)
			elif Input.is_action_pressed("FButton"): on_fill_pressed(active_tile)
	else:
		if Input.is_action_just_pressed("ShiftLeftClick"):
			on_update_tile_menu()
		
	if Input.is_action_pressed("LeftClick") and !selected_item_pos:
		match SelectionBox:
			null: on_create_selection_box()
			_: on_resize_selection_box()
		
	if !disable_interact and Input.is_action_just_pressed(Helper.interact_button()):
		load_settings_mini_menu()
	if Input.is_action_just_released("LeftClick") and is_inside_tree():
		on_clear_selection_box()
	
	if Input.is_action_just_pressed("Favorite"):
		var items: Array = Items.get_children().filter(func(x: Control): return Rect2(x.global_position, x.size).has_point(get_viewport().get_mouse_position()) and x.scene_file_path.ends_with("item.tscn"))
		if items.size() == 1: on_favorite_item(items[0])
		else: on_load_favorite_menu()
		
	old_mpos = get_viewport().get_mouse_position()
	if Input.is_action_just_pressed("TopDownAlign") and !Input.is_action_pressed(Helper.interact_button(true)):
		World.get_node("MovementCamera").rotation_degrees = Vector3(-88.5, 0, 0)
		World.get_node("MovementCamera")._total_pitch = 63.5
		
	if Input.is_action_just_released("FButton") and active_tile_state == 5: 
		reset_active_tile_state(0)
		fill_mode = 0
		
	if !is_undo_redo_delay:
		if Input.is_action_pressed("Redo"):
			on_redo_pressed()
			is_undo_redo_delay = true
			get_tree().create_timer(UNDO_REDO_DELAY).timeout.connect(func(): is_undo_redo_delay = false)
		elif Input.is_action_pressed("Undo"):
			on_undo_pressed()
			is_undo_redo_delay = true
			get_tree().create_timer(UNDO_REDO_DELAY).timeout.connect(func(): is_undo_redo_delay = false)


var favorites: Array = []
func on_favorite_item(item: Control) -> void:
	var pos: Array = folder_pos + item.get_node("Button").pressed.get_connections()[0].callable.get_bound_arguments()
	var spos: String = str(pos)
	var contents: Array = Helper.return_file_contents("user://save/level_editor/favorite_items.txt").split("\n", false)
	var erased: bool = false
	for p in contents:
		if spos == p:
			contents.erase(p)
			favorites.erase(pos)
			erased = true
			break
			
	if !erased and contents.size() < 7: 
		contents.append(pos)
		favorites.append(pos)
	var scontents: String = ""
	for p in contents:
		scontents += str(p) + "\n"
	
	Helper.write_to_file("user://save/level_editor/", "favorite_items", ".txt", scontents, false)
	on_load_folder()
	
var FavoriteMenu: Control
func on_load_favorite_menu() -> void:
	if loaded_area and !block_screen:
		reset_infos(true)
		block_screen = true
		reset_mblocker_rects()
		var favorite_menu: Control = preload("res://scenes/screens/level_editor/favorite_menu.tscn").instantiate()
		favorite_menu.position.x = get_viewport().get_mouse_position().x + 30
		favorite_menu.position.y = 10
		
		var contents: Array = Array(Helper.return_file_contents("user://save/level_editor/favorite_items.txt").split("\n", false)).map(func(x: String): return str_to_var(x))
		favorite_menu.label_texts = contents.map(func(x: Array): return transform_item_name(get_item_name(x), x[0]))
		favorite_menu.favorite_items = contents.map(func(x: Array): return get_folder_path(x, true, false, false))
		for j in favorite_menu.favorite_items:
			favorite_menu.variations.append(0)
			for n in range(10):
				if FileAccess.file_exists(j.left(-4) + str(n) + ".glb"):
					favorite_menu.variations[favorite_menu.variations.size() - 1] += 1
		
		favorite_menu.item_selected.connect(on_favorite_menu_item_selected)
		favorite_menu.removed_items.connect(on_remove_favorite_menu_items)
		add_child(favorite_menu)
		Helper.load_area_colors(favorite_menu, loaded_area.primary_color, loaded_area.accent_color)
		favorite_menu.queued.connect(on_file_loader_queued)
		FavoriteMenu = favorite_menu
		if active_tile:
			active_tile.load_tile(active_tile.info.tile.id)

func on_favorite_menu_item_selected(i: int, variation: int) -> void:
	selected_item_type = variation
	var f: Array = favorites[i]
	var tab_index: int = f[0] - 1
	selected_item_pos = f
	for child in Tabs.get_children():
		match child.get_index():
			tab_index: child.modulate = Helper.RED
			_: child.modulate = Helper.BASE
	
	folder_pos = []
	for n in range(f.size()):
		if n != f.size() - 1:
			folder_pos.append(f[n])
	
	on_load_folder()
	on_load_model()
	
	FavoriteMenu._queue_free()
	

func on_remove_favorite_menu_items(values: Array) -> void:
	for i in values:
		favorites.remove_at(i)
		
	var contents: String = ""
	for i in favorites: contents += str(i) + "\n"
	Helper.write_to_file("user://save/level_editor/", "favorite_items", ".txt", contents, false)
	on_load_folder()
	
func transform_item_name(unrefined_name: String, first_slot: int) -> String:
	if unrefined_name[0].is_valid_int():
		match first_slot:
			1: return "Ground"
			3: return "Wall"
	else: return unrefined_name.left(-4).capitalize()
	return ""
	
func on_load_favorites() -> void:
	favorites = []
	for p in Helper.return_file_contents("user://save/level_editor/favorite_items.txt").split("\n", false):
		favorites.append(str_to_var(p))
	
var og_sbox_pos: Vector2
func on_create_selection_box() -> void:
	if !block_screen and !(mblocker_rects.filter(func(x: Rect2i): return x.has_point(get_viewport().get_mouse_position()))):
		if !Settings.lasso_select:
			SelectionBox = ColorRect.new() 
			SelectionBox.position = get_viewport().get_mouse_position()
			og_sbox_pos = SelectionBox.position
		else:
			SelectionBox = Polygon2D.new()
			SelectionBox.position = Vector2(0, 0)
			SelectionBox.polygon = [get_viewport().get_mouse_position()]
			
		add_child(SelectionBox)
		SelectionBox.color = "2fffff87"
			
	
func on_resize_selection_box() -> void:
	if !Settings.lasso_select:
		var s: Vector2 = (og_sbox_pos - get_viewport().get_mouse_position()) * -1
		SelectionBox.scale = Vector2(-1 if s.x < 0 else 1, -1 if s.y < 0 else 1)
		SelectionBox.size = Vector2(abs(s.x), abs(s.y))
	else:
		if get_viewport().get_mouse_position() not in SelectionBox.polygon:
			SelectionBox.polygon = Array(SelectionBox.polygon) + [get_viewport().get_mouse_position()]
			
func on_clear_selection_box() -> void:
	if SelectionBox != null and is_inside_tree():
		var tiles: Array = []
		var ray: RayCast3D = World.get_node("TileRaycast")
		ray.position = World.get_node("MovementCamera").position
		for tile in World.get_node("Tiles/" + str(Settings.level_editor_elevation)).get_children():
			ray.target_position = tile.position - ray.position
			ray.force_raycast_update()
			if ray.get_collider() == tile.get_node("DetectMouse"):
				if !Settings.lasso_select:
					var rect := Rect2(SelectionBox.position, SelectionBox.size)
					if SelectionBox.scale.x == -1: rect.position.x -= rect.size.x
					if SelectionBox.scale.y == -1: rect.position.y -= rect.size.y
					if rect.has_point(World.get_node("MovementCamera").unproject_position(ray.get_collision_point())):
						tiles.append(tile)
				elif Geometry2D.is_point_in_polygon(World.get_node("MovementCamera").unproject_position(ray.get_collision_point()), SelectionBox.polygon):
					tiles.append(tile)
		on_tiles_selected(tiles)
		SelectionBox.queue_free()
		SelectionBox = null
		
func on_move_build_menu() -> void:
	build_menu_is_moving = true
func on_move_screen_switch() -> void:
	load_world.emit(World)

func on_ray_mouse() -> Node3D:
	var to: Vector3 = World.get_node("MovementCamera").project_ray_normal(get_viewport().get_mouse_position()) * RAY_LENGTH
	var ray: RayCast3D = World.get_node("TileRaycast")
	ray.position = World.get_node("MovementCamera").position
	ray.target_position = to
	ray.force_raycast_update()
	var node: Node3D = ray.get_collider()
	if node: node = node.get_parent()
	return node

func on_mblocker_mouse_exited():
	if active_tile:
		var tile: Node3D = on_ray_mouse()
		if tile == active_tile:
			active_tile.on_mouse_entered_check_mblockers(mblocker_rects)
	
func on_mblocker_mouse_entered():
	if active_tile: active_tile.on_mouse_exited(); reset_infos(true)

func reset_mblocker_rects() -> void:
	mblocker_rects = mblockers.map(func(x: Control): return Rect2i(x.global_position, x.size))
	
func on_area_selected(item: AreaInfoGD) -> void:
	on_clear_history()
	loaded_area = item
	Helper.load_area_colors(self, item.primary_color, item.accent_color)
	
	folder_pos = []
	build_folders = ["res://assets/models/"]
	on_setup_tabs()
	build_folders = [build_folders[0], build_folders[3], build_folders[2], build_folders[4], build_folders[1]]
	build_folders[1] = build_folders[1].filter(func(x: Variant): return !(typeof(x) == TYPE_STRING) or !x[0].is_valid_int() or int(x) == item.id)
	build_folders[3] = build_folders[3].filter(func(x: Variant): return !(typeof(x) == TYPE_STRING) or !x[0].is_valid_int() or int(x) == item.id)
	on_load_tab(0)
	
	if !loaded_level:
		on_build_menu_enabled()
	
	on_load_empty_level()
	equip_sky.emit(item.id, false)
	LoadLevel.clear()
	
	for level_info in Helper.getAllLevelInfo():
		if level_info.area == loaded_area: LoadLevel.add_item(level_info.folder_name)
	LoadLevel.selected = -1
	
@onready var LoadLevel: OptionButton = %LoadLevel
func on_load_level_pressed(index: int) -> void:
	on_load_level(Helper.getFofInfo(LoadLevel.get_item_text(index), "level", "folder_name"))
	
func on_load_level(info: LevelInfoGD) -> void:
	on_clear_history()
	active_tile = null
	match loaded_level:
		false: on_build_menu_enabled(); loaded_level = true
		_: _on_save_level_pressed()
	
	on_area_selected(info.area)
	level_size = info.level_size
	level_difficulty = info.difficulty
	
	clear_world_tiles()
	for i in info.tiles:
		var tile: Node3D = create_tile(Vector3(i.position[0], i.position[1], i.position[3]))
		tile.info = i
		
		tile.load_tile(i.tile.id)
		tile.load_obj(i.obj.id)
		tile.load_wall(i.wall.id)
		tile.load_tdeco(i.tdeco.id)
		tile.load_wdeco(i.wdeco.id)
	setup_elevation()
	onResetInfoMenu(info.name, info.folder_name, info.id, info.difficulty)
	
func on_load_empty_level(save_level: bool = true) -> void:
	if loaded_area != null:
		on_clear_history()
		Settings.set_leveleditorelevation(0)
		setup_elevation()
		set_heightbuttons_modulate()
		Settings.update_settings_info(0, "Preferences", "LevelEditorElevation")
		level_size = default_level_size
		
		active_tile = null
		if save_level: _on_save_level_pressed()
		
		clear_world_tiles()
		for w in range(6):
			for x in range(-default_level_size, (default_level_size + 1)):
				for y in range(max(-default_level_size, -x - default_level_size), min(default_level_size, -x + default_level_size) + 1):
					var tile: Node3D = create_tile(Vector3(x, y, w))
					tile.info = {"tile": {
					"id": 1 if w == 0 else 0, "rotation": 0, "type": 0, "multi_tile": []}, 
					"obj": EMPTY_DATA[1].duplicate(true),
					"wall": EMPTY_DATA[2].duplicate(true),
					"tdeco": EMPTY_DATA[3].duplicate(true),
					"wdeco": EMPTY_DATA[4].duplicate(true), 
					"position": [x, y, -x-y, w]}
					tile.load_tile(tile.info.tile.id)
					
		onResetInfoMenu()
		loaded_level = true
		setup_elevation()
	
@onready var DifficultySlider: HSlider = %DifficultySlider
func onResetInfoMenu(level_name: String = "", folder_name: String = "", id: int = 0, difficulty: int = 0) -> void:
	LevelName.text = level_name
	FolderName.text = folder_name
	IDEdit.text = str(id)
	DifficultySlider.value = difficulty
	
func clear_world_tiles() -> void:
	for child in World.get_node("Tiles").get_children():
		for tile in child.get_children():
			tile.queue_free()
			
	active_tile_check_deletion()
	
func active_tile_check_deletion() -> void:
	if active_tile != null and active_tile.is_queued_for_deletion(): active_tile = null
	
func create_tile(xy: Vector3) -> Node3D:
	var tile: Node3D = preload("res://assets/models/editor_tile.tscn").instantiate()
	tile.position = Vector3((sqrt(3) * xy.x + sqrt(3) * xy.y * 0.5),
	xy.z * 1.2,
	xy.y * 3 / 2)
	tile.load_obj_get_area.connect(on_load_obj_get_area)
	tile.load_tile_get_area.connect(on_load_tile_get_area)
	tile.load_wall_get_area.connect(on_load_wall_get_area)
	tile.active_tile.connect(on_is_active_tile)
	tile.hover_tile.connect(on_hover_tile)
	tile.exit_mouse.connect(on_tile_exit_mouse)
	tile.set_tile_material.connect(on_set_tile_material)
	
	tile.DetectMouse.mouse_entered.connect(on_tile_mouse_entered.bind(tile))
	tile.DetectMouse.mouse_exited.connect(tile.on_mouse_exited)
	World.get_node("Tiles/" + str(xy.z)).add_child(tile)
	return tile
	
func on_tile_mouse_entered(tile: Node3D) -> void:
	if !block_screen or tile in selection_tiles or move_tile != null:
		tile.on_mouse_entered_check_mblockers(mblocker_rects)
	
func on_build_menu_enabled() -> void:
	BuildMenu.get_node("WarningLabel").text = ""
	BuildMenu.get_node("Tabs").visible = true
	BuildMenu.get_node("LoadedMenu").visible = true
		
func on_file_loader_queued() -> void:
	block_screen = false
	reset_mblocker_rects()
	file_loader_loaded = false

@onready var IDEdit: LineEdit = %IDEdit
func _on_save_level_pressed() -> LevelInfoGD:
	if loaded_level and !(LevelName.text.is_empty())\
	and !(FolderName.text.is_empty()) and IDEdit.text.is_valid_int():
		var children: Array = []
		for child in World.get_node("Tiles").get_children():
			for tile in child.get_children():
				children.append(tile)
				
		var level_info: LevelInfoGD = LevelInfoGD.new()
		level_info.id = int(IDEdit.text)
		level_info.name = LevelName.text
		level_info.folder_name = FolderName.text
		level_info.difficulty = level_difficulty
		level_info.level_size = level_size
		level_info.area = loaded_area
		level_info.tiles = children.map(func(x: Node3D): return x.info)
		
		var DIR_PATH: String = "res://assets/base_game/levels/levels/" + level_info.folder_name + "/"
		DirAccess.make_dir_absolute(DIR_PATH)
		ResourceSaver.save(level_info, DIR_PATH + "level_info.tres")
		
		for item in range(LoadLevel.item_count).map(func(x: int): return LoadLevel.get_item_text(x)):
			if item == level_info.folder_name: return level_info
		
		LoadLevel.add_item(level_info.folder_name)
		LoadLevel.selected = -1
		return level_info
	else: AudioMaster.play_sfx("UnconfirmDefault")
	return null
func _queue_free() -> void:
	_on_save_level_pressed()
	load_world.emit(null)

var build_folders: Array = ["res://assets/models/"]
var selected_item_pos: Array
var folder_pos: Array

func on_load_tab(i: int):
	current_page = 1
	for child in Tabs.get_children():
		match child.get_index():
			i: child.modulate = Helper.RED
			_: child.modulate = Helper.BASE
	folder_pos = [i + 1]
	on_load_folder()
func on_setup_tabs(current_folder: Array = build_folders) -> void:
	var i: int = 1
	for directory in DirAccess.get_directories_at(get_folder_path()):
		folder_pos.append(i)
		current_folder.append([directory + "/"])
		var fpath: String = get_folder_path()
		on_setup_tabs(current_folder[i])
		if Array(DirAccess.get_files_at(fpath)).any(func(x: String): return x.ends_with(".glb") and x[0] != "_" and !x[x.length() - 5].is_valid_int()):
				
			for file in Array(DirAccess.get_files_at(fpath)).filter(func(x: String): return x.ends_with(".glb") and x[0] != "_" and !x[x.length() - 5].is_valid_int()):
				current_folder[i].append(file)
				
		folder_pos.remove_at(folder_pos.size() - 1)
		i += 1
func get_item_name(pos: Array = folder_pos) -> String:
	var arr: Array = build_folders
	for i in range(pos.size()):
		if i == pos.size() - 1: return arr[pos[i]]
		else: arr = arr[pos[i]]
	return ""
	
func get_folder_path(pos: Array = folder_pos, get_item: bool = false, from_fol: bool = false, get_type: bool = true) -> String:
	var path: String = build_folders[0] if !from_fol else ""
	var arr: Array = build_folders
	var i: int = 1
	
	for key in pos:
		if !get_item or get_item and i != pos.size():
			arr = arr[key]
			path += arr[0]
		else: path += arr[key]
		if from_fol and i == 1: path = ""
		i += 1
	if pos.size() > 2 and pos[0] == 4 and get_item and from_fol:
		var n: Array = path.split("/")
		n.remove_at(0)
		path = n.pop_front()
		for j in n: path += "/" + j
	if get_item and get_type: path = get_selected_item_type_path(path)
	return path
	
func get_folder_contents(pos: Array = folder_pos) -> Array:
	var contents: Array = build_folders
	for key in pos:
		contents = contents[key]
	return contents

var loaded_items: Array
var current_page: int = 1
const ITEM_COUNT_ONE_PAGE: int = 12

func is_in_selection_folder() -> bool:
	if selected_item_pos.size() == folder_pos.size() + 1:
		for i in range(folder_pos.size()):
			if folder_pos[i] != selected_item_pos[i]:
				return false
		return true
	return false

func on_load_folder() -> void:
	item_rects = []
	BackArrow.visible = !(folder_pos.size() == 0)
	$BuildMenu/LoadedMenu/PRLeftArrow.disabled = (current_page == 1)
	$BuildMenu/LoadedMenu/PRRightArrow.disabled = ceil(float((get_folder_contents().size() - 1)) / ITEM_COUNT_ONE_PAGE) <= current_page

	loaded_items = []
	for child in Items.get_children(): child.queue_free()
	BuildMenuWorld.clear_items()
	
	var skip_first: bool = true
	var contents: Array = get_folder_contents()
	for i in range((current_page - 1) * ITEM_COUNT_ONE_PAGE, min(contents.size(), (current_page * ITEM_COUNT_ONE_PAGE) + 1)):
		var item_contents: Variant = contents[i]
		if !skip_first:
			var item: Control
			match typeof(item_contents):
				TYPE_ARRAY:
					item = preload("res://scenes/screens/level_editor/build_menu/folder.tscn").instantiate()
					item.get_node("Label").text = item_contents[0].left(-1).capitalize()
					item.get_node("Button").pressed.connect(on_folder_pressed.bind(item_contents[0]))
				TYPE_STRING:
					item = preload("res://scenes/screens/level_editor/build_menu/item.tscn").instantiate()
					if item_contents[0].is_valid_int():
						match folder_pos[0]:
							1: item.get_node("Label").text = "Ground"
							3: item.get_node("Label").text = "Wall"
					else: item.get_node("Label").text = item_contents.left(-4).capitalize()
					BuildMenuWorld.add_item(get_folder_path(folder_pos + [i], true, false, false))
					item.get_node("Button").pressed.connect(on_item_pressed.bind(i))
					item.get_node("PROutside").modulate = loaded_area.primary_color
					
					if folder_pos + [i] in favorites:
						item.get_node("Label").text += " ★"
					
			Items.add_child(item)
			loaded_items.append(item)
		else: skip_first = false
	
	var xy := Vector2.ZERO
	for item in loaded_items:
		item.position += xy
		if item.scene_file_path.ends_with("item.tscn"): 
			BuildMenuWorld.position_item(xy)
		xy.x += 200
		if xy.x == 1200:
			xy.y += 150
			xy.x = 0
	modulate_items()
	if !is_in_selection_folder(): clear_item_types()
	else: type_button_factory()
	
func clear_item_types() -> void: 
	for child in ItemTypes.get_children(): child.queue_free()
	max_item_types = 0
	
func _on_change_page_pressed(i: int) -> void:
	var old_current_page: int = current_page
	current_page = clamp(current_page + i, 1, ceil(float((get_folder_contents().size() - 1)) / ITEM_COUNT_ONE_PAGE))
	if current_page != old_current_page:
		on_load_folder()
func on_folder_pressed(folder_name: String) -> void:
	var j: int = 0
	for item in get_folder_contents():
		if j > 0 and folder_name == item[0]:
			folder_pos.append(j)
		j += 1
	on_load_folder()
func on_item_pressed(i: int) -> void:
	if selected_item_pos == folder_pos + [i]: deselect_item()
	else:
		if selected_item_type > 0 and selected_item_pos[selected_item_pos.size() - 2] == folder_pos[folder_pos.size() - 1]:
			selected_item_type = 0
			replace_build_menu_item()
		selected_item_pos = folder_pos + [i]
		selected_item_type = 0
		type_button_factory()
		modulate_items()
		on_load_model()

func get_selected_item_type_path(path: String) -> String:
	if selected_item_type > 0 and is_in_selection_folder(): return path.left(-4) + str(selected_item_type) + ".glb"
	return path

func type_button_factory() -> void:
	clear_item_types()
	var fpath: String = get_folder_path(selected_item_pos, true, false, false)
	var item_btn: Control = Items.get_children().filter(func(x: Node): return !x.is_queued_for_deletion())[get_selected_item_index() - 1]
	var farray: Array = fpath.split("/")
	var fitem: String = farray[farray.size() - 1].left(-4)
	fpath = ""
	for j in range(farray.size()):
		if j < farray.size() - 1:
			fpath += farray[j] + "/"
	
	ItemTypes.global_position = Vector2(item_btn.global_position.x + 95, item_btn.global_position.y)
	var fexists: bool = false
	var xy := Vector2.ZERO
	for n in range(1, 9):
		if FileAccess.file_exists(fpath + fitem + str(n) + ".glb"):
			if fexists == false: xy = create_type_button(0, xy)
			xy = create_type_button(n, xy)
			fexists = true

func create_type_button(i: int, xy: Vector2) -> Vector2:
	var btn := Button.new()
	ItemTypes.add_child(btn)
	btn.text = str(i)
	btn.size = Vector2(20, 20)
	btn.position = xy
	btn.pressed.connect(on_type_button_pressed.bind(i))
	max_item_types += 1
	if i == selected_item_type: 
		btn.modulate = Helper.RED
		replace_build_menu_item()
		
	xy.x += 25
	if xy.x >= 100:
		xy.y += 40
		xy.x = 0
	return xy

func replace_build_menu_item() -> void:
	var j: int = selected_item_pos[selected_item_pos.size() - 1]
	selected_item_pos.resize(selected_item_pos.size() - 1)
	var i: int = get_folder_contents(selected_item_pos).filter(func(x: Variant): return typeof(x) == TYPE_ARRAY).size()
	selected_item_pos.append(j)
	BuildMenuWorld.replace_item(j - 1 - i, get_folder_path(selected_item_pos, true))

func on_type_button_pressed(i: int) -> void:
	if i <= max_item_types:
		selected_item_type = i
		for child in ItemTypes.get_children():
			if int(child.text) == i: child.modulate = Helper.RED
			else: child.modulate = Helper.BASE
		on_load_model()
		replace_build_menu_item()

func deselect_item() -> void:
	reset_infos(true)
	clear_item_types()
	if selected_item_type > 0:
		selected_item_type = 0
		replace_build_menu_item()
	selected_item_type = 0
	selected_item_pos = []
	modulate_items()
	on_load_model(false)
	
func on_load_model(_load: bool = true) -> void:
	spin_model = _load
	for child in ModelItem.get_children(): child.queue_free()
	if _load:
		var model: Node3D = load(get_folder_path(selected_item_pos, true)).instantiate()
		ModelItem.add_child(model)
func _on_back_arrow_pressed():
	folder_pos.resize(folder_pos.size() - 1)
	current_page = 1
	on_load_folder()
func modulate_items():
	
	var j: int = get_selected_item_index()
	var n: int = 1
	for btn in Items.get_children():
		if !btn.is_queued_for_deletion():
			btn.modulate = Helper.LIGHT_GREY if n == j else Helper.BASE
			n += 1

func get_item_index(pos: Array) -> Array:
	var item_name: String = get_folder_path(pos, true, true, false).left(-4)
	for i in range(Helper._id_to.size()):
		for j in range(Helper._id_to[i].size()):
			if Helper._id_to[i][j] == item_name \
			or i == 0 and j == 1 and item_name[0].is_valid_int() and item_name.ends_with("tile") \
			or i == 2 and j == 1 and item_name[0].is_valid_int() and item_name.ends_with("wall"):
				return [i, j]
	return []

func get_selected_item_index() -> int:
	var j: int = 0 if selected_item_pos.is_empty() or !(folder_pos.size() == selected_item_pos.size() - 1) else selected_item_pos[selected_item_pos.size() - 1]
	if j > 0:
		for i in range(folder_pos.size()):
			if folder_pos[i] != selected_item_pos[i]:
				j = 0
				break
	return j
	
func on_load_obj_get_area(id: int, tile: Node3D) -> void:
	tile.on_load_obj_get_area(id, loaded_area)

func on_load_wall_get_area(id: int, tile: Node3D) -> void:
	tile.on_load_wall_get_area(id, loaded_area.id)

func on_load_tile_get_area(id: int, tile: Node3D) -> void:
	tile.on_load_tile_get_area(id, loaded_area.id)

func on_is_active_tile(tile: Node3D) -> void:
	active_tile = tile
	reset_active_tile_state(0)

func on_tile_remove(tile: Node3D) -> void:
	if active_tile_state != 1 and !tile.preview_state:
		var infos: Array = on_multi_tiles_info_duplicate(tile)
		reset_active_tile_state(1)
		var i: int = 1
		for item in ["wdeco", "tdeco", "wall", "obj", "tile"]: # potential for a multi-tile bug here
			if item == "tile" and tile.info.tile.type > 0 and active_remove_state in [0, i + 2]:
				tile.info.tile.type = 0
				tile.load_tile(tile.info.tile.id)
				active_remove_state = i + 2
				break
				
			if active_remove_state in [0, i]:
				var ctile: Node3D = center_tile_by_multi_tile(tile, STR_TO_BTAB[item], true)
				if ctile.info[item].id != 0:
					ctile.info.tile.type = 0
					on_tile_remove_specific(ctile, STR_TO_BTAB[item])
					active_remove_state = i
					if item == "tile": on_remove_under_tile(ctile)
					break
					
			if item == "tile" and active_remove_state in [0, i + 1]:
				tile.load_tile(1)
				active_remove_state = i + 1
				break
			i += 1
			if i == 6: infos = []
		on_add_to_history(infos, "REMOVE")
	
var has_rotated_tile_delay: bool = false
const ROTATION_TILE_DELAY: float = 0.2
	
func on_remove_under_tile(tile: Node3D) -> void:
	var p: Array = tile.info.position
	var tiles: Array = tiles_by_multitile(true_tile_by_position([p[0], p[1], p[2], p[3] - 1]), 2).filter(func(x: Node3D): return x != null and x.info.wall.type == 2)
	for _tile in tiles: on_tile_remove_specific(_tile, 2)
	
func on_tile_rotate(tile: Node3D, rotate_direction: int) -> void:
	if !has_rotated_tile_delay:
		has_rotated_tile_delay = true
		var rotate_order: Array = item_id_array[0]
		if highlight: rotate_order = [BTAB_TO_STR[highlight]]
		
		if tile.preview_state.size() == 0: on_add_to_history(on_multi_tiles_info_duplicate(tile), "ROTATE")
		for j in rotate_order:
			if (tile.info[j].id > 0 and !(j == "tile" and tile.info[j].type == 0)) or tile.info[j].multi_tile.size() > 1:
				match j:
					"wall":
						var tiles: Array = tiles_by_multitile(tile, 2, false)
						for _tile in tiles:
							on_rotate_tile_object(_tile, rotate_direction, j, tile.info[j].id)
							
						if 2 in tiles[0].preview_state: 
							on_remove_ghost_arrow(tiles[0])
							on_place_ghost_arrow(tiles[0], tiles[0].info.wall.rotation)
					_:
						if !tile.info[j].multi_tile.size() > 1:
							on_rotate_tile_object(tile, rotate_direction, j, tile.info[j].id)
							
							if STR_TO_BTAB[j] in tile.preview_state:
								on_remove_ghost_arrow(tile)
								on_place_ghost_arrow(tile, tile.info[j].rotation)
							
						else: on_rotate_multi_tile_object(tile, rotate_direction, j)
						
					
		get_tree().create_timer(ROTATION_TILE_DELAY).timeout.connect(func(): has_rotated_tile_delay = false)
	
func on_multi_tiles_info_duplicate(tile: Node3D) -> Array:
	var tiles: Array = [tile]
	for _tiles in item_id_array[0].map(func(x: String): return tiles_by_multitile(tile, STR_TO_BTAB[x])):
		for _tile in _tiles:
			if _tile != null and _tile not in tiles: tiles.append(_tile)
	return tiles.map(func(x: Node3D): return x.info.duplicate(true))
	
func on_multi_tiles_info_duplicates(tiles: Array) -> Array:
	return Helper.flatten(tiles.map(func(x: Node3D): return on_multi_tiles_info_duplicate(x)), true)
	
func on_rotate_multi_tile_object(tile: Node3D, direction: int, j: String) -> bool:
	var btab: int = STR_TO_BTAB[j]
	var p: Vector4 = Helper.position_to_vec(tile.info.position)
	direction *= -1
	
	var tiles: Array = tiles_by_multitile(tile, btab, false).filter(func(x: Node3D): return x != null and x != tile)
	var npos: Array = tiles.map(func(x: Node3D): return Helper.position_to_vec(x.info.position) - p)
	
	for n in range(abs(direction)):
		if direction > 0: npos = npos.map(func(x: Vector4): return Vector4(-x.y, -x.z, -x.x, x.w))
		else: npos = npos.map(func(x: Vector4): return Vector4(-x.z, -x.x, -x.y, x.w))
	
	npos = npos.map(func(x: Vector4): return true_tile_by_position(Helper.vec_to_position(p + x)))
	if !npos.any(func(x: Node3D): return x == null):
		var clamped_direction: int = clamp(direction * -1, -1, 1)
		for i in range(abs(direction)):
			apply_rotation(tile, clamped_direction, j)
		if !(STR_TO_BTAB[j] in tile.preview_state):
			var odatas: Array = []
			for _tile in tiles:
				odatas.append(_tile.info[j].duplicate(true)) 
				_tile.info[j] = EMPTY_DATA[btab].duplicate(true)
			
			for _tiles in npos.map(func(x: Node3D): return tiles_by_multitile(x, btab)):
				for _tile in _tiles:
					if _tile != null and _tile != tile:
						if _tile not in npos: _tile.info[j] = EMPTY_DATA[btab].duplicate(true)
						if _tile not in tiles: tiles.append(_tile)
			
			var multi_tile: Array = [tile.info.position]
			for i in range(odatas.size()):
				npos[i].info[j] = odatas[i]
				npos[i].info[j].rotation = tile.info[j].rotation
				multi_tile.append(npos[i].info.position)
			
			var multis: Array = multi_tile.map(func(x: Array): return true_tile_by_position(x))
			for i in range(multis.size()):
				if multis[i] != null and multis[i].info[j].id > 0:
					var val: Array = multi_tile[0].duplicate(true)
					multi_tile[0] = multi_tile[i].duplicate(true)
					multi_tile[i] = val
					break
					
			for _tile in npos: _tile.info[j].multi_tile = multi_tile.duplicate(true)
			tile.info[j].multi_tile = multi_tile
			tiles.append(tile)
			for _tile in tiles: _tile.call("load_" + j, _tile.info[j].id)
			return true
		else:
			var multi_tile: Array = [tile.info.position]
			for i in range(npos.size()): multi_tile.append(npos[i].info.position)
			tile.info[j].multi_tile = multi_tile
			on_preview_tiles(tile, tile.info.duplicate(true), STR_TO_BTAB[j])
	return false
	
const KEEP_ROTATION_DICT: Dictionary = {
	"tile": 0,
	"obj": 1,
	"wall": 2,
	"wdeco": 2,
	"tdeco": 3,
}

const STR_TO_BTAB: Dictionary = {
	"tile": 0,
	"obj": 1,
	"wall": 2,
	"tdeco": 3,
	"wdeco": 4,
}

const BTAB_TO_STR: Dictionary = {
	0: "tile",
	1: "obj",
	2: "wall",
	3: "tdeco",
	4: "wdeco",
}
	
func apply_rotation(tile: Node3D, direction: int, j: String) -> void:
	var old_rotation: int = tile.info[j].rotation
	tile.info[j].rotation = clamp(tile.info[j].rotation + direction, 0, 5)
	if old_rotation == tile.info[j].rotation: tile.info[j].rotation = 0 if old_rotation == 5 else 5
	if Settings.keep_rotation: keep_rotation[KEEP_ROTATION_DICT[j]] = tile.info[j].rotation
	
func on_rotate_tile_object(tile: Node3D, direction: int, j: String, id: int):
	apply_rotation(tile, direction, j)
	tile.call("load_" + j, id)
	
func on_tile_interact(tile: Node3D) -> void:
	if move_tile == null:
		reset_active_tile_state(2)
		on_tiles_selected([tile])
	elif !is_moving: on_preview_tiles_new_tile(original_move_tile); on_tile_menu_move_finished()
	
func on_set_tile_material(tile: Node3D, highlights: Array, set_override: bool = true) -> void:
	for i in highlights:
		for child in tile.get_node(BTAB_TO_STR[i]).get_children():
			if !child.is_queued_for_deletion():
				for mesh_instance in child.get_children():
					mesh_instance.set_surface_override_material(0, preload("res://assets/materials/base_materials/base_material_half_transparent.tres") if set_override else null)
func on_tile_select() -> void:
	if move_tile == null:
		if active_tile_state != 3:
			reset_active_tile_state(3)
			if load_infos:
				var load_tiles: Array = []
				for i in load_infos:
					var tile: Node3D = true_tile_by_position(i.position)
					on_remove_ghost_arrow(tile)
					var _highlight: Array = []
					for n in range(5):
						var b: String = BTAB_TO_STR[n]
						var is_centric: bool = tile.info[b].id > 0 and (tile.info[b].multi_tile.size() == 0 or tile.info[b].multi_tile[0] == tile.info.position)
						var mt: int = tile.info[b].multi_tile.size()
						
						if ((tile.info[b].id > 0 or mt > 0) and !(0 in tile.preview_state) and tile.info.tile.id == 0 \
						and (mt == 0 or tile.info[b].multi_tile[0][3] == tile.info.position[3])):
							if tile not in load_tiles: load_tiles.append(tile)

						if n == 2 or is_centric: 
							_highlight.append(n)
					
					on_set_tile_material(tile, _highlight, false)
					tile.preview_state = []
				
				for tile in load_tiles: on_load_tile(tile, 1, 0, 0, true)
				if load_infos.size() == 1 and load_infos[0].tile.id > 0:
					var tile: Node3D = true_tile_by_position(load_infos[0].position)
					on_load_tile(tile, tile.info.tile.id, tile.info.tile.rotation, tile.info.tile.type, true)
				
				on_add_to_history(bs_infos.duplicate(true), "PLACE")
				reset_infos()
				
			elif active_tile and active_tile in selection_tiles:
				on_call_selection_callable(active_tile)
	elif !is_moving and Input.is_action_just_pressed("LeftClick"): on_tile_menu_move_finished()

func item_pos_to_str(pos: Array) -> String:
	if pos[0] < 4: return BTAB_TO_STR[pos[0] - 1]
	elif pos[1] == 1: return "tdeco"
	else: return "wdeco"

func item_pos_to_btab(pos: Array) -> int:
	if pos[0] < 4: return pos[0] - 1
	elif pos[1] == 1: return 3
	return 4

func on_load_tile(tile: Node3D, id: int, rot: int, type: int, create_wall: bool = true) -> void:
	tile.info.tile = {"id": id, "rotation": rot, "type": type, "multi_tile": []}
	tile.load_tile(id)
	if create_wall and Settings.elevation_fill: create_elevation_fill(tile)

func create_elevation_fill(tile: Node3D) -> void:
	var f: bool = Settings.tile_walls
	Settings.tile_walls = true
	var p: Array = tile.info.position
	var load_id: int = 1
	#if tile.info.tile.id in [3, 4]: load_id = tile.info.tile.id
	
	for i in range(p[3] - 1, -1, -1):
		var _tile: Node3D = true_tile_by_position([p[0], p[1], p[2], i])
		if _tile and _tile.info.tile.id > 0  and _tile.info.tile.type == 0 and ["wall", "obj", "tdeco", "wdeco"].all(func(x: String): return _tile.info[x].id == 0):
			if _tile.info.position[3] == 0:
				on_add_to_history([_tile.info.duplicate(true)], "ELEVATION")
				on_load_wall(_tile, load_id, 0, 2, p[3], 1)
			#if tile.info.tile.id in [3, 4]: on_load_tile(_tile, tile.info.tile.id, 0, 0)
			break
	Settings.tile_walls = f

func on_load_tdeco(tile: Node3D, id: int, rot: int, type: int, _create_tile: bool = true) -> void:
	on_create_multi_tile_object(tile, 3, {"id": id, "rotation": rot, "type": type, "multi_tile": []})
	if _create_tile and tile.info.tile.id == 0: on_load_tile(tile, 1, 0, 0)
	
func on_load_wdeco(tile: Node3D, id: int, rot: int, type: int, _create_tile: bool = true) -> void:
	on_create_multi_tile_object(tile, 4, {"id": id, "rotation": rot, "type": type, "multi_tile": []})
	if _create_tile and tile.info.tile.id == 0: on_load_tile(tile, 1, 0, 0)

func on_load_obj(tile: Node3D, id: int, rot: int, type: int, _create_tile: bool = true):
	on_create_multi_tile_object(tile, 1, {"id": id, "rotation": rot, "type": type, "multi_tile": [], "obj_info": []})
	if _create_tile and tile.info.tile.id == 0: on_load_tile(tile, 1, 0, 0)

const EMPTY_DATA: Dictionary = {
	0: {"id": 0, "type": 0, "rotation": 0, "multi_tile": []},
	1: {"id": 0, "type": 0, "rotation": 0, "multi_tile": [], "obj_info": []},
	2: {"id": 0, "type": 0, "rotation": 0, "multi_tile": [], "tile_wall": 0},
	3: {"id": 0, "rotation": 0, "type": 0, "multi_tile": []},
	4: {"id": 0, "rotation": 0, "type": 0, "multi_tile": []},
}

func on_create_multi_tile_object(tile: Node3D, btab: int, data: Dictionary) -> void:
	var b: String = BTAB_TO_STR[btab]
	var positions: Array = Helper.return_multi_tile([btab, data.id]).map(func(x: Array): return range(x.size()).map(func(i: int): return x[i] + tile.info.position[i]))
	
	on_tile_remove_specific(tile, btab)
	tile.info[b].multi_tile = positions
	var tiles: Array = tiles_by_multitile(tile, btab)
	for i in range(tiles.size()):
		if tiles[i] != null:
			if i == 0: tiles[i].info[b] = data
			else: tiles[i].info[b] = EMPTY_DATA[btab].duplicate(true)
			tiles[i].info[b].multi_tile = positions
			tiles[i].call("load_" + b, tiles[i].info[b].id)
	
func on_tile_remove_specific(tile: Node3D, btab: int) -> void:
	var b: String = BTAB_TO_STR[btab]
	for _tile in tiles_by_multitile(tile, btab):
		if _tile != null:
			_tile.info[b] = EMPTY_DATA[btab].duplicate(true)
			if !remove_midair_tile(_tile):
				_tile.call("load_" + b, tile.info[b].id)
		
func on_load_wall(tile: Node3D, id: int, rot: int, type: int, multi_tile_height: int, tile_wall: int, _create_tile: bool = true) -> void:
	tile_wall = set_tile_wall_multi_tile(tile, multi_tile_height, tile_wall)
	var tiles: Array = tiles_by_multitile(tile, 2)
	for i in range(tiles.size()):
		var _tile: Node3D = tiles[i]
		if i == 0: 
			_tile.info.wall = {"id": id, "rotation": rot, "type": type, 
			"multi_tile": tile.info.wall.multi_tile if tiles.size() > 1 else [], 
			"tile_wall": tile_wall if i == tiles.size() - 1 else 0}
		else:
			_tile.info.wall = {"id": id, "rotation": rot, "type": type,
			"multi_tile": tile.info.wall.multi_tile,
			"tile_wall": tile_wall if i == tiles.size() - 1 else 0}
		_tile.load_wall(id)
	if _create_tile and tile.info.tile.id == 0: on_load_tile(tile, 1, 0, 0)
	
func set_tile_wall_multi_tile(tile: Node3D, height: int, tile_wall: int) -> int:
	tile.info.wall.multi_tile = []
	if height == 0:
		height = 1
		tile_wall = 2
		
		
	for i in range(height):
		tile.info.wall.multi_tile.append([tile.info.position[0], tile.info.position[1], tile.info.position[2], tile.info.position[3] + i])
	if tile.info.wall.multi_tile.size() < 1: tile.info.wall.multi_tile = []
	return tile_wall
	
func tiles_by_multitile(tile: Node3D, btab: int, prevent_preview: bool = true) -> Array:
	if tile and (prevent_preview and !tile.preview_state) or !prevent_preview:
		var b: String = BTAB_TO_STR[btab]
		if tile.info[b].multi_tile.size() > 1:
			return tile.info[b].multi_tile.map(func(x: Array): return true_tile_by_position(x, true))
		return [true_tile_by_position(tile.info.position)]
	return []
	
func true_tile_by_position(pos: Array, _create_tile: bool = false) -> Node3D:
	if pos[3] >= 0:
		for tile in World.get_node("Tiles/" + str(pos[3])).get_children().filter(func(x: Node3D): return !x.is_queued_for_deletion()):
			if Helper.compare_by_value(tile.info.position, pos): return tile
		if _create_tile and pos[3] > 5:
			return create_empty_tile_with_info(Vector3(pos[0], pos[1], pos[3]))
	return null
	
func tiles_by_position(pos: Array) -> Array:
	var multi_tile: Array = []
	for tile in World.get_node("Tiles/" + str(pos[3])).get_children():
		if Helper.compare_by_value(tile.info.position, pos):
			if !tile.multi_tile:
				for _pos in tile.multi_tile:
					if _pos[3] > 5: multi_tile.append(create_tile(Vector3(_pos[0], _pos[1], _pos[3])))
					else: multi_tile.append(true_tile_by_position(_pos))
			else: return [tile]
		
	if !multi_tile and pos[3] > 5: return [create_tile(Vector3(pos[0], pos[1], pos[3]))]
	return multi_tile

func create_empty_tile_with_info(pos: Vector3) -> Node3D:
	var tile: Node3D = create_tile(pos)
	tile.info = return_empty_info([pos.x, pos.y, -pos.x - pos.y, pos.z])
	tile.get_node("DetectMouse").collision_layer = 0
	return tile
	
func return_empty_info(pos: Array) -> Dictionary:
	return {
		"tile": EMPTY_DATA[0].duplicate(true),
		"obj": EMPTY_DATA[1].duplicate(true),
		"wall": EMPTY_DATA[2].duplicate(true),
		"tdeco": EMPTY_DATA[3].duplicate(true),
		"wdeco": EMPTY_DATA[4].duplicate(true),
		"position": pos.duplicate(),
		}
	
func reset_active_tile_state(i: int) -> void:
	active_tile_state = i
	if i == 4: active_remove_state = 0

func load_settings_mini_menu() -> void:
	if !block_screen and loaded_area:
		reset_infos(true)
		block_screen = true
		reset_mblocker_rects()
		var mini_menu: Control = preload("res://scenes/screens/level_editor/build_menu/settings_mini_menu.tscn").instantiate()
		Helper.load_area_colors(mini_menu, loaded_area.primary_color, loaded_area.accent_color)
		add_child(mini_menu)
		mini_menu.queued.connect(on_file_loader_queued)

func setup_elevation() -> void:
	$ElevationNumber.text = str(Settings.level_editor_elevation)
	for child in World.get_node("Tiles").get_children():
		var p: bool = child.name == str(Settings.level_editor_elevation)
		for tile in child.get_children(): 
			tile.get_node("DetectMouse").collision_layer = 64 if p else 0

func set_heightbuttons_modulate() -> void:
	for btn in HeightButtons.get_children():
		btn.modulate = Helper.RED if btn.name == str(Settings.default_wall_height) else Helper.BASE

	for btn in ElevationButtons.get_children():
		btn.modulate = Helper.RED if btn.name == str(Settings.level_editor_elevation) else Helper.BASE

func on_hover_tile(tile: Node3D) -> void:
	if !(!Settings.highlight_empty_tiles and tile.info.tile.id == 0) and (SelectionBox == null):
		if tile in selection_tiles: tile.load_tile(tile.info.tile.id)
		elif move_tile: on_buffer_preview_tile(tile)
		elif active_remove_state == 0:
			if selected_item_pos.size() > 0:
				var btab: int = item_pos_to_btab(selected_item_pos)
				if !(tile.info[BTAB_TO_STR[btab]].type == selected_item_type and tile.info[BTAB_TO_STR[btab]].id == get_item_index(selected_item_pos)[1]):
					var tile_info: Dictionary = create_tile_info(tile)
					if !tile_info.is_empty(): on_preview_tiles(tile, tile_info, btab)
					else: reset_infos(true)
				else: reset_infos(true)
			elif tile.info.tile.type == 0: tile.load_tile(2)

var BufferTile: Node3D
@onready var BufferTimer: Timer = $BufferPreviewTileTimer
const PREVIEW_TILE_BUFFER_ZONE = Vector2(8, 8)
func on_buffer_preview_tile(tile: Node3D) -> void:
	if abs(old_mpos - get_viewport().get_mouse_position()) < PREVIEW_TILE_BUFFER_ZONE:
		on_preview_tiles_new_tile(tile)
	else: BufferTimer.start(); BufferTile = tile

func create_tile_info(tile: Node3D) -> Dictionary:
	var info: Dictionary = {"position": tile.info.position.duplicate(true)}
	for i in range(item_id_array[0].size()):
		var b: String = item_id_array[0][i]
		if i != item_pos_to_btab(selected_item_pos):
			info.merge({b: tile.info[b].duplicate(true)})
		else:
			var empty: Dictionary = EMPTY_DATA[i].duplicate(true)
			var idx: Array = get_item_index(selected_item_pos)
			empty.id = idx[1]
			empty.type = selected_item_type
			empty.rotation = tile.info.tile.rotation if !Settings.keep_rotation else keep_rotation[KEEP_ROTATION_DICT[b]]
			match b:
				"wall": create_wall_multi_tile(tile, empty)
				"tile": pass
				_: if !create_any_multi_tile(tile, idx, empty): return {}
			
			info.merge({b: empty})
	return info

func create_wall_multi_tile(tile: Node3D, empty: Dictionary) -> void:
	empty.multi_tile = []
	var height: int = Settings.default_wall_height
	if height == 0:
		empty.tile_wall = 2
		height = 1
	else: empty.tile_wall = Settings.tile_walls
	if height > 1:
		for j in range(height):
			empty.multi_tile.append([tile.info.position[0], tile.info.position[1], tile.info.position[2], tile.info.position[3] + j])

func tile_exists(pos: Array) -> bool:
	return World.get_node("Tiles/" + str(pos[3])).get_children().any(func(x: Node3D): return Helper.compare_by_value(x.info.position, pos))

func create_any_multi_tile(tile: Node3D, idx: Array, empty: Dictionary) -> bool:
	var mt: Array = Helper.return_multi_tile(idx)
	if mt.size() > 1:
		empty.multi_tile = mt.map(func(x: Array): return [x[0] + tile.info.position[0], x[1] + tile.info.position[1], x[2] + tile.info.position[2], x[3] + tile.info.position[3]])
		if empty.rotation > 0:
			empty.multi_tile.remove_at(0)
			var p: Vector4 = Helper.position_to_vec(tile.info.position)
			var vec_poses: Array = empty.multi_tile.map(func(x: Array): return Helper.position_to_vec(x) - p)
			for n in range(empty.rotation):
				vec_poses = vec_poses.map(func(x: Vector4): return Vector4(-x.z, -x.x, -x.y, x.w))
			empty.multi_tile = vec_poses.map(func(x: Vector4): return Helper.vec_to_position(p + x))
			empty.multi_tile.push_front(tile.info.position)
		return empty.multi_tile.all(func(x: Array): return x[3] > 5 or tile_exists(x))
	return true
var load_infos: Array = []
var bs_infos: Array = []

func reset_infos(true_reset: bool = false) -> void:
	highlight = 0
	if true_reset:
		for i in bs_infos:
			for j in load_infos:
				if i.position == j.position:
					var tile: Node3D = true_tile_by_position(i.position)
					if tile != null:
						tile.info = i
						on_remove_ghost_arrow(tile)
						if !remove_midair_tile(tile):
							tile.preview_state = []
							reload_tile(tile)
	
	load_infos = []
	bs_infos = []

var ghost_arrow: PackedScene = preload("res://assets/env/level_editor/ghost_arrow.glb")
var highlight: int = 0
func on_preview_tiles(tsi: Node3D, info: Dictionary, _highlight: int) -> void:
	reset_infos(true)
	highlight = _highlight
	var late_load_info: Array = []
	if !(tsi.info.wall.id > 0 and tsi.info.wall.multi_tile.size() > 0 and tsi.info.wall.multi_tile[0] != tsi.info.position):
		add_to_bs_infos(tsi.info)
		for btab in range(5):
			if tsi.info[BTAB_TO_STR[btab]].multi_tile.size() > 1:
				for tile in tiles_by_multitile(tsi, highlight).filter(func(x: Node3D): return x != null and x != tsi):
					add_to_bs_infos(tile.info)
					if btab == highlight:
						tile.info[BTAB_TO_STR[highlight]] = EMPTY_DATA[highlight].duplicate(true)
						late_load_info.append(tile.info)
					
		tsi.info = info
		add_to_load_infos(tsi.info)
		for b in item_id_array[highlight + 1]:
			if tsi.info[b].multi_tile.size() > 1:
				var btab: int = STR_TO_BTAB[b]
				for tile in tiles_by_multitile(tsi, btab):
					if tile != null and tile != tsi:
						add_to_bs_infos(tile.info)
						for _tile in tiles_by_multitile(tile, btab):
							if _tile != null and _tile != tile:
								add_to_bs_infos(_tile.info)
								if _tile not in load_infos:
									_tile.info[b] = EMPTY_DATA[btab].duplicate(true)
									late_load_info.append(_tile.info)
						tile.info[b] = EMPTY_DATA[btab].duplicate(true)
						if b == "wall":
							tile.info.wall = EMPTY_DATA[2].duplicate(true)
							tile.info.wall.id = info.wall.id
							tile.info.wall.rotation = info.wall.rotation
							tile.info.wall.type = info.wall.type
							
							if Helper.compare_by_value(tile.info.position, info.wall.multi_tile[info.wall.multi_tile.size() - 1]):
								tile.info.wall.tile_wall = info.wall.tile_wall
								tsi.info.wall.tile_wall = 0
								
						tile.info[b].multi_tile = info[b].multi_tile
						add_to_load_infos(tile.info)
						
		for _info in late_load_info:
			add_to_load_infos(_info)
		
		on_place_ghost_arrow(tsi, tsi.info[BTAB_TO_STR[highlight]].rotation)
		for _info in load_infos:
			var tile: Node3D = true_tile_by_position(_info.position, true)
			tile.preview_state = [highlight]
			reload_tile(tile)

func on_remove_ghost_arrow(tile: Node3D) -> void:
	for child in tile.get_node("extra/GhostArrow").get_children(): child.queue_free()
	
func on_place_ghost_arrow(tile: Node3D, _rotation: int) -> void:
	var GhostArrow: Node3D = ghost_arrow.instantiate()
	tile.get_node("extra/GhostArrow").add_child(GhostArrow)
	GhostArrow.rotation_degrees.y = 60 * _rotation

func add_to_load_infos(info: Dictionary):
	if !load_infos.any(func(x: Dictionary): return x.position == info.position): load_infos.append(info)

func reload_tile(tile: Node3D) -> void:
	for b in item_id_array[0]: tile.call("load_" + b, tile.info[b].id)

func add_to_bs_infos(info: Dictionary) -> void:
	if !bs_infos.any(func(x: Dictionary): return x.position == info.position): bs_infos.append(info.duplicate(true))
			
func on_call_selection_callable(tile: Node3D) -> void:
	selection_callable.call(tile)
		
var original_elevation: int = -1
func on_set_selection_tiles(tiles: Array = [], c: Callable = Callable()) -> void:
	if original_elevation > -1: 
		Settings.level_editor_elevation = original_elevation
		original_elevation = -1
		setup_elevation()
		
	selection_tiles = tiles
	selection_callable = c
	
	if tiles.size() > 0 and tiles[0].info.position[3] != Settings.level_editor_elevation:
		original_elevation = Settings.level_editor_elevation
		Settings.level_editor_elevation = tiles[0].info.position[3]
		setup_elevation()
	
	if selection_tiles.size() == 1: on_call_selection_callable(tiles[0])
	elif tiles.size() > 0: on_tile_menu_highlight_tiles(1, tiles)
		
signal update_tile_menu

var TileMenuGlobal: Control
var tile_menu_tiles: Array
func on_tiles_selected(tiles: Array) -> void:
	if !Settings.select_empty_tiles: tiles = tiles.filter(func(x: Node3D): return x.info.tile.id != 0)
	if tiles.size() > 0 and !block_screen and loaded_area:
		active_tile = null
		reset_infos(true)
		for t in tiles: if t.info.tile.type == 0: t.load_tile(2)
		block_screen = true
		reset_mblocker_rects()
		
		var tile_menu: Control = preload("res://scenes/screens/level_editor/build_menu/tile_menu.tscn").instantiate()
		update_tile_menu.connect(tile_menu.on_update_tile_menu)
		TileMenuGlobal = tile_menu
		tile_menu_tiles = tiles
		tile_menu.tiles = tiles
		add_child(tile_menu)
		for sig in tile_menu.signals: 
			sig.connect(get("on_tile_menu_" + sig.get_name()))
		update_tile_menu.emit()
		
func on_update_tile_menu() -> void:
	if tile_menu_tiles.size() > 0:
		var ray: RayCast3D = World.get_node("TileRaycast")
		var tiles: Array = World.get_node("Tiles/" + str(Settings.level_editor_elevation)).get_children()
		if !Settings.select_empty_tiles: tiles = tiles.filter(func(x: Node3D): return x.info.tile.id != 0)
		ray.position = World.get_node("MovementCamera").position
		ray.target_position = (World.get_node("MovementCamera").project_ray_origin(get_viewport().get_mouse_position())) + World.get_node("MovementCamera").project_ray_normal(get_viewport().get_mouse_position()) * 300
		ray.force_raycast_update()
		if ray.get_collider():
			var tile: Node3D = ray.get_collider().get_parent()
			if tile in tile_menu_tiles:
				if tile_menu_tiles.size() > 1: # important its here
					tile_menu_tiles.erase(tile)
					tile.load_tile(tile.info.tile.id)
			else: tile_menu_tiles.append(tile); tile.load_tile(2)
			update_tile_menu.emit()

func on_tile_menu_queued(TileMenu: Control, affect: bool = true) -> void:
	if !file_loader_loaded and TileMenu and !TileMenu.is_queued_for_deletion():
		if move_tile == null and affect:
			on_set_selection_tiles()
			block_screen = false
			for tile in TileMenu.tiles: on_tile_exit_mouse(tile)
			var tile: Node3D = on_ray_mouse()
			if tile: active_tile = tile; active_tile.can_press = true
		reset_mblocker_rects()
		TileMenu.queue_free()

func on_tile_menu_highlight_tiles(state: int, tiles: Array) -> void:
	for tile in tiles:
		var i: int = 2 if state > 0 else tile.info.tile.id
		tile.load_tile(i)

func on_tile_exit_mouse(tile: Node3D) -> void:
	if !block_screen and move_tile == null:
		if tile.info.tile.type == 0: tile.load_tile(tile.info.tile.id)
		var _tile: Node3D = on_ray_mouse()
		if _tile == null: reset_infos(true)
		
	elif tile in selection_tiles:
		tile.load_tile(2)

var item_id_array: Array = [["tile", "obj", "wall", "tdeco", "wdeco"], ["tile"], ["obj"], ["wall"], ["tdeco"], ["wdeco"]]
func on_tile_menu_rotate_full(item: int, i: int, tiles: Array) -> void:
	on_add_to_history(on_multi_tiles_info_duplicates(tiles), "FULL-ROTATE")
	for tile in tiles:
		for j in item_id_array[item]:
			var load_id: int = (2 if j == "tile" else tile.info[j].id) if tile.info[j].type == 0 else tile.info[j].id
			if Settings.keep_rotation: keep_rotation[KEEP_ROTATION_DICT[j]] = i
			if j == "wall":
				var _tiles: Array = tiles_by_multitile(tile, 2)
				for _tile in _tiles:
					_tile.info[j].rotation = i
					_tile.call("load_wall", load_id)
			elif tile.info[j].multi_tile.size() > 1:
				var ctile: Node3D = center_tile_by_multi_tile(tile, STR_TO_BTAB[j])
				if tile == ctile:
					var rotation_base: int = i - tile.info[j].rotation
					if rotation_base != 0: on_rotate_multi_tile_object(tile, rotation_base, j)
			else:
				tile.info[j].rotation = i
				tile.call("load_" + j, load_id)
	
func on_tile_menu_rotate_direction(item: int, direction: int, tiles: Array) -> void:
	on_add_to_history(on_multi_tiles_info_duplicates(tiles), "TILES-ROTATE")
	for tile in tiles:
		for j in item_id_array[item]:
			if j != "wall":
				if tile.info[j].multi_tile.size() > 1:
					var ctile: Node3D = center_tile_by_multi_tile(tile, STR_TO_BTAB[j])
					if tile == ctile:
						on_rotate_multi_tile_object(tile, direction, j)
				else: on_rotate_tile_object(tile, direction, j, (2 if j == "tile" else tile.info[j].id) if tile.info[j].type == 0 else tile.info[j].id)
			else:
				for _tile in tiles_by_multitile(tile, 2): 
					on_rotate_tile_object(_tile, direction, j, _tile.info[j].id)
	
func on_tile_menu_delete(item: int, tiles: Array) -> void:
	on_add_to_history(on_multi_tiles_info_duplicates(tiles), "TILES-DELETE")
	for tile in tiles:
		for j in item_id_array[item]:
			if j == "tile": 
				tile.load_tile(1 if item_id_array[item].size() > 1 or tile.info[j].id == 0 else 0)
				on_remove_under_tile(tile)
			else: on_tile_remove_specific(tile, STR_TO_BTAB[j])
			
	update_tile_menu.emit()
	
var selection_callable: Callable
var selection_tiles: Array = []

var copy_item: int
var copy_info: Array
func on_tile_menu_copy(item: int, tiles: Array) -> void:
	copy_info = tiles
	copy_item = item
	
func on_tile_menu_paste(tiles: Array) -> void:
	if copy_info.size() > 0 and tiles.size() > 0:
		var tile: Node3D = on_ray_mouse()
		if tile:
			on_tile_menu_queued(TileMenuGlobal, false)
			for _tile in tiles: _tile.load_tile(_tile.info.tile.id)
			on_tile_menu_move(copy_item, copy_info, 1 if copy_info[0].info.position[3] == tiles[0].info.position[3] else 2)

var bucket_info: Array = []
func on_tile_menu_bucket(item: int, tiles: Array) -> void:
	if tiles.size() == 1:
		bucket_info = []
		for j in item_id_array[item]:
			match j:
				"wall":
					var mt: Array = tiles[0].info.wall.multi_tile
					if mt.size() > 0:
						bucket_info.append([j, true_tile_by_position(mt[mt.size() - 1], true).info.wall.duplicate(true)])
					else: bucket_info.append([j, tiles[0].info[j].duplicate(true)])
				_: bucket_info.append([j, tiles[0].info[j].duplicate(true)])
	else:
		if bucket_info.size() > 0:
			var extra: Array = tiles.duplicate()
			for j in bucket_info: 
				if j[0] == "wall" and j[1].id > 0 and j[1].multi_tile.size() > 0:
					extra = []
					for tile in tiles:
						var p: Array = tile.info.position
						for n in range(0, j[1].multi_tile.size()):
							extra.append(true_tile_by_position([p[0], p[1], p[2], p[3] + n], true))
					break
			on_add_to_history(on_multi_tiles_info_duplicates(extra), "TILES-BUCKET")
			for tile in tiles:
				for j in bucket_info:
					if j[1].multi_tile.size() == 0 or j[1].multi_tile.all(func(x: Array): return [x[0], x[1], x[2]] == [j[1].multi_tile[0][0], j[1].multi_tile[0][1], j[1].multi_tile[0][2]]):
						on_replace_tile_item(tile, STR_TO_BTAB[j[0]], j[1])

func on_replace_tile_item(tile: Node3D, btab: int, info: Dictionary) -> void:
	if tile and !tile.preview_state:
		on_tile_remove_specific(tile, btab)
		tile.info[btab] = info
		on_load(tile, btab, info, true)
	
var original_move_tile: Node3D
var old_infos: Array = []
var move_infos: Array = []
var move_highlights: Array = []
var move_tile: Node3D
var original_infos = []

func on_tile_menu_move(item: int, tiles: Array, copy_mode: int = 0) -> void:
	original_infos = on_multi_tiles_info_duplicates(tiles)
	on_set_selection_tiles(tiles, on_tile_menu_move_center_tile_selected.bind(item, tiles, copy_mode))
	if tiles.size() == 1: 
		on_tile_menu_queued(TileMenuGlobal)
		warp_mouse(get_viewport().get_mouse_position())
	
var is_moving: bool = false
func on_tile_menu_move_center_tile_selected(center_tile: Node3D, item: int, _tiles: Array, copy_mode: int) -> void:
	on_set_selection_tiles()
	if item == 0: move_highlights = range(5)
	else: move_highlights = [item - 1]
	
	var tiles: Array = []
	for tile in _tiles:
		for b in item_id_array[item]: 
			for _tile in tiles_by_multitile(tile, STR_TO_BTAB[b], true):
				if _tile not in tiles: tiles.append(_tile)
	
	var p: Vector4 = Helper.position_to_vec(center_tile.info.position)
	var b: String = item_id_array[item][0]
	for tile in tiles:
		var tile_info: Dictionary = {"position": Helper.vec_to_position(Helper.position_to_vec(tile.info.position) - p)}
		var old_info: Dictionary = {}
		match item:
			0:
				tile_info.merge({"tile": tile.info.tile.duplicate(true), "tdeco": tile.info.tdeco.duplicate(true),
				"wdeco": tile.info.wdeco.duplicate(true), "wall": tile.info.wall.duplicate(true), "obj": tile.info.obj.duplicate(true)})
				
				if copy_mode == 0:
					old_info = return_empty_info(tile.info.position)
					if tile_info.position[3] == center_tile.info.position[3]: old_info.tile.id = 1
				else: old_info = tile.info.duplicate(true)
			_: 
				tile_info.merge({b: tile.info[b].duplicate(true)})
				if copy_mode == 0:
					old_info = {"position": tile.info.position.duplicate(), b: EMPTY_DATA[STR_TO_BTAB[b]].duplicate(true)}
				else: old_info = {"position": tile.info.position.duplicate(), b: tile.info[b].duplicate(true)}
		move_infos.append(tile_info)
		old_infos.append(old_info)
		
		
	move_tile = center_tile
	original_move_tile = center_tile
	for tile in true_tile_by_move_infos():
		tile.load_tile(tile.info.tile.id)
		if copy_mode != 2:
			on_set_tile_material(tile, move_highlights)
	
	is_moving = true
	await get_tree().create_timer(0.2).timeout
	is_moving = false
		
func true_tile_by_move_infos() -> Array:
	return move_infos.map(func(x: Dictionary): 
		return true_tile_by_position(Helper.vec_to_position(Helper.position_to_vec(x.position) + Helper.position_to_vec(move_tile.info.position)), true))\
		.filter(func(x: Node3D): return x != null)

func on_preview_tiles_new_tile(tile: Node3D) -> void:
	if tile != move_tile:
		var op: Vector4 = Helper.position_to_vec(move_tile.info.position)
		move_tile = tile
		var p: Vector4 = Helper.position_to_vec(move_tile.info.position)
		var move_tiles: Array = true_tile_by_move_infos()
		
		for info in old_infos: # revert existing tiles to their original state
			var _tile: Node3D = true_tile_by_position(info.position)
			for b in item_id_array[0]:
				if info.has(b):
					_tile.info[b] = info[b].duplicate(true)
					if !remove_midair_tile(_tile):
						_tile.call("load_" + b, _tile.info[b].id)
					else: break
					
		var tiles: Array = []
		for _tile in move_tiles: # put all the tiles that will be affected in tiles array
			for btab in move_highlights:
				for __tile in tiles_by_multitile(_tile, btab, true).filter(func(x: Node3D): return x != null):
					if __tile not in tiles: tiles.append(__tile)
		
		old_infos = []
		var b: String = BTAB_TO_STR[move_highlights[0]]
		for _tile in tiles: # save the info of all the tiles that will be affected
			var old_info: Dictionary = {}
			match move_highlights.size():
				1: old_info = {"position": _tile.info.position.duplicate(), b: _tile.info[b].duplicate(true)}
				_: old_info = _tile.info.duplicate(true)
			old_infos.append(old_info)
				
		for _tile in move_tiles: # load in the new info of the tiles
			var pp: Vector4 = Helper.position_to_vec(_tile.info.position)
			for info in move_infos:
				if pp - p == Helper.position_to_vec(info.position):
					var offset: Vector4 = p - op
					for btab in move_highlights:
						var _b: String = BTAB_TO_STR[btab]
						info[_b].multi_tile = info[_b].multi_tile.map(func(x: Array): return Helper.vec_to_position(Helper.position_to_vec(x) + offset))
						_tile.info[_b] = info[_b]
						_tile.call("load_" + _b, _tile.info[_b].id)
					break
			on_set_tile_material(_tile, move_highlights)

func on_tile_menu_move_finished() -> void:
	var positions: Array = original_infos.map(func(x: Dictionary): return x.position)
	for info in old_infos:
		if info.position not in positions:
			original_infos.append(info.duplicate(true))
	
	on_add_to_history(original_infos, "TILES-MOVE")
	for _tile in true_tile_by_move_infos():
		on_set_tile_material(_tile, move_highlights, false)
	
	move_tile = null
	original_move_tile = null
	move_infos = []
	original_infos = []
	move_highlights = []
	old_infos = []
	block_screen = false

func on_load(tile: Node3D, btab: int, info: Dictionary, _create_tile: bool = true) -> void:
	info = info.duplicate(true)
	var args: Array = [tile, info.id, info.rotation, info.type]
	match btab:
		2: args += [1 if info.multi_tile.size() == 0 else info.multi_tile.size(), info.tile_wall, _create_tile]
		_: args += [_create_tile]
	
	callv("on_load_" + BTAB_TO_STR[btab], args)

func on_tile_menu_spawn(tiles: Array) -> void:
	if tiles.size() == 1 and loaded_area:
		on_add_to_history(tiles.map(func(x: Node3D): return x.info.duplicate(true)), "SPAWN")
		var FileLoader: Control = preload("res://scenes/editor/file_loader/file_loader.tscn").instantiate()
		var cards: Array = loaded_area.cards.map(func(i: int): return Helper.id_to_dict(i, "Card"))
		match tiles[0].info.obj.id:
			1: cards = cards.filter(func(x: Dictionary): return x != {} and x.r != 1)
			3: cards = cards.filter(func(x: Dictionary): return x != {} and x.r == 0)
			
		FileLoader.on_ready_preselected("Card", cards)
		FileLoader.item_selected.connect(on_card_selected_from_fileloader)
		on_file_loader_loaded(FileLoader)
 
func on_tile_menu_item_type(val: int, item: int, tiles: Array) -> void:
	if tiles.size() == 1 and item != 0:
		
		var _tiles: Array = tiles
		if item == 3: _tiles = tiles_by_multitile(tiles[0], 2)
		on_add_to_history(_tiles.map(func(x: Node3D): return x.info.duplicate(true)), "ITEM-TYPE")
		
		for j in item_id_array[item]:
			if j == "wall": 
				for _tile in _tiles:
					_tile.info[j].type = val
					_tile.call("load_" + j, _tile.info[j].id)
			else:
				tiles[0].info[j].type = val
				tiles[0].call("load_" + j, tiles[0].info[j].id)

var fill_mode: int = 0
func on_fill_pressed(tile: Node3D) -> void:
	if active_tile_state != 5 and tile.info.wall.id not in Helper.exclude_fill and tile.info.tile.id != 0 and !tile.preview_state:
		reset_active_tile_state(5)
		if tile.info.wall.id == 0 and fill_mode in [0, 2]:
			var infos: Array = on_multi_tiles_info_duplicate(tile)
			var infos_positions: Array = infos.map(func(x: Dictionary): return x.position)
			var p: Array = tile.info.position
			for _tile in range(Settings.default_wall_height).map(func(x: int): return true_tile_by_position([p[0], p[1], p[2], p[3] + x], true)):
				if _tile != null and !infos_positions.any(func(x: Array): return Helper.compare_by_value(_tile.info.position, x)): infos.append(_tile.info.duplicate(true))
			
			on_add_to_history(infos, "FILL")
				
			var wall_id: int = 1
			var elevation_positions: Array = World.get_node("Tiles/" + str(tile.info.position[3])).get_children()\
			.map(func(x: Node3D): return Helper.position_to_vec(x.info.position))
			var hex_ids: Array = Helper._hex_neighbours(Helper.position_to_vec(tile.info.position), elevation_positions)
			hex_ids = hex_ids.map(func(x: Vector4): return true_tile_by_position(Helper.vec_to_position(x)))
			hex_ids = hex_ids.filter(func(x: Node3D): return x.info.wall.id > 0 and x.info.wall.id not in Helper.exclude_fill)\
			.map(func(y: Node3D): return y.info.wall.id)
			
			var _total_count: int = 0
			var total_count: int = 0
			for i in hex_ids:
				_total_count = 0
				for j in hex_ids:
					if i == j: total_count += 1
				if total_count > _total_count: total_count = _total_count; wall_id = i
			
			on_load_wall(tile, wall_id, tile.info.wall.rotation, 2, Settings.default_wall_height, Settings.tile_walls)
			fill_mode = 2
			
		elif tile.info.wall.type != 2:
			var mult: int = 0
			if tile.info.wall.type > 2: 
				if fill_mode in [0, 1]:
					mult = -3
					fill_mode = 1
			elif fill_mode in [0, 2]:
				mult = 3
				fill_mode = 2
				
			if mult != 0:
				on_add_to_history(on_multi_tiles_info_duplicate(tile), "FILL")
				var twh: Array = on_find_wall_tile_wall_and_height(tile)
				on_load_wall(tile, tile.info.wall.id, tile.info.wall.rotation, tile.info.wall.type + mult, twh[0], twh[1], true)
		
		elif fill_mode in [0, 1]:
			on_add_to_history(on_multi_tiles_info_duplicate(tile), "FILL")
			var tiles: Array = tiles_by_multitile(tile, 2)
			for _tile in tiles: _tile.info.wall = EMPTY_DATA[2].duplicate(true); _tile.load_wall(0)
			fill_mode = 1

func on_tile_menu_fill_wall(tiles: Array) -> void:
	var wall_ids: Array = tiles.filter(func(x: Node3D): return x.info.wall.id > 0 and x.info.wall.id not in Helper.exclude_fill).map(func(y: Node3D): return y.info.wall.id)
	var _total_count: int = 0
	var total_count: int = 0
	var wall_id: int = 1
	
	for i in wall_ids:
		_total_count = 0
		for j in wall_ids:
			if i == j: total_count += 1
		if total_count > _total_count: total_count = _total_count; wall_id = i
	on_add_to_history(on_multi_tiles_info_duplicates(on_find_wall_tiles(tiles, func(x: int): return x == 0, Settings.default_wall_height)), "TILES-FILL")
	for tile in tiles:
		if tile.info.wall.id == 0:
			on_load_wall(tile, wall_id, tile.info.wall.rotation, 2, Settings.default_wall_height, Settings.tile_walls)
		elif tile.info.wall.type < 2 and tile.info.wall.id not in Helper.exclude_fill:
			var twh: Array = on_find_wall_tile_wall_and_height(tile)
			on_load_wall(tile, tile.info.wall.id, tile.info.wall.rotation, tile.info.wall.type + 3, twh[0], twh[1], true)
	
func on_tile_menu_unfill_wall(tiles: Array) -> void:
	tiles = tiles.filter(func(x: Node3D): return x.info.wall.id > 0 and x.info.wall.id not in Helper.exclude_fill)
	on_add_to_history(on_multi_tiles_info_duplicates(tiles), "TILES-UNFILL")
	for tile in tiles:
		if tile.info.wall.type == 2:
			var _tiles: Array = tiles_by_multitile(tile, 2)
			for _tile in _tiles: _tile.info.wall = EMPTY_DATA[2].duplicate(true); _tile.load_wall(0)
		elif tile.info.wall.type > 2:
			var twh: Array = on_find_wall_tile_wall_and_height(tile)
			on_load_wall(tile, tile.info.wall.id, tile.info.wall.rotation, tile.info.wall.type - 3, twh[0], twh[1], true)

func on_find_wall_tile_wall_and_height(tile: Node3D) -> Array:
	var tile_wall: int = tile.info.wall.tile_wall
	var j: int = tile.info.wall.multi_tile.size() - 1
	if j > 0:
		tile_wall = true_tile_by_position(tile.info.wall.multi_tile[j], true).info.wall.tile_wall
		j += 1
	elif tile_wall != 2:
		j = 1
	else: j = 0
	return [j, tile_wall]
func on_find_wall_tiles(tiles: Array, condition: Callable, height: int) -> Array:
	var extra: Array = []
	for tile in tiles:
		if condition.call(tile.info.wall.id):
			var p: Array = tile.info.position
			for n in range(1, height):
				extra.append(true_tile_by_position([p[0], p[1], p[2], p[3] + n], true))
	for tile in tiles: if tile not in extra: extra.append(tile)
	return extra

func on_tile_menu_wall_height(i: int, tiles: Array) -> void:
	var extra: Array = []
	for tile in tiles:
		if tile.info.wall.id > 0:
			var p: Array = tile.info.position
			for n in range(1, i):
				extra.append(true_tile_by_position([p[0], p[1], p[2], p[3] + n], true))
	
	for tile in tiles: if tile not in extra: extra.append(tile)
	on_add_to_history(on_multi_tiles_info_duplicates(on_find_wall_tiles(tiles, func(x: int): return x > 0, i)), "WALL-HEIGHT")
	for tile in tiles:
		if tile.info.wall.id > 0:
			var _tiles: Array = tiles_by_multitile(tile, 2)
			var tdata: Dictionary = _tiles[0].info.wall.duplicate()
			var tile_wall: int = on_find_wall_tile_wall_and_height(_tiles[0])[1]
			on_tile_remove_specific(_tiles[0], 2)
			on_load_wall(_tiles[0], tdata.id, tdata.rotation, tdata.type, i, tile_wall)

func on_file_loader_loaded(FileLoader: Control):
	FileLoader.queued.connect(on_file_loader_queued)
	if is_instance_valid(TileMenuGlobal): on_tile_menu_queued(TileMenuGlobal, true)
	block_screen = true
	file_loader_loaded = true
	reset_mblocker_rects()
	add_child(FileLoader)

func on_card_selected_from_fileloader(item_info: Dictionary) -> void:
	if tile_menu_tiles.size() == 1:
		tile_menu_tiles[0].info.obj.obj_info = [item_info.id]
		tile_menu_tiles[0].load_obj(tile_menu_tiles[0].info.obj.id)

func remove_midair_tile(tile: Node3D) -> bool:
	if tile.info.position[3] > 5:
		if item_id_array[0].filter(func(x: String): return tile.info[x].multi_tile.size() > 0).size() > 0: 
			return false
		tile.queue_free()
		active_tile_check_deletion()
		return true
	return false

func center_tile_by_multi_tile(tile: Node3D, btab: int, pp: bool = true) -> Node3D:
	if tile.info[BTAB_TO_STR[btab]].multi_tile.size() > 1: 
		return tiles_by_multitile(tile, btab, pp)[0]
	else: return tile

func _on_buffer_preview_tile_timer_timeout():
	if BufferTile: on_preview_tiles_new_tile(BufferTile)
	
const UNDO_REDO_DELAY: float = 0.2
const HISTORY_SIZE: int = 1000
const MAX_PAGE_COUNT: int = 10

var history_page: int = 0
var is_undo_redo_delay: bool = false

var tree_selected: int = 1
var mtree: Array = []
var shadow_realm: Array = []
var _HistoryButton: PackedScene = preload("res://scenes/screens/level_editor/history_menu/history_button.tscn")
@onready var HistoryData: Control = $HistoryMenu/HistoryData

func on_undo_pressed(reload: bool = true) -> void:
	if mtree.size() > 0 and !block_screen:
		if reload: reset_infos(true)
		var last_index: int = mtree.size() - 1
		var tiles: Array = mtree[last_index].map(func(x: Variant): 
			if typeof(x) == TYPE_DICTIONARY: return true_tile_by_position(x.position, true)
			else: return x)
			
		shadow_realm.append(tiles.map(func(x: Variant):
			if typeof(x) == TYPE_OBJECT: return x.info.duplicate(true)
			else: return x))
		
		for i in range(mtree[last_index].size() - 1):
			tiles[i].info = mtree[last_index][i]
			reload_tile(tiles[i])
		
		mtree.remove_at(last_index)
		
		if reload:
			on_change_history_menu_page(0)
	
func on_redo_pressed(reload: bool = true) -> void:
	if shadow_realm.size() > 0 and !block_screen:
		if reload: reset_infos(true)
		var last_index: int = shadow_realm.size() - 1
		var tiles: Array = shadow_realm[last_index].map(func(x: Variant): 
			if typeof(x) == TYPE_DICTIONARY: return true_tile_by_position(x.position, true)
			else: return x)
		mtree.append(tiles.map(func(x: Variant): 
			if typeof(x) == TYPE_OBJECT: return x.info.duplicate(true)
			else: return x))
		
		for i in range(shadow_realm[last_index].size() - 1):
			tiles[i].info = shadow_realm[last_index][i]
			reload_tile(tiles[i])
			
		shadow_realm.remove_at(last_index)
		
		if reload:
			on_change_history_menu_page(0)

func on_add_to_history(tile_infos: Array, type: String) -> void:
	if tile_infos.size() > 0:
		if mtree.size() > HISTORY_SIZE: mtree.remove_at(0)
		tile_infos.append(type)
		mtree.append(tile_infos)
		
		shadow_realm = []
		on_change_history_menu_page(0)

func on_reload_history_data() -> void:
	for button in HistoryData.get_children():
		button.queue_free()
	
	var page_space: int = 10 * history_page
	var history_display: Array = []
	var srs: int = shadow_realm.size() - 1
	var mts: int = mtree.size()
	
	for i in range(page_space, page_space + 10):
		var srs_inverse: int = srs - i
		if srs_inverse >= 0: history_display.append([shadow_realm[srs_inverse], 1])
		elif mts - abs(srs_inverse) >= 0: history_display.append([mtree[mts - abs(srs_inverse)], 0])
		
	for i in range(history_display.size()):
		var btn: Button = _HistoryButton.instantiate()
		HistoryData.add_child(btn)
		btn.text = history_display[i][0][history_display[i][0].size() - 1] + "\n" + str(history_display[i][0][0].position)
			
		btn.position.y = i * 38
		var is_shadow: bool = history_display[i][1] == 1
		if is_shadow: btn.modulate = Helper.LIGHT_GREY
		btn.pressed.connect(on_history_button_pressed.bind(page_space + i, is_shadow))

func on_history_button_pressed(pos: int, is_shadow: bool) -> void:
	reset_infos(true)
	if is_shadow: for i in range(pos + 1): on_redo_pressed(false)
	else: for i in range(pos + 1 - shadow_realm.size()): on_undo_pressed(false)
	on_change_history_menu_page(0)

func on_change_history_menu_page(i: int):
	var max_page: int = max(floor(float(mtree.size() + shadow_realm.size() - 1) / MAX_PAGE_COUNT), 0)
	history_page = clamp(history_page + i, 0, max_page)
	$HistoryMenu/PRLeft.disabled = history_page == 0
	$HistoryMenu/PRRight.disabled = history_page == max_page
	on_reload_history_data()

func on_clear_history() -> void:
	shadow_realm = []
	mtree = []
	on_change_history_menu_page(0)

var light_tester_gd: Script = preload("res://assets/base_game/levels/level/loaded_level_light_tester.gd")

func _onBakeLevelPressed() -> void:
	var level_info: LevelInfoGD = _on_save_level_pressed()
	if level_info != null:
		pass

func onBakeLevelPressed():
	var level_info: LevelInfoGD = _on_save_level_pressed()
	if level_info != null:
		var packed_scene := PackedScene.new()
		
		var load_level_path: String = "res://assets/base_game/levels/level/loaded_level.tscn"
		var alt_path: String = "res://assets/base_game/levels/levels/" + level_info.folder_name + "/loaded_level.tscn"
		if FileAccess.file_exists(alt_path): load_level_path = alt_path
			
		get_parent().visible = false
		var LoadedLevel: Node3D = load(load_level_path).instantiate()
		for child in LoadedLevel.get_node("Tiles").get_children(): child.free()
		add_child(LoadedLevel)
		
		var tiles: Array = []
		var s: int = level_info.tiles.size()
		var i: int = 0
		for tile_info in level_info.tiles:
			tiles.append(on_create_tile(tile_info, LoadedLevel))
			await get_tree().create_timer(0.001).timeout
			i += 1
			print(str(i) + "/" + str(s))
		
		tiles = tiles.filter(func(x: TileGD): return x != null)
		for Tile in tiles: onSortTileCollisions(Tile, tiles, level_info.area.id)
		
		var positions: Array = tiles.map(func(x: TileGD): return x.onTTpos())
		for Tile in tiles:
			print(Tile.tile)
			on_set_tile_solid_status(Tile, tiles, positions)
		
		await get_tree().create_timer(0.02).timeout # absolutely necessary
		LoadedLevel.script = light_tester_gd
		packed_scene.pack(LoadedLevel)
		ResourceSaver.save(packed_scene, alt_path)
		LoadedLevel.queue_free()
		get_parent().visible = true
	else:
		AudioMaster.play_sfx("UnconfirmDefault")

func onSortTileCollisions(Tile: TileGD, tiles: Array, area: int) -> void:
	for obj_name in TILE_OBJECT_NAMES:
		var scene_path: String = "null"
		match obj_name:
			"tile": scene_path = Helper.tid_to(Tile[obj_name].id, area, Tile[obj_name].type)
			"wall": scene_path = Helper.wid_to(Tile[obj_name].id, area, Tile[obj_name].type)
			_: scene_path = Helper.editor_id_to(Helper.TYPE_TO_BTAB[obj_name], Tile[obj_name].id, Tile[obj_name].type)
	
		if scene_path != "null":
			match obj_name:
				"wall":
					var packed_wall: PackedScene = load("res://assets/models/walls/" + scene_path + ".tscn")
					for n in range(4 - Tile['wall'].tile_wall):
						var scene: Node3D = packed_wall.instantiate()
						Tile.ModelManager.add_child(scene)
						scene.rotation_degrees.y = Tile['wall'].rotation * 60
						scene.position.y = (n * 0.3) + 0.3
						if n == 1: onCreateCollisionPoints(Tile, tiles, scene.global_position, Tile['wall'].rotation * 60, scene.collision_points, 'wall')
				_: 
					if !(obj_name == "obj" and Tile['obj'].id in range(1, 5)):
						var scene: Node3D = load("res://assets/models/" + TILE_OBJECT_NAME_TO_FULL_NAME[obj_name] + "/" + scene_path + ".tscn").instantiate()
						Tile.ModelManager.add_child(scene)
						scene.position.y = 0.0 if obj_name == "tile" else 0.3
						scene.rotation_degrees.y = Tile[obj_name].rotation * 60
						onCreateCollisionPoints(Tile, tiles, scene.global_position, Tile[obj_name].rotation * 60,  scene.collision_points, obj_name)
		
	for grandchild in Tile.ModelManager.get_children():
		grandchild.owner = Tile.owner

func onCreateCollisionPoints(Tile: TileGD, tiles: Array, pos: Vector3, p_rot: int, points: Array, type: String) -> void:
	if points.size() > 0:
		match type:
			"tile":
				var match_type: int = Tile['tile'].type
				if match_type != 2 and getAdjacentTiles(Tile, tiles).all(func(x: TileGD): return x['tile'].type == match_type):
					for i in range(6 + int(Tile.w == 0)): points.remove_at(7)
			"wall":
				if Tile['wall'].type == 2:
					var _tiles: Array = getAdjacentTiles(Tile, tiles)
					if _tiles.size() == 6 and _tiles.all(func(x: TileGD): return x['wall'].type == 2):
						points = []
			
		for point in points:
			Tile.collision_points.append(getRotationPoint(point, p_rot) + pos)

func getAdjacentTiles(Tile: TileGD, tiles: Array) -> Array:
	var keep_tiles: Array = []
	for _Tile in tiles:
		if Tile.w == _Tile.w:
			var pos: Vector3 = Tile.tpos - _Tile.tpos
			if ((abs(pos.x) + abs(pos.y) + abs(pos.z)) / 2) == 1: keep_tiles.append(_Tile)
	return keep_tiles
var _LevelTile: PackedScene = preload("res://scenes/screens/level_map/utility_nodes/tiles/level_tile.tscn")
var item_properties: Array

var TILE_OBJECT_NAME_TO_FULL_NAME: Dictionary = {
	"tile": "tiles",
	"wdeco": "decorations/walls",
	"tdeco": "decorations/tiles",
	"obj": "objects",
	"wall": "walls",
}
var TILE_OBJECT_NAMES: Array = ["tile", "wall", "obj", "tdeco", "wdeco"]
func on_create_tile(tile_info: Dictionary, owner_node: Node3D) -> TileGD:
	if TILE_OBJECT_NAMES.any(func(x: String): return tile_info[x].id > 0):
		var LevelTile: Node3D = _LevelTile.instantiate()
	
		LevelTile.name = str(randi())
		owner_node.get_node("Tiles").add_child(LevelTile)
		owner_node.set_editable_instance(LevelTile, true)
		LevelTile.owner = owner_node
		
		var temp_vec: Vector4 = Vector4(tile_info.position[0], tile_info.position[1], tile_info.position[2], tile_info.position[3])
		LevelTile.position = Vector3(
		(sqrt(3) * temp_vec.x + sqrt(3) * temp_vec.y * 0.5),
		temp_vec.w * 1.2,
		temp_vec.y * 3 / 2)
		
		for child in LevelTile.ModelManager.get_children(): child.queue_free()
		for obj_name in TILE_OBJECT_NAMES:
			LevelTile[obj_name] = tile_info[obj_name]
			LevelTile.w = tile_info.position[3]
			LevelTile.tpos = Vector3(tile_info.position[0], tile_info.position[1], tile_info.position[2])
		return LevelTile
	return null

func getRotationPoint(xyz: Vector3, rot: int) -> Vector3:
	var r: float = deg_to_rad(rot)
	return Vector3(xyz.x * (cos(r)) - xyz.z * (sin(r)), xyz.y, xyz.z * (cos(r)) + xyz.x * (sin(r)))

func on_set_tile_solid_status(Tile: TileGD, tiles: Array, positions: Array) -> void:
	var btab: int = 0
	for tile_object in Helper.BTAB_TO_TYPE[-1]:
		if tile_object != "tile":
			if Tile[tile_object].id > 0:
				for info in item_properties:
					if info.id[0] == btab and info.id[1] == Tile[tile_object].id:
						var abs_positions: Array = positions.map(func(x: Vector4): return Vector3(Tile.tpos.x - x.x,\
						Tile.tpos.y - x.y, Tile.w - x.w))
						for key in info:
							if key.contains("|"):
								var pos: Vector3 = Vector3(int(key.get_slice("|", 0)), int(key.get_slice("|", 1)), int(key.get_slice("|", 2)))
								for i in range(abs_positions.size()):
									if abs_positions[i] == pos:
										if tiles[i].solid_status < 1 and info[key].solidity > 0:
											tiles[i].solid_status = 1
		btab += 1
	
func on_load_item_properties() -> void:
	var data: String = Helper.return_file_contents("res://static/game_info/item_properties.txt")
	for line in data.split("\n", false):
		item_properties.append(str_to_var(line))

@onready var LoadArea: OptionButton = %LoadArea
func _on_load_area_item_selected(index):
	on_area_selected(Helper.getFofInfo(int(LoadArea.get_item_text(index)), "area"))

@onready var LevelName: LineEdit = %LevelName
@onready var FolderName: LineEdit = %FolderName
func onLineEditTextSubmitted(__: String) -> void:
	LevelName.release_focus()
	FolderName.release_focus()
	IDEdit.release_focus()

func _on_h_slider_value_changed(value):
	level_difficulty = value
