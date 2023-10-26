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

@export var INFO_MENU_MOVE_SPEED: float = 6
@export var BUILD_MENU_MOVE_SPEED: float = 4

var Tiles: Node3D

@onready var mblockers: Array = [$LoadButtons, $InfoMenu, $BuildMenu]
var block_screen: bool = false
var active_tile: Node3D
var active_remove_state: int = 0
var level_difficulty: int = 1
var mblocker_rects: Array = []

var offset_values: Array = [dx * 0.5, 0]
var offset: float = dx * 0.5
const dx: float = sqrt(3)

const RAY_LENGTH: int = 1000
const TID: int = 5
const FILE_LOADER_NAME: String = "Level"

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
var default_level_size: int = [6, 10, 16, 20, 30, 40, 50, 100][Settings.level_size]
var grid_half_size: int = round(default_level_size * 0.5)

var selected_item_type: int = 0
var active_tile_state: int = 0
var max_item_types: int = 0

func admin() -> void:
	on_area_selected_from_fileloader(Helper.id_to_dict(1, "area"))
func _process(delta: float) -> void:
	if spin_model:
		ModelItem.rotation_degrees.y += delta * SPIN_MODEL_SPEED
	
	for input in [1,2,3,4]:
		if max_item_types > 0 and Input.is_action_just_pressed("ShiftNumber" + str(input)):
			on_type_button_pressed(input - 1)
		
		elif Input.is_action_just_pressed("Number" + str(input)):
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
		elif Input.is_action_pressed(Helper.interact_button()): on_tile_interact(active_tile); disable_interact = true
		elif Input.is_action_pressed("RotateLeft"): on_tile_rotate(active_tile, -1)
		elif Input.is_action_pressed("RotateRight"): on_tile_rotate(active_tile, 1)
	
	if !disable_interact and Input.is_action_just_pressed(Helper.interact_button()): load_settings_mini_menu()
			
func on_move_build_menu() -> void:
	build_menu_is_moving = true
func on_move_screen_switch() -> void:
	load_world.emit(World)
	
func _ready() -> void:
	for btn in [ArrowButton, $BuildMenu/LoadedMenu/PRLeftArrow, $BuildMenu/LoadedMenu/PRRightArrow]:
		Helper.create_button_clickmask(btn)
		btn.pressed.connect((func(): AudioMaster.play_sfx(preload("res://scenes/screens/level_editor/arrow/woosh.wav"))))
	BuildMenu.get_node("WarningLabel").text = "Make sure to load in an area, silly!"
	BuildMenu.get_node("Tabs").visible = false
	BuildMenu.get_node("LoadedMenu").visible = false
	BuildMenu.position.y += BuildMenu.size.y
	reset_mblocker_rects()
	admin()

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
	
	if block_screen:
		mblocker_rects.append(Rect2i(Vector2.ZERO, Vector2(1920, 1080)))
	
func _on_load_area_pressed():
	var FileLoader: Control = preload("res://scenes/editor/file_loader/file_loader.tscn").instantiate()
	FileLoader.on_ready("Area")
	FileLoader.item_selected.connect(on_area_selected_from_fileloader)
	FileLoader.queued.connect(on_file_loader_queued)
	block_screen = true
	reset_mblocker_rects()
	add_child(FileLoader)
func on_area_selected_from_fileloader(item: Dictionary) -> void:
	on_area_selected(item)
	on_load_empty_level()
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
	var lastx: int = 0
	for i in info.tiles:
		if i.position[0] != lastx: offset = 0
		lastx = i.position[0]
		var tile: Node3D = create_tile(Vector3(i.position[0], i.position[1], i.position[3]))
		tile.info = i
		
		tile.load_tile(i.tile.id)
		tile.load_obj(i.obj.id)
		tile.load_wall(i.wall.id)
		tile.load_deco(i.deco.id)
	setup_elevation()
	
