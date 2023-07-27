extends Node2D

var active_arrow_state: int = 0
var active_tile_state: int = 0
var active_tile_item: String
const tile_size: int = 60
const tile_x_offset: int = 30
const tile_y_offset: int = 50

var current_page: int = 0
var max_page: int = 0
var max_cards_on_page: int = 6
var all_cards: Array
const tile_amount: int = 800
const tile_rows: int = 28
@onready var tile_default: PackedScene = preload("res://assets/map/tile/tile.tscn")

func _ready():
	
	var x: int = 0
	var y: int = 0
	var trigger_offset: int = 0
	for i in range(tile_amount):
		var tile: Node2D = tile_default.instantiate()
		$FakeTiles.add_child(tile)
		if x >= tile_rows:
			x = 0
			y += 1
			trigger_offset = 1 - trigger_offset
			
		tile.position.x += x * tile_size + (trigger_offset * tile_x_offset)
		tile.position.y += y * tile_y_offset
		x += 1
		tile.tile_position = Vector2(x, y)

	for child in $ChooseColor/TileStates.get_children():
		child.pressed.connect(on_change_active_tile_state.bind(child.name))
		
	for child in $AddArrows/ArrowStates.get_children():
		child.pressed.connect(on_change_active_arrow_state.bind(child.name))
		
	on_change_active_arrow_state("0")
	on_change_active_tile_state("0")
	
	var file_names: PackedStringArray = DirAccess.open("res://assets/sprites").get_files()
	file_names = Array(file_names).filter(func(x: String): return x.ends_with(".import"))
	for file in file_names:
		all_cards.append(file.replace(".import", ""))
	
	max_page = ceil(float(file_names.size()) / max_cards_on_page) - 1
	on_load_cards()
	
func on_load_cards():
	for child in $AddItem/Sprites.get_children(): child.free()
	for i in range(current_page * max_cards_on_page, (current_page + 1) * max_cards_on_page):
		if i < all_cards.size():
			var sprite := TextureButton.new()
			sprite.texture_normal = load("res://assets/sprites/%s" % all_cards[i])
			$AddItem/Sprites.add_child(sprite)
			sprite.pressed.connect(on_art_max_pressed.bind(all_cards[i]))
		
	var y: int = 0
	for child in $AddItem/Sprites.get_children():
		child.position.y += y
		y += 140
		
func on_art_max_pressed(item_name: String):
	active_tile_item = item_name
		
func on_change_active_arrow_state(arrow_name: String) -> void:
	active_arrow_state = int(arrow_name)
	for child in $AddArrows/ArrowStates.get_children():
		match child.name:
			arrow_name: child.modulate = Color(1,1,1,1)
			_: child.modulate = Color(1,1,1,0.6)
			
func on_change_active_tile_state(tile_name: String) -> void:
	active_tile_state = int(tile_name)
	for child in $ChooseColor/TileStates.get_children():
		match child.name:
			tile_name: child.modulate = Color(1,1,1,1)
			_: child.modulate = Color(1,1,1,0.6)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("MouseUp"):
		if active_tile_state > 0:
			on_change_active_tile_state(str(active_tile_state - 1))
			
	elif Input.is_action_just_pressed("MouseDown"):
		if active_tile_state < $ChooseColor/TileStates.get_children().size() - 1:
			on_change_active_tile_state(str(active_tile_state + 1))

	if Input.is_action_just_pressed("Escape"):
		queue_free()

func _on_save_level_button_pressed():
	var i: int = 0
	while FileAccess.file_exists("res://data/save/levels/%s.txt" % i):
		i += 1
	var file := FileAccess.open("res://data/save/levels/%s.txt" % i, FileAccess.WRITE)
	var write_string: String = ""
	for tile in $FakeTiles.get_children():
		if tile.tile_state != 0:
			write_string += "%s,%s,%s,%s,%s\n" % [tile.tile_position.x, tile.tile_position.y, tile.tile_state, tile.tile_item, tile.arrow_state]

	file.store_string(write_string)
	file = null

func _on_clear_tiles_pressed():
	on_change_active_arrow_state("0")
	on_change_active_tile_state("0")
	_on_clear_selection_pressed()
	for tile in $FakeTiles.get_children():
		tile._on_inside_pressed()

func _on_down_pressed():
	if current_page > 0:
		current_page -= 1
		on_load_cards()

func _on_up_pressed():
	if current_page < max_page:
		current_page += 1
		on_load_cards()

func _on_clear_selection_pressed():
	active_tile_item = ""

func _on_load_level_pressed():
	var levelloader = preload("res://screens/create_level/load_level.tscn").instantiate()
	add_child(levelloader)
	levelloader.load_level.connect(on_load_level)
	
func on_load_level(level_name: String) -> void:
	_on_clear_tiles_pressed()
	var lvl_path: String = "res://data/save/levels/%s.txt" % level_name
	var file := FileAccess.open(lvl_path, FileAccess.READ)
	var tiles: Array = []
	for tile_info in file.get_as_text().split("\n"):
		var tii: Array = tile_info.split(",")
		if tii.size() == 5:
			tiles.append([Vector2(tii[0].to_int(), tii[1].to_int()), tii[2].to_int(), tii[3], tii[4].to_int()])
		
	for tile_info in tiles:
		active_tile_state = tile_info[1]
		active_tile_item = tile_info[2]
		active_arrow_state = tile_info[3]
		for tile in $FakeTiles.get_children():
			if tile.tile_position == tile_info[0]:
				tile._on_inside_pressed()
	
	on_change_active_arrow_state("0")
	on_change_active_tile_state("0")
	_on_clear_selection_pressed()
	file = null
	
	
