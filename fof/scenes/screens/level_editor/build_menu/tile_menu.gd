extends Control
signal queued

var tiles: Array
var items: Array

@onready var CollisionShape = $DetectMouse/CollisionShape2D

func _ready():
	load_option(0, tiles)
	var options: Array = ["tile", "obj", "wall", "deco"]
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

func load_option(option_type: int, tiles: Array) -> void:
	var tile_menu_item: Control = preload("res://scenes/screens/level_editor/build_menu/tile_menu_item.tscn").instantiate()
	tile_menu_item.item = option_type
	tile_menu_item.position.y = size.y
	$Items.add_child(tile_menu_item)
	items.append(tile_menu_item)
	tile_menu_item.tiles = tiles
	size.y += 200

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("LeftClick") and !Rect2(CollisionShape.global_position - (CollisionShape.shape.size / 2), CollisionShape.shape.size).has_point(get_viewport().get_mouse_position())\
	or Input.is_action_just_pressed(Helper.interact_button()):
		_queued_free()

func _queued_free() -> void:
	queued.emit(self)
	queue_free()
