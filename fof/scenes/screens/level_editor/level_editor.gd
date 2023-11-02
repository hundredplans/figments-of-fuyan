extends Control
signal load_world

@onready var ItemTypes: Control = $BuildMenu/LoadedMenu/ItemTypes
@onready var Tabs: HBoxContainer = $BuildMenu/Tabs/Tabs
@onready var LevelDifficulty = $InfoMenu/LevelDifficulty
@onready var EditFileName = $InfoMenu/EditFileName
@onready var ArrowButton = $InfoMenu/PRArrow
@onready var InfoMenu = $InfoMenu
@onready var LoadButtons = $LoadButtons
@onready var BuildMenu = $BuildMenu
@onready var Items = $BuildMenu/LoadedMenu/Items
@onready var BackArrow = $BuildMenu/LoadedMenu/BackArrow
@onready var BuildMenuWorld = $BuildMenu/LoadedMenu/ItemsViewer/ItemViewport/BuildMenuWorld
@onready var ModelItem: Node3D = $BuildMenu/LoadedMenu/ModelViewer/ViewmodelViewport/ViewmodelWorld/Model

@onready var HeightButtons: Control = $BuildMenu/HeightMenu/HeightButtons
@onready var ElevationButtons: Control = $BuildMenu/HeightMenu/ElevationButtons

@export var INFO_MENU_MOVE_SPEED: float = 6
@export var BUILD_MENU_MOVE_SPEED: float = 4

var SelectionBox: ColorRect

@onready var mblockers: Array = [$LoadButtons, $InfoMenu, $BuildMenu]
var block_screen: bool = false
var active_tile: Node3D
var active_remove_state: int = 0
var level_difficulty: int = 1
var mblocker_rects: Array = []

const RAY_LENGTH: int = 1000
const TID: int = 5
const FILE_LOADER_NAME: String = "Level"

var file_loader_loaded: bool = false
var loaded_area: Dictionary
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

var selected_item_type: int = 0
var active_tile_state: int = 0
var max_item_types: int = 0
var trinket_amount: int = 0

var current_history: Array = []
var erased_history: Array = []

func _ready() -> void:
	$InfoMenu/EditFileName.open_state.connect(func(x: bool): $InfoMenu/TrinketAmount.visible = !x)
	for i in [["DefaultWallHeight", HeightButtons.get_children()], ["LevelEditorElevation", ElevationButtons.get_children()]]:
		for btn in i[1]:
			btn.pressed.connect(Settings["set_" + i[0].to_lower()].bind(int(str(btn.name))))
			btn.pressed.connect(Settings.update_settings_info.bind(int(str(btn.name)), "Preferences", i[0]))
			btn.pressed.connect(set_heightbuttons_modulate)
			if i[0] == "LevelEditorElevation":
				btn.pressed.connect(setup_elevation)
	
	for btn in [ArrowButton, $BuildMenu/LoadedMenu/PRLeftArrow, $BuildMenu/LoadedMenu/PRRightArrow]:
		Helper.create_button_clickmask(btn)
		btn.pressed.connect((func(): AudioMaster.play_sfx(preload("res://scenes/screens/level_editor/arrow/woosh.wav"))))
	BuildMenu.get_node("WarningLabel").text = "Make sure to load in an area, silly!"
	BuildMenu.get_node("Tabs").visible = false
	BuildMenu.get_node("LoadedMenu").visible = false
	BuildMenu.position.y += BuildMenu.size.y
	reset_mblocker_rects()
	admin()
	
	setup_elevation()
	set_heightbuttons_modulate()

func admin() -> void:
	on_area_selected_from_fileloader(Helper.id_to_dict(1, "area"))
	
