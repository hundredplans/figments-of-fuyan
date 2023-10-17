extends Control
signal load_world

@onready var Tabs: HBoxContainer = $BuildMenu/Tabs/Tabs
@onready var LevelDifficulty = $InfoMenu/LevelDifficulty
@onready var EditFileName = $InfoMenu/EditFileName
@onready var ArrowButton = $InfoMenu/ArrowButton
@onready var InfoMenu = $InfoMenu
@onready var LoadButtons = $LoadButtons
@onready var BuildMenu = $BuildMenu
@onready var Items = $BuildMenu/LoadedMenu/Items
@onready var BackArrow = $BuildMenu/LoadedMenu/BackArrow
@onready var BuildMenuWorld = $BuildMenu/LoadedMenu/ItemsViewer/ItemViewport/BuildMenuWorld
@onready var ModelItem: Node3D = $BuildMenu/LoadedMenu/ModelViewer/ViewmodelViewport/ViewmodelWorld/Model

@export var INFO_MENU_MOVE_SPEED: float = 6
@export var BUILD_MENU_MOVE_SPEED: float = 4

@onready var mblockers: Array = [$LoadButtons, $InfoMenu, $BuildMenu]
var level_difficulty: int = 1
var mblocker_rects: Array = []

var offset_values: Array = [dx * 0.5, 0]
var offset: float = dx * 0.5
const dx: float = sqrt(3)

const TID: int = 5
const FILE_LOADER_NAME: String = "Level"

var active_tile_state: int = 0
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

func admin() -> void:
	on_area_selected(Helper.id_to_dict(1, "area"))

func _process(delta: float) -> void:
	
	if spin_model:
		ModelItem.rotation_degrees.y += delta * SPIN_MODEL_SPEED
	
	for input in [1,2,3,4]:
		if Input.is_action_just_pressed("Number" + str(input)):
			on_load_tab(input - 1)
	
	if build_menu_is_moving == 0 and Input.is_action_just_pressed("Tab"):
		build_menu_is_moving = -1 if BuildMenu.position.y > 1000 else 1
		build_menu_positions = Vector2(BuildMenu.position.y, BuildMenu.position.y + (BuildMenu.size.y * build_menu_is_moving))
		build_weight = 0
		
	if build_menu_is_moving != 0:
		var adjusted_weight: float = clamp(build_weight * BUILD_MENU_MOVE_SPEED, 0, 1)
		BuildMenu.position.y = lerp(build_menu_positions.x, build_menu_positions.y, adjusted_weight)
		build_weight += delta
		
		if adjusted_weight >= 1:
			build_menu_is_moving = 0
			reset_mblocker_rects()
			
	if active_tile_state != 2 and !Input.is_action_pressed(Helper.interact_button()):
		active_tile_state = 2
		for child in World.get_node("Tiles").get_children():
			child.active_tile_possible_state = 2

	if info_menu_is_moving != 0:
		var adjusted_weight: float = clamp(info_weight * INFO_MENU_MOVE_SPEED, 0, 1)
		InfoMenu.position.x = lerp(info_menu_positions.x, info_menu_positions.y, adjusted_weight)
		info_weight += delta
		
		if adjusted_weight >= 1:
			info_menu_is_moving = 0
			reset_mblocker_rects()

func on_move_build_menu() -> void:
	build_menu_is_moving = true
	
func on_move_screen_switch() -> void:
	load_world.emit(World)
	
func _ready() -> void:
	on_setup_tabs()
	build_folders = [build_folders[0], build_folders[3], build_folders[2], build_folders[4], build_folders[1]]