func on_load_empty_level(save_level: bool = true) -> void:
	Settings.set_leveleditorelevation(0)
	Settings.update_settings_info(0, "Preferences", "LevelEditorElevation")
	
	active_tile = null
	LevelDifficulty.select_item(0)
	if save_level: _on_save_level_pressed(false, 2)
	EditFileName.set_text("")
	clear_world_tiles()
	for n in range(6):
		for x in range(-grid_half_size, grid_half_size + 1):
			offset = 0
			for y in range(-grid_half_size, grid_half_size + 1):
				var tile: Node3D = create_tile(Vector3(x, y, n))
				tile.info = {"tile": {"id": 1 if n == 0 else 0, "rotation": 0, "type": 0}, "obj": {"id": 0, "rotation": 0, "type": 0}, "deco": {"id": 0, "rotation": 0, "type": 0}, "wall": {"id": 0, "rotation": 0, "type": 0, "height": 0, "tile_wall": 0}, "position": [x, y, -x - y, n]}
				tile.load_tile(tile.info.tile.id)
	loaded_level = true
	setup_elevation()
	
func clear_world_tiles() -> void:
	for child in World.get_node("Tiles").get_children():
		for tile in child.get_children():
			tile.queue_free()
	
func create_tile(xy: Vector3) -> Node3D:
	var tile: Node3D = preload("res://assets/models/tiles/editor_tile.tscn").instantiate()
	tile.position = Vector3((xy.x * dx) + offset, xy.z, xy.y * 1.5)
	tile.load_tile_get_area.connect(on_load_tile_get_area)
	tile.load_wall_get_area.connect(on_load_wall_get_area)
	tile.active_tile.connect(on_is_active_tile)
	
	tile.DetectMouse.mouse_entered.connect(func(): tile.on_mouse_entered_check_mblockers(mblocker_rects))
	tile.DetectMouse.mouse_exited.connect(tile.on_mouse_exited)
	World.get_node("Tiles/" + str(xy.z)).add_child(tile)
	offset = offset_values[round(offset)]
	return tile
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
	FileLoader.queued.connect(on_file_loader_queued)
	block_screen = true
	reset_mblocker_rects()
	add_child(FileLoader)
	
	if loaded_area:
		FileLoader.set_search(str(loaded_area.id), 3)
		
func on_file_loader_queued() -> void:
	block_screen = false
	reset_mblocker_rects()
		
func _on_save_level_pressed(play_sfx: bool = true, create_temp: int = 1):
	if loaded_level:
		var children: Array = []
		for child in World.get_node("Tiles").get_children():
			for tile in child.get_children():
				children.append(tile)
		var contents: String = "%s\n%s\n%s\n" % [loaded_area.id, level_difficulty, children.map(func(x: Node3D): return x.info)]
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
		if Array(DirAccess.get_files_at(fpath)).any(func(x: String): return x.ends_with(".glb") and x[0] != "_"):
			for directory_two in DirAccess.get_directories_at(fpath):
				on_setup_tabs(current_folder[i])
				
			for file in Array(DirAccess.get_files_at(fpath)).filter(func(x: String): return x.ends_with(".glb") and x[0] != "_"):
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
	if selected_item_type > 0 and is_in_selection_folder():
		var farray: Array = path.split("/")
		var fitem: String = "_" + farray[farray.size() - 1].left(-4) + "_" + str(selected_item_type) + ".glb"
		if fitem.begins_with("__"): fitem = fitem.right(-1)
		farray.resize(farray.size() - 1)
		path = ""
		for i in farray: path += i + "/"
		return path + fitem
	return path