func _process(delta: float) -> void:
	if spin_model:
		ModelItem.rotation_degrees.y += delta * SPIN_MODEL_SPEED
	
	for input in [1,2,3,4,5,6,7]:
		if max_item_types > 0 and Input.is_action_just_pressed("ShiftNumber" + str(input)):
			on_type_button_pressed(input - 1)
		
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

	if info_menu_is_moving != 0:
		var adjusted_weight: float = clamp(info_weight * INFO_MENU_MOVE_SPEED, 0, 1)
		var pos: float = lerp(info_menu_positions.x, info_menu_positions.y, adjusted_weight)
		InfoMenu.position.x = pos
		info_weight += delta
		
		if adjusted_weight >= 1:
			info_menu_is_moving = 0
			reset_mblocker_rects()
			
	if Input.is_action_just_released("Remove"):
		reset_active_tile_state(4)
			
	if Input.is_action_just_pressed("ClearSelection") and selected_item_pos:
		deselect_item()
			
	var disable_interact: bool = false
	if active_tile and active_tile.can_press:
		if Input.is_action_pressed("LeftClick"): on_tile_select(active_tile)
		elif Input.is_action_pressed("Remove"): on_tile_remove(active_tile)
		elif Input.is_action_just_pressed(Helper.interact_button()): on_tile_interact(active_tile); disable_interact = true
		elif Input.is_action_pressed("RotateLeft"): on_tile_rotate(active_tile, -1)
		elif Input.is_action_pressed("RotateRight"): on_tile_rotate(active_tile, 1)
	else:
		if Input.is_action_just_pressed("ShiftLeftClick"):
			on_update_tile_menu()
		
	if Input.is_action_pressed("LeftClick") and !selected_item_pos:
		match SelectionBox:
			null: on_create_selection_box()
			_: on_resize_selection_box()
		
	if !disable_interact and Input.is_action_just_pressed(Helper.interact_button()): load_settings_mini_menu()
	if Input.is_action_just_released("LeftClick"):
		on_clear_selection_box()
	
#	if Input.is_action_just_pressed("TopDownAlign"):
#		World.get_node("MovementCamera").rotation_degrees = Vector3(-90, 0, 0)
	
var og_sbox_pos: Vector2
func on_create_selection_box() -> void:
	if !block_screen and !(mblocker_rects.filter(func(x: Rect2i): return x.has_point(get_viewport().get_mouse_position()))):
		var color_rect := ColorRect.new()
		SelectionBox = color_rect
		add_child(SelectionBox)
		color_rect.position = get_viewport().get_mouse_position()
		color_rect.color = "2fffff87"
		og_sbox_pos = color_rect.position
	
func on_resize_selection_box() -> void:
	var s: Vector2 = (og_sbox_pos - get_viewport().get_mouse_position()) * -1
	SelectionBox.scale = Vector2(-1 if s.x < 0 else 1, -1 if s.y < 0 else 1)
	SelectionBox.size = Vector2(abs(s.x), abs(s.y))
	
func on_clear_selection_box() -> void:
	if SelectionBox != null and is_inside_tree():
		var tiles: Array = []
		var ray: RayCast3D = World.get_node("TileRaycast")
		for tile in World.get_node("Tiles/" + str(Settings.level_editor_elevation)).get_children():
			ray.position = World.get_node("MovementCamera").position
			ray.target_position = tile.position - ray.position
			ray.force_raycast_update()
			if ray.get_collider() == tile.get_node("DetectMouse"):
				var rect := Rect2(SelectionBox.position, SelectionBox.size)
				if SelectionBox.scale.x == -1: rect.position.x -= rect.size.x
				if SelectionBox.scale.y == -1: rect.position.y -= rect.size.y
				if rect.has_point(World.get_node("MovementCamera").unproject_position(ray.get_collision_point())):
					tiles.append(tile)
			
		on_tiles_selected(tiles)
		SelectionBox.queue_free()
		SelectionBox = null
		
func on_move_build_menu() -> void:
	build_menu_is_moving = true
func on_move_screen_switch() -> void:
	load_world.emit(World)

func on_mblocker_mouse_exited():
	if active_tile:
		var to: Vector3 = World.get_node("MovementCamera").project_ray_normal(get_viewport().get_mouse_position()) * RAY_LENGTH
		var ray: RayCast3D = World.get_node("TileRaycast")
		ray.position = World.get_node("MovementCamera").position
		ray.target_position = to
		ray.force_raycast_update()
		if ray.get_collider() == active_tile.get_node("DetectMouse"):
			active_tile.on_mouse_entered()
	
