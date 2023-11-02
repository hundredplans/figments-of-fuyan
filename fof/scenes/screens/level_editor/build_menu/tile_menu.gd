extends Control
signal queued
signal delete
signal copy
signal move
signal paste
signal bucket
signal rotate_full
signal rotate_direction
signal highlight_tiles
signal spawn

signal update_item_rotations
signal update_tile_menu

signal fill_wall
signal tile_wall
signal wall_height
signal item_type

@onready var signals: Array[Signal] = [
	delete, copy, move, paste, bucket, rotate_full, rotate_direction, 
	highlight_tiles, queued, spawn, fill_wall, tile_wall, wall_height,
	item_type]
	
var tiles: Array
var items: Array

@onready var CollisionShape = $DetectMouse/CollisionShape2D

func _ready():
	load_option(0, tiles)
	var options: Array = ["tile", "obj", "wall", "wdeco", "tdeco"]
	for i in range(options.size()):
		for tile in tiles:
			if tile.info[options[i]].id > 0 or options[i] == "tile" and Settings.select_empty_tiles:
				load_option(i + 1, tiles)
				break
				
	position = get_viewport().get_mouse_position()
	position.y -= size.y / 2
	for i in [["x", 1920], ["y", 1080]]:
		if position[i[0]] + size[i[0]] > i[1]: position[i[0]] -= (position[i[0]] + size[i[0]] - i[1]) + 5 
		elif position[i[0]] < 0: position[i[0]] = 0 + 5
	CollisionShape.shape.size.y = size.y + 10
	CollisionShape.position.y = (CollisionShape.shape.size.y / 2) - 5

func load_option(option_type: int, ntiles: Array) -> void:
	var tile_menu_item: Control = preload("res://scenes/screens/level_editor/build_menu/tile_menu_item.tscn").instantiate()
	tile_menu_item.item = option_type
	tile_menu_item.position.y = size.y
	tile_menu_item.tiles = ntiles
	tile_menu_item.parent = self
	update_tile_menu.connect(tile_menu_item.on_update_tile_menu)
	$Items.add_child(tile_menu_item)
	items.append(tile_menu_item)
	size.y += 178

func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("LeftClick") and !Input.is_action_just_pressed("ShiftLeftClick") and !Rect2(CollisionShape.global_position - (CollisionShape.shape.size / 2), CollisionShape.shape.size).has_point(get_viewport().get_mouse_position())\
	or Input.is_action_just_pressed(Helper.interact_button())) and get_parent().selection_tiles.size() == 0:
		_queued_free()

func _queued_free() -> void:
	queued.emit(self)

func on_update_tile_menu() -> void: update_tile_menu.emit()