#	for child in mblockers:
#		child.mouse_entered.connect(func(): for tile in World.get_node("Tiles").get_children(): tile.on_check_mouse_entered())
#		child.mouse_exited.connect(func(): for tile in World.get_node("Tiles").get_children(): tile.on_check_mouse_entered())
	on_load_tab(0)
	reset_mblocker_rects()
	for btn in [ArrowButton,  $BuildMenu/LoadedMenu/LeftArrow, $BuildMenu/LoadedMenu/RightArrow]:
		Helper.create_button_clickmask(btn)
		btn.pressed.connect((func(): AudioMaster.play_sfx(preload("res://scenes/screens/level_editor/arrow/woosh.wav"))))
	BuildMenu.get_node("WarningLabel").text = "Make sure to load in an area, silly!"
	BuildMenu.get_node("Tabs").visible = false
	BuildMenu.get_node("LoadedMenu").visible = false
	BuildMenu.position.y += BuildMenu.size.y
	admin()

func reset_mblocker_rects() -> void:
	mblocker_rects = mblockers.map(func(x: Control): return Rect2i(x.global_position, x.size))

func _on_load_area_pressed():
	var FileLoader: Control = preload("res://scenes/editor/file_loader/file_loader.tscn").instantiate()
	FileLoader.on_ready("Area")
	FileLoader.item_selected.connect(on_area_selected)
	add_child(FileLoader)

func on_area_selected(item: Dictionary) -> void:
	loaded_area = item
	Helper.load_area_colors(self, item.pcolor, item.acolor)
	on_load_empty_level()
	if !loaded_level:
		on_build_menu_enabled()

func on_load_level(info: Dictionary) -> void:
	match loaded_level:
		false: on_build_menu_enabled(); loaded_level = true
		_: _on_save_level_pressed(false, 2)
	
	EditFileName.set_text(info.iname, info.sname)
	on_area_selected(Helper.id_to_dict(info.area, "Area"))
	level_difficulty = info.difficulty
	LevelDifficulty.select_item(level_difficulty - 1)
	
	for child in World.get_node("Tiles").get_children(): child.queue_free()
	var lastx: int = 0
	for i in info.tiles:
		if i[1] != lastx: offset = 0
		lastx = i[1]
		var tile: Node3D = create_tile(Vector3(i[1], i[2], i[4]))
		tile.info = {"active_tile": i[6], "tid": i[0], "position": Vector4(i[1], i[2], i[3], i[4]), "area": i[5]}
		tile.load_tid(tile.info.tid)

func on_load_empty_level(save_level: bool = true) -> void:
	LevelDifficulty.select_item(0)
	if save_level: _on_save_level_pressed(false, 2)
	EditFileName.set_text("")
	for child in World.get_node("Tiles").get_children(): child.queue_free()
	
	for x in range(-grid_half_size, grid_half_size + 1):
		offset = 0
		for y in range(-grid_half_size, grid_half_size + 1):
			var tile: Node3D = create_tile(Vector3(x, y, 0))
			tile.info = {"active_tile": true, "tid": 0, "position": Vector4(x, y, -x - y, 0), "area": loaded_area.id}
			tile.load_tid(0)
	loaded_level = true

func create_tile(xy: Vector3) -> Node3D:
	var tile: Node3D = preload("res://assets/models/tiles/editor_tile.tscn").instantiate()
	tile.position = Vector3((xy.x * dx) + offset, xy.z, xy.y * 1.5)
	tile.active_tile_change_state.connect(on_active_tile_change_state)
	tile.get_node("DetectMouse").mouse_entered.connect(func(): tile._on_detect_mouse_mouse_entered(mblocker_rects))
	World.get_node("Tiles").add_child(tile)
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
	add_child(FileLoader)
	
	if loaded_area:
		FileLoader.set_search(str(loaded_area.id), 3)