func on_mblocker_mouse_entered():
	if active_tile: active_tile.on_mouse_exited()

func reset_mblocker_rects() -> void:
	mblocker_rects = mblockers.map(func(x: Control): return Rect2i(x.global_position, x.size))
	$MouseBlockers/BuildMenu.position = BuildMenu.position + ($MouseBlockers/BuildMenu.shape.size / 2)
	$MouseBlockers/InfoMenu.position = InfoMenu.position + ($MouseBlockers/InfoMenu.shape.size / 2)
	
func _on_load_area_pressed():
	var FileLoader: Control = preload("res://scenes/editor/file_loader/file_loader.tscn").instantiate()
	FileLoader.on_ready("Area")
	FileLoader.item_selected.connect(on_area_selected_from_fileloader)
	on_file_loader_loaded(FileLoader)
	
func on_area_selected_from_fileloader(item: Dictionary) -> void:
	_on_save_level_pressed(false, 2)
	on_area_selected(item)
	on_load_empty_level(false)
	
func on_area_selected(item: Dictionary) -> void:
	loaded_area = item
	Helper.load_area_colors(self, item.pcolor, item.acolor)
	
	folder_pos = []
	build_folders = ["res://assets/models/"]
	on_setup_tabs()
	build_folders = [build_folders[0], build_folders[3], build_folders[2], build_folders[4], build_folders[1]]
	build_folders[1] = build_folders[1].filter(func(x: Variant): return !(typeof(x) == TYPE_STRING) or !x[0].is_valid_int() or int(x) == item.id)
	build_folders[3] = build_folders[3].filter(func(x: Variant): return !(typeof(x) == TYPE_STRING) or !x[0].is_valid_int() or int(x) == item.id)
	on_load_tab(0)
	
	if !loaded_level:
		on_build_menu_enabled()
func on_load_level(info: Dictionary) -> void:
	active_tile = null
	match loaded_level:
		false: on_build_menu_enabled(); loaded_level = true
		_: _on_save_level_pressed(false, 2)
	
	EditFileName.set_text(info.iname, info.sname)
	on_area_selected(Helper.id_to_dict(info.area, "Area"))
	level_difficulty = info.difficulty
	LevelDifficulty.select_item(level_difficulty - 1)
	
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
	trinket_amount = info.trinkets
	$InfoMenu/TrinketAmount.default = trinket_amount
	$InfoMenu/TrinketAmount.set_grabber_position()
	
func on_load_empty_level(save_level: bool = true) -> void:
	Settings.set_leveleditorelevation(0)
	Settings.update_settings_info(0, "Preferences", "LevelEditorElevation")
	
	active_tile = null
	LevelDifficulty.select_item(0)
	if save_level: _on_save_level_pressed(false, 2)
	EditFileName.set_text("")
	clear_world_tiles()
	for w in range(6):
		for x in range(-default_level_size, (default_level_size + 1)):
			for y in range(max(-default_level_size, -x - default_level_size), min(default_level_size, -x + default_level_size) + 1):
				var tile: Node3D = create_tile(Vector3(x, y, w))
				tile.info = {"tile": {
				"id": 1 if w == 0 else 0, "rotation": 0, "type": 0}, 
				"obj": {"id": 0, "rotation": 0, "type": 0, "loaded": 0}, 
				"wdeco": {"id": 0, "rotation": 0, "type": 0}, 
				"tdeco": {"id": 0, "rotation": 0, "type": 0},
				"wall": {"id": 0, "rotation": 0, "type": 0, "height": 0, "tile_wall": 0}, 
				"position": [x, y, -x-y, w]}
				tile.load_tile(tile.info.tile.id)
	loaded_level = true
	setup_elevation()
	trinket_amount = 0
	$InfoMenu/TrinketAmount.default = trinket_amount
	$InfoMenu/TrinketAmount.set_grabber_position()
	
func clear_world_tiles() -> void:
	for child in World.get_node("Tiles").get_children():
		for tile in child.get_children():
			tile.queue_free()
	
