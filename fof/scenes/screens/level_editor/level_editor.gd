extends Control
signal change_fileloader_state

var tiles: Dictionary
@onready var Tiles = $WorldContainer/World/World/Tiles
@onready var LoadButtons = $LoadButtons
@onready var BuildMenu = $BuildMenu

const BUILD_MENU_MOVE_SPEED: float = 4
const TID: int = 5
const FILE_LOADER_NAME: String = "Level"
var loaded_area: Dictionary
var loaded_level: Dictionary

var build_menu_positions := Vector2.ZERO
var build_weight: float = 0
var build_menu_is_moving: int = 0

func _process(delta: float) -> void:
	
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

func on_move_build_menu() -> void:
	build_menu_is_moving = true

func _ready() -> void:
	BuildMenu.get_node("WarningLabel").text = "Make sure to load in an area, silly!"
	BuildMenu.get_node("Tabs").visible = false
	BuildMenu.position.y += BuildMenu.size.y

func _on_load_area_pressed():
	var FileLoader: Control = preload("res://scenes/editor/file_loader/file_loader.tscn").instantiate()
	FileLoader.on_ready("Area")
	FileLoader.item_selected.connect(on_area_selected)
	add_child(FileLoader)

func on_area_selected(item: Dictionary) -> void:
	loaded_area = item
	Helper.load_area_colors(self, item.pcolor, item.acolor)
	
	if !loaded_level:
		on_build_menu_enabled()
	
	on_load_empty_level()

func on_load_empty_level() -> void:
	for child in Tiles.get_children(): child.queue_free()
	var tile_packed: PackedScene = preload("res://assets/models/tiles/null_tile/null_tile.tscn")
	Tiles.add_child(tile_packed.instantiate())
	
func on_build_menu_enabled() -> void:
	BuildMenu.get_node("WarningLabel").text = ""
	BuildMenu.get_node("Tabs").visible = true

func _on_load_empty_pressed():
	if !loaded_area: _on_load_area_pressed()
	else: on_load_empty_level()

func _on_load_level_pressed():
	if !loaded_area: _on_load_area_pressed()
	else: pass

func _on_save_level_pressed():
	if !loaded_area: _on_load_area_pressed()
	else: pass