func _on_save_level_pressed(play_sfx: bool = true, create_temp: int = 1):
	if loaded_level:
		var contents: String = "%s\n%s\n%s\n" % [loaded_area.id, level_difficulty,
		World.get_node("Tiles").get_children().map(func(x: Node3D): return x.info)
		.map(func(x: Dictionary) :return\
		[x.tid, x.position.x, x.position.y, x.position.z, x.position.w, x.area, x.active_tile])]
		match Helper.write_to_base_game_file(FILE_LOADER_NAME, EditFileName, contents, TID):
			{}: if play_sfx: AudioMaster.play_sfx(preload("res://assets/sounds/confirmation/unconfirm_default.wav"), -10)
			_: if play_sfx: AudioMaster.play_sfx(preload("res://assets/sounds/confirmation/confirm_default.wav"), -10)
		
		if Settings.clear_backup_files_array[Settings.clear_backup_files] != 1:
			Helper.write_to_file("user://save/temp/levels/", EditFileName.get_node("Showcase").text + ["", "_save", "_override"][create_temp], ".txt", contents)
		
func _queue_free() -> void:
	_on_save_level_pressed(false, 0)
	load_world.emit(null)

func on_active_tile_change_state(x: bool) -> void:
	if active_tile_state == 2:
		active_tile_state = int(x)
		for child in World.get_node("Tiles").get_children():
			child.active_tile_possible_state = active_tile_state

func _on_arrow_button_pressed():
	if info_menu_is_moving == 0:
		info_weight = 0
		info_menu_is_moving = 1 if InfoMenu.position.x < 0 else -1
		info_menu_positions = Vector2(InfoMenu.position.x, InfoMenu.position.x + ((InfoMenu.size.x - 80) * info_menu_is_moving))

func _on_level_difficulty_item_selected(i: int):
	level_difficulty = i + 1

var build_folders: Array = ["res://assets/models/"]
var selected_item_pos: Array
var folder_pos: Array

func on_load_tab(i: int):
	on_load_model(false)
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
		if Array(DirAccess.get_files_at(fpath)).any(func(x: String): return x.ends_with(".glb")):
			for directory_two in DirAccess.get_directories_at(fpath):
				on_setup_tabs(current_folder[i])
				
			for file in Array(DirAccess.get_files_at(fpath)).filter(func(x: String): return x.ends_with(".glb")):
				current_folder[i].append(file)
		folder_pos.remove_at(folder_pos.size() - 1)
		i += 1
	
func get_folder_path(pos: Array = folder_pos, get_item: bool = false) -> String:
	var path: String = build_folders[0]
	var arr: Array = build_folders
	var i: int = 1
	for key in pos:
		if !get_item or get_item and i != pos.size():
			arr = arr[key]
			path += arr[0]
		else: path += arr[key]
		i += 1
	return path

func get_folder_contents(pos: Array = folder_pos) -> Array:
	var contents: Array = build_folders
	for key in pos:
		contents = contents[key]
	return contents

var loaded_items: Array
var current_page: int = 1
const ITEM_COUNT_ONE_PAGE: int = 12

func on_load_folder() -> void:
	BackArrow.visible = !(folder_pos.size() == 0)
	$BuildMenu/LoadedMenu/LeftArrow.disabled = (current_page == 1)
	$BuildMenu/LoadedMenu/RightArrow.disabled = ceil(float((get_folder_contents().size() - 1)) / ITEM_COUNT_ONE_PAGE) <= current_page

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
					item.get_node("Label").text = item_contents.left(-4).capitalize()
					BuildMenuWorld.add_item(get_folder_path(folder_pos + [i], true))
					item.get_node("Button").pressed.connect(on_item_pressed.bind(i))
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
	var has_pressed: bool = selected_item_pos == folder_pos + [i]
	if !has_pressed:
		selected_item_pos = folder_pos + [i]
	else: selected_item_pos = []
	modulate_items()
	on_load_model(!has_pressed)

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
	var j: int = 0 if selected_item_pos.is_empty() or !(folder_pos.size() == selected_item_pos.size() - 1) else selected_item_pos[selected_item_pos.size() - 1]
	if j > 0:
		for i in range(folder_pos.size()):
			if folder_pos[i] != selected_item_pos[i]:
				j = 0
				break
	
	var n: int = 1
	for btn in Items.get_children():
		if !btn.is_queued_for_deletion():
			btn.modulate = Helper.LIGHT_GREY if n == j else Helper.BASE
			n += 1