func create_tile(xy: Vector3) -> Node3D:
	var tile: Node3D = preload("res://assets/models/tiles/editor_tile.tscn").instantiate()
	tile.position = Vector3((sqrt(3) * xy.x + sqrt(3) * xy.y * 0.5),
	xy.z * 1.2,
	xy.y * 3 / 2)
	tile.load_obj_get_area.connect(on_load_obj_get_area)
	tile.load_tile_get_area.connect(on_load_tile_get_area)
	tile.load_wall_get_area.connect(on_load_wall_get_area)
	tile.active_tile.connect(on_is_active_tile)
	tile.hover_tile.connect(on_hover_tile)
	tile.exit_mouse.connect(on_tile_exit_mouse)
	
	tile.DetectMouse.mouse_entered.connect(on_tile_mouse_entered.bind(tile))
	tile.DetectMouse.mouse_exited.connect(tile.on_mouse_exited)
	World.get_node("Tiles/" + str(xy.z)).add_child(tile)
	return tile
	
func on_tile_mouse_entered(tile: Node3D) -> void:
	if !block_screen or tile in selection_tiles:
		tile.on_mouse_entered_check_mblockers(mblocker_rects)
	
func on_build_menu_enabled() -> void:
	BuildMenu.get_node("WarningLabel").text = ""
	BuildMenu.get_node("Tabs").visible = true
	BuildMenu.get_node("LoadedMenu").visible = true
func _on_load_empty_pressed():
	if !loaded_area: _on_load_area_pressed()
	else: on_load_empty_level()
func _on_load_level_pressed():
	var FileLoader: Control = preload("res://scenes/editor/file_loader/file_loader.tscn").instantiate()
	FileLoader.on_ready(FILE_LOADER_NAME)
	FileLoader.item_selected.connect(on_load_level)
	on_file_loader_loaded(FileLoader)
	
	if loaded_area:
		FileLoader.set_search(str(loaded_area.id), 3)
		
func on_file_loader_queued() -> void:
	block_screen = false
	reset_mblocker_rects()
	file_loader_loaded = false
		
func _on_save_level_pressed(play_sfx: bool = true, create_temp: int = 1):
	if loaded_level:
		var children: Array = []
		for child in World.get_node("Tiles").get_children():
			for tile in child.get_children():
				children.append(tile)
		var contents: String = "%s\n%s\n%s\n%s\n" % [loaded_area.id, level_difficulty, trinket_amount, children.map(func(x: Node3D): return x.info)]
		match Helper.write_to_base_game_file(FILE_LOADER_NAME, EditFileName, contents, TID):
			{}: if play_sfx: AudioMaster.play_sfx(preload("res://assets/sounds/confirmation/unconfirm_default.wav"), -10)
			_: if play_sfx: AudioMaster.play_sfx(preload("res://assets/sounds/confirmation/confirm_default.wav"), -10)
		
		if Settings.clear_backup_files_array[Settings.clear_backup_files] != 1:
			Helper.write_to_file("user://save/temp/levels/", EditFileName.get_node("Showcase").text + ["", "_save", "_override"][create_temp], ".txt", contents)
func _queue_free() -> void:
	_on_save_level_pressed(false, 0)
	load_world.emit(null)
func _on_arrow_button_pressed():
	if info_menu_is_moving == 0:
		info_weight = 0
		info_menu_is_moving = 1 if InfoMenu.position.x < 0 else -1
		info_menu_positions = Vector2(InfoMenu.position.x, InfoMenu.position.x + ((InfoMenu.size.x - 105) * info_menu_is_moving))