func type_button_factory() -> void:
	clear_item_types()
	var fpath: String = get_folder_path(selected_item_pos, true, false, false)
	var item_btn: Control = Items.get_child(get_selected_item_index() - 1)
	var farray: Array = fpath.split("/")
	var fitem: String = "_" + farray[farray.size() - 1].left(-4) + "_"
	if fitem.begins_with("__"): fitem = fitem.right(-1)
	fpath = ""
	for j in range(farray.size()):
		if j < farray.size() - 1:
			fpath += farray[j] + "/"
	
	ItemTypes.global_position = Vector2(item_btn.global_position.x + 95, item_btn.global_position.y)
	var fexists: bool = false
	var xy := Vector2.ZERO
	for n in range(1, 7):
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
	if xy.x >= 75:
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
		for item in ["obj", "deco", "wall", "tile"]:
			
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
		for j in ["tile", "obj", "wall", "deco"]:
			if !selected_item_pos or i == selected_item_pos[0]:
				var old_rotation: int = tile.info[j].rotation
				tile.info[j].rotation = clamp(tile.info[j].rotation + rotate_direction, 0, 5)
				if old_rotation == tile.info[j].rotation: tile.info[j].rotation = 0 if old_rotation == 5 else 5
				tile.call("load_" + j, tile.info[j].id)
			i += 1
		await get_tree().create_timer(ROTATION_TILE_DELAY).timeout
		has_rotated_tile_delay = false
	
func on_tile_interact(_tile: Node3D) -> void:
	if active_tile_state != 2:
		reset_active_tile_state(2)
	
func on_tile_select(tile: Node3D) -> void:
	if active_tile_state != 3:
		if selected_item_pos:
			var item_name: String = get_folder_path(selected_item_pos, true, true)
			match selected_item_pos[0]:
				1:
					tile.info.tile = {"id": Helper.id_to_editor(0, item_name), "rotation": tile.info.tile.rotation, "type": selected_item_type}
					tile.load_tile(tile.info.tile.id)
					
					if Settings.elevation_fill:
						var f: bool = Settings.tile_walls
						Settings.tile_walls = false
						var p: Array = tile.info.position
						for i in range(p[3] - 1, -1, -1):
							var _tile: Node3D = get_tile_by_position([p[0], p[1], p[2], i])
							if _tile.info.tile.id > 0 and _tile.info.wall.id == 0:
								load_wall(_tile, 1 if tile.info.tile.id != 4 else 3, 0, 4 if tile.info.tile.id != 4 else 0, p[3], 1)
								break
						Settings.tile_walls = f
				2: 
					tile.info.obj = {"id": Helper.id_to_editor(1, item_name), "rotation": tile.info.obj.rotation, "type": selected_item_type}
					tile.load_obj(tile.info.obj.id)
				3: load_wall(tile, Helper.id_to_editor(2, item_name), tile.info.wall.rotation, selected_item_type, Settings.default_wall_height, Settings.tile_walls)
				4:
					tile.info.deco = {"id": Helper.id_to_editor(3, item_name), "rotation": tile.info.deco.rotation, "type": selected_item_type}
					tile.load_deco(tile.info.deco.id)
		reset_active_tile_state(3)

func load_wall(tile: Node3D, id: int, rot: int, type: int, height: int, tile_wall: int) -> void:
	tile.info.wall = {"id": id, "rotation": rot, "type": type, "height": height, "tile_wall": tile_wall}
	tile.load_wall(id)

func get_tile_by_position(pos: Array) -> Node3D:
	for tile in World.get_node("Tiles/" + str(pos[3])).get_children():
		if tile.info.position == pos: return tile
	print_debug("Tile not found!")
	return null

func reset_active_tile_state(i: int) -> void:
	active_tile_state = i
	if i == 4: active_remove_state = 0

func load_settings_mini_menu() -> void:
	if !block_screen and loaded_area:
		block_screen = true
		reset_mblocker_rects()
		var mini_menu: Control = preload("res://scenes/screens/level_editor/build_menu/settings_mini_menu.tscn").instantiate()
		mini_menu.colors = [loaded_area.pcolor, loaded_area.acolor]
		add_child(mini_menu)
		mini_menu.queued.connect(on_file_loader_queued)
		mini_menu.get_node("Settings/LevelEditorElevation").item_selected.connect(func(__: int): setup_elevation())

func setup_elevation() -> void:
	for child in World.get_node("Tiles").get_children():
		var p: bool = child.name == str(Settings.level_editor_elevation)
		for tile in child.get_children(): tile.get_node("DetectMouse").collision_layer = 2 if p else 0