func _on_level_difficulty_item_selected(i: int):
	level_difficulty = i + 1

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
		path = n.pop_back()
		n.remove_at(0)
		for j in n: path += j + "/"
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
					item.get_node("PROutside").modulate = loaded_area.pcolor
			Items.add_child(item)
			loaded_items.append(item)
		else: skip_first = false
		
	var xy := Vector2.ZERO
	for item in loaded_items:
		if item.scene_file_path.ends_with("item.tscn"): BuildMenuWorld.position_item(xy)
		item.position += xy
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
	if active_tile_state != 1:
		var i: int = 1
		for item in ["obj", "wdeco", "tdeco", "wall", "tile"]:
			if item == "tile" and tile.info.tile.type > 0 and active_remove_state in [0, i + 2]:
				tile.info.tile.type = 0
				tile.load_tile(tile.info.tile.id)
				active_remove_state = i + 2
				break
				
			if active_remove_state in [0, i]:
				if tile.info[item].id != 0:
					tile.info.tile.type = 0
					tile.call("load_" + item, 0)
					active_remove_state = i
					if item == "tile":
						var p: Array = tile.info.position
						for j in range(p[3] - 1, -1, -1):
							var _tile: Node3D = get_tile_by_position([p[0], p[1], p[2], j])
							if _tile.info.tile.id != 0:
								if _tile.info.wall.id != 0 and _tile.info.wall.type == 1 and _tile.info.wall.tile_wall == 1:
									_tile.load_wall(0)
								break
					break
					
			if item == "tile" and active_remove_state in [0, i + 1]:
				tile.load_tile(1)
				active_remove_state = i + 1
				break
				
			i += 1
		reset_active_tile_state(1)
	
var has_rotated_tile_delay: bool = false
const ROTATION_TILE_DELAY: float = 0.2
	
func on_tile_rotate(tile: Node3D, rotate_direction: int) -> void:
	if !has_rotated_tile_delay:
		has_rotated_tile_delay = true
		var i: int = 1
		for j in ["tile", "obj", "wall", "tdeco", "wdeco"]:
			if !selected_item_pos or i == selected_item_pos[0] or selected_item_pos[0] == 4 and selected_item_pos[1] == 2 and j == "wdeco":
				on_rotate_tile_object(tile, rotate_direction, j, tile.info[j].id)
			i += 1
		await get_tree().create_timer(ROTATION_TILE_DELAY).timeout
		has_rotated_tile_delay = false
	
func _on_trinket_amount_item_selected(i: int): trinket_amount = i
	
func on_rotate_tile_object(tile: Node3D, direction: int, j: String, id: int):
	var old_rotation: int = tile.info[j].rotation
	tile.info[j].rotation = clamp(tile.info[j].rotation + direction, 0, 5)
	if old_rotation == tile.info[j].rotation: tile.info[j].rotation = 0 if old_rotation == 5 else 5
	tile.call("load_" + j, id)
	
func on_tile_interact(tile: Node3D) -> void:
	if active_tile_state != 2:
		reset_active_tile_state(2)
		on_tiles_selected([tile])
	
func on_tile_select(tile: Node3D) -> void:
	if active_tile_state != 3:
		if !is_wall_below_you_reaches_above_you(tile.info.position):
			if selected_item_pos:
				var item_name: String = get_folder_path(selected_item_pos, true, true)
				match selected_item_pos[0]:
					1: load_tile(tile, Helper.id_to_editor(0, item_name), tile.info.tile.rotation, selected_item_type)
					2: 
						tile.info.obj = {"id": Helper.id_to_editor(1, item_name), "rotation": tile.info.obj.rotation, "type": selected_item_type, "loaded": 0}
						tile.load_obj(tile.info.obj.id)
						if tile.info.tile.id == 0 and tile.info.obj.id != 5: load_tile(tile, 1, 0, 0)
					3: 
						load_wall(tile, Helper.id_to_editor(2, item_name), tile.info.wall.rotation, selected_item_type, Settings.default_wall_height, Settings.tile_walls)
						if tile.info.tile.id == 0: load_tile(tile, 1, 0, 0)
					4:
						match selected_item_pos[1]:
							1: 
								tile.info.tdeco = {"id": Helper.id_to_editor(3, item_name), "rotation": tile.info.tdeco.rotation, "type": selected_item_type}
								tile.load_tdeco(tile.info.tdeco.id)
								if tile.info.tile.id == 0: load_tile(tile, 1, 0, 0)
							2:
								tile.info.wdeco = {"id": Helper.id_to_editor(4, item_name), "rotation": tile.info.wdeco.rotation, "type": selected_item_type}
								tile.load_wdeco(tile.info.wdeco.id)
								if tile.info.tile.id == 0: load_tile(tile, 1, 0, 0)
			elif tile in selection_tiles:
				on_call_selection_callable(tile)
					
		reset_active_tile_state(3)

func is_wall_below_you_reaches_above_you(p: Array) -> bool:
	for i in range(p[3] - 1, -1, -1):
		var _tile: Node3D = get_tile_by_position([p[0], p[1], p[2], i])
		if _tile.info.wall.id > 0 and _tile.info.wall.height > p[3] - i:
			return true
	return false

func load_tile(tile: Node3D, id: int, rot: int, type: int) -> void:
	tile.info.tile = {"id": id, "rotation": rot, "type": type}
	tile.load_tile(id)
	
	if Settings.elevation_fill:
		var f: bool = Settings.tile_walls
		Settings.tile_walls = true
		var p: Array = tile.info.position
		var load_id: int = 1
		if tile.info.tile.id in [3, 4]: load_id = tile.info.tile.id
		for i in range(p[3] - 1, -1, -1):
			var _tile: Node3D = get_tile_by_position([p[0], p[1], p[2], i])
			if _tile.info.tile.id > 0 and _tile.info.wall.id == 0 and _tile.info.obj.id == 0 and _tile.info.wdeco.id == 0 and _tile.info.tdeco.id == 0 and _tile.info.tile.type == 0:
				if _tile.info.position[3] == 0: load_wall(_tile, load_id, 0, 1, p[3], 1)
				if tile.info.tile.id in [3, 4]: load_tile(_tile, tile.info.tile.id, 0, 0)
				break
		Settings.tile_walls = f

func load_wall(tile: Node3D, id: int, rot: int, type: int, height: int, tile_wall: int) -> void:
	tile.info.wall = {"id": id, "rotation": rot, "type": type, "height": height, "tile_wall": tile_wall}
	tile.load_wall(id)

func get_tile_by_position(pos: Array) -> Node3D:
	for tile in World.get_node("Tiles/" + str(pos[3])).get_children():
		if Helper.compare_by_value(tile.info.position, pos): return tile
	return null

func reset_active_tile_state(i: int) -> void:
	active_tile_state = i
	if i == 4: active_remove_state = 0

func load_settings_mini_menu() -> void:
	if !block_screen and loaded_area:
		block_screen = true
		reset_mblocker_rects()
		var mini_menu: Control = preload("res://scenes/screens/level_editor/build_menu/settings_mini_menu.tscn").instantiate()
		Helper.load_area_colors(mini_menu, loaded_area.pcolor, loaded_area.acolor)
		add_child(mini_menu)
		mini_menu.queued.connect(on_file_loader_queued)

func setup_elevation() -> void:
	$ElevationNumber.text = str(Settings.level_editor_elevation)
	for child in World.get_node("Tiles").get_children():
		var p: bool = child.name == str(Settings.level_editor_elevation)
		for tile in child.get_children(): 
			tile.get_node("DetectMouse").collision_layer = 2 if p else 0

func set_heightbuttons_modulate() -> void:
	for btn in HeightButtons.get_children():
		btn.modulate = Helper.RED if btn.name == str(Settings.default_wall_height) else Helper.BASE

	for btn in ElevationButtons.get_children():
		btn.modulate = Helper.RED if btn.name == str(Settings.level_editor_elevation) else Helper.BASE

func on_hover_tile(tile: Node3D) -> void:
	if tile.info.tile.type == 0 and !(!Settings.highlight_empty_tiles and tile.info.tile.id == 0) and SelectionBox == null:
		if tile in selection_tiles: tile.load_tile(tile.info.tile.id)
		else: tile.load_tile(2)
		
func on_call_selection_callable(tile: Node3D) -> void:
	selection_callable.call(tile)
		
func on_set_selection_tiles(tiles: Array = [], c: Callable = Callable()) -> void:
	selection_tiles = tiles
	selection_callable = c
	
	if selection_tiles.size() == 1: on_call_selection_callable(tiles[0])
	elif tiles.size() > 0: on_tile_menu_highlight_tiles(1, tiles)
		
signal update_tile_menu
var tile_menu_tiles: Array
func on_tiles_selected(tiles: Array) -> void:
	if !Settings.select_empty_tiles: tiles = tiles.filter(func(x: Node3D): return x.info.tile.id != 0)
	if tiles.size() > 0 and !block_screen and loaded_area:
		for t in tiles: if t.info.tile.type == 0: t.load_tile(2)
		block_screen = true
		reset_mblocker_rects()
		
		var tile_menu: Control = preload("res://scenes/screens/level_editor/build_menu/tile_menu.tscn").instantiate()
		update_tile_menu.connect(tile_menu.on_update_tile_menu)
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

func on_tile_menu_queued(TileMenu: Control) -> void:
	if !file_loader_loaded:
		block_screen = false
		on_set_selection_tiles()
		for tile in TileMenu.tiles: on_tile_exit_mouse(tile)
		reset_mblocker_rects()
		TileMenu.queue_free()

func on_tile_menu_highlight_tiles(state: int, tiles: Array) -> void:
	for tile in tiles:
		var i: int = 2 if state > 0 else tile.info.tile.id
		tile.load_tile(i)

func on_tile_exit_mouse(tile: Node3D) -> void:
	if tile.info.tile.type == 0:
		if !block_screen:
			tile.load_tile(tile.info.tile.id)
		elif tile in selection_tiles:
			tile.load_tile(2)

var item_id_array: Array = [["tile", "obj", "wall", "wdeco", "tdeco"], ["tile"], ["obj"], ["wall"], ["wdeco"], ["tdeco"]]
func on_tile_menu_rotate_full(item: int, i: int, tiles: Array) -> void:
	for tile in tiles:
		for j in item_id_array[item]:
			var load_id: int = (2 if j == "tile" else tile.info[j].id) if tile.info[j].type == 0 else tile.info[j].id
			tile.info[j].rotation = i
			tile.call("load_" + j, load_id)
	
func on_tile_menu_rotate_direction(item: int, direction: int, tiles: Array) -> void:
	for tile in tiles:
		for j in item_id_array[item]:
			on_rotate_tile_object(tile, direction, j, (2 if j == "tile" else tile.info[j].id) if tile.info[j].type == 0 else tile.info[j].id)
	
func on_tile_menu_delete(item: int, tiles: Array) -> void:
	for tile in tiles:
		for j in item_id_array[item]:
			var load_id: int = 0
			if j == "tile":
				if item_id_array[item].size() > 1 or tile.info[j].id == 0:
					load_id = 1
			tile.call("load_" + j, load_id)
			
	update_tile_menu.emit()
	
var selection_callable: Callable
var selection_tiles: Array = []
var copy_info: Array

func on_tile_menu_copy(item: int, tiles: Array) -> void:
	on_set_selection_tiles(tiles, on_tile_menu_copy_tile_selected.bind(item, tiles))
	
func on_tile_menu_copy_tile_selected(tile: Node3D, item: int, tiles: Array) -> void:
	var i: int = tiles.find(tile)
	tiles[i] = tiles[0]
	tiles[0] = tile
	copy_info = store_tile_info(tiles, tile, [], item)
	on_set_selection_tiles.call_deferred()
	tile.load_tile(2)
	
func store_tile_info(tiles: Array, tile: Node3D, arr: Array, item: int) -> Array:
	var p: Vector4 = Helper.position_to_vec(tile.info.position)
	for _tile in tiles:
		var x: Vector4 = Helper.position_to_vec(_tile.info.position) - p
		arr.append([[x.x, x.y, x.z, x.w]])
		var csize: int = arr.size() - 1
		for j in item_id_array[item]:
			arr[csize].append([j, _tile.info[j].duplicate(true)])
	return arr
	
func on_tile_menu_paste(_tiles: Array) -> void:
	if copy_info.size() > 0 and _tiles.size() == 1:
		var p: Vector4 = Helper.position_to_vec(_tiles[0].info.position)
		for i in copy_info:
			var x: Vector4 = Helper.position_to_vec(i[0]) + p
			var tile: Node3D = get_tile_by_position([x.x, x.y, x.z, x.w])
			if tile != null:
				for k in range(1, i.size()):
					tile.info[i[k][0]] = i[k][1].duplicate(true)
					tile.call("load_" + i[k][0], tile.info[i[k][0]].id)
	
func on_tile_menu_move(item: int, tiles: Array) -> void:
	on_set_selection_tiles(tiles, on_tile_menu_move_center_tile_selected.bind(item, tiles))
	
func on_tile_menu_move_center_tile_selected(center_tile: Node3D, item: int, tiles: Array) -> void:
	copy_info = store_tile_info(tiles, center_tile, [], item)
	for tile in tiles:
		for j in item_id_array[item]:
			tile.call("load_" + j, 1 if j == "tile" else 0)
	
	on_set_selection_tiles(World.get_node("Tiles/" + str(Settings.level_editor_elevation)).get_children(), on_tile_menu_move_finished.bind(tiles))
func on_tile_menu_move_finished(tile: Node3D, tiles: Array) -> void:
	on_tile_menu_paste([tile])
	on_set_selection_tiles.call_deferred()
	on_tile_menu_highlight_tiles(0, World.get_node("Tiles/" + str(Settings.level_editor_elevation)).get_children())
	on_tile_menu_highlight_tiles(1, tiles)
	
var bucket_info: Array = []
func on_tile_menu_bucket(item: int, tiles: Array) -> void:
	if tiles.size() == 1:
		bucket_info = []
		for j in item_id_array[item]:
			bucket_info.append([j, tiles[0].info[j].duplicate(true)])
	else:
		if bucket_info.size() > 0:
			for tile in tiles:
				for j in bucket_info:
					tile.info[j[0]] = j[1].duplicate(true)
					tile.call("load_" + j[0], tile.info[j[0]].id)

func on_tile_menu_spawn(tiles: Array) -> void:
	if tiles.size() == 1 and loaded_area:
		var FileLoader: Control = preload("res://scenes/editor/file_loader/file_loader.tscn").instantiate()
		var cards: Array = loaded_area.cards.map(func(i: int): return Helper.id_to_dict(i, "Card"))
		match tiles[0].info.obj.id:
			1: cards = cards.filter(func(x: Dictionary): return x != {} and x.r != 1)
			3: cards = cards.filter(func(x: Dictionary): return x != {} and x.r == 0)
			
		FileLoader.on_ready_preselected("Card", cards)
		FileLoader.item_selected.connect(on_card_selected_from_fileloader)
		on_file_loader_loaded(FileLoader)
		FileLoader.queued.connect(func(): block_screen = true; reset_mblocker_rects())

func on_tile_menu_item_type(val: int, item: int, tiles: Array) -> void:
	if tiles.size() == 1 and item != 0:
		for j in item_id_array[item]:
			tiles[0].info[j].type = val
			tiles[0].call("load_" + j, tiles[0].info[j].id)

func on_tile_menu_fill_wall(tiles: Array) -> void:
	pass
	
func on_tile_menu_tile_wall(tiles: Array) -> void:
	pass

func on_tile_menu_wall_height(i: int, tiles: Array) -> void:
	for tile in tiles:
		if tile.info.wall.id > 0:
			tile.info.wall.height = i
			tile.load_wall(tile.info.wall.id)

func on_file_loader_loaded(FileLoader: Control):
	FileLoader.queued.connect(on_file_loader_queued)
	file_loader_loaded = true
	block_screen = true
	reset_mblocker_rects()
	add_child(FileLoader)

func on_card_selected_from_fileloader(item_info: Dictionary) -> void:
	if tile_menu_tiles.size() == 1:
		tile_menu_tiles[0].info.obj.loaded = item_info.id
		tile_menu_tiles[0].load_obj(tile_menu_tiles[0].info.obj.id)
