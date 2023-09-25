extends Control
signal change_fileloader_state

const TID: int = 1
const file_loader_name: String = "Area"
var world_difficulty: int = 1
var area_name: String
var primary_color: Color = Color("000000")
var accent_color: Color = Color("ffffff")
var cards_allowed: Array
var tiles_allowed: Array

var primary_color_selected: bool = false
var choose_color := Color(0x00000000)

func _ready():
	modulate_all()
	load_primary_and_accent_colors()
	var available_colors: Array = Helper.return_file_contents("res://static/screens/area_editor/available_colors.txt").split("\n", false)
	if available_colors.size() > 0:
		var primary_container: bool = false
		for container in [$Buttons/Colors/PrimaryColor/Colors, $Buttons/Colors/AccentColor/Colors]:
			primary_container = !primary_container
			var color_rect_size: int = floor(container.size.x / available_colors.size())
			var next_position: float = 0
			var i: int = 1
			for hexcolor in available_colors:
				if hexcolor.length() == 6:
					var color_rect := ColorRect.new()
					color_rect.color = Color(hexcolor)
					color_rect.size = Vector2(color_rect_size, container.size.y)
					if i == available_colors.size(): color_rect.size.x = container.size.x - next_position
					color_rect.position.x = next_position
					color_rect.mouse_entered.connect(func(): choose_color = hexcolor; primary_color_selected = primary_container)
					color_rect.mouse_exited.connect(func(): choose_color = 0x00000000)
					
					next_position = color_rect.size.x + color_rect.position.x
					container.add_child(color_rect)
					i += 1
				else: print_debug("Your: %s value is incorrectly formatted, are you perhaps using RGB values?" % hexcolor)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("LeftClick"):
		if choose_color != Color(0x00000000):
			match primary_color_selected:
				true: primary_color = choose_color
				false: accent_color = choose_color
			load_primary_and_accent_colors()

func load_primary_and_accent_colors() -> void:
	for child in Helper.get_children_recursive(self):
		if child.name.begins_with("PR"):
			if child is ColorRect: child.color = primary_color
			else: child.modulate = primary_color
		elif child.name.begins_with("AC"):
			if child is ColorRect: child.color = accent_color
			else: child.modulate = accent_color

func modulate_all() -> void:
	modulate_world_difficulty_buttons()
	
func modulate_world_difficulty_buttons() -> void:
	var i: int = 0
	for child in $Buttons/WorldDifficulty.get_children():
		if child as Button:
			i += 1
			if i == world_difficulty: child.modulate = Helper.RED
			else: child.modulate = Helper.BASE
	
func _on_world_difficulty_pressed(_world_difficulty: int): 
	world_difficulty = _world_difficulty
	modulate_world_difficulty_buttons()

func _on_save_area_pressed():
	var contents: String = "%s\n%s\n%s\n%s\n%s" % [str(primary_color), str(accent_color), str(world_difficulty), cards_allowed, tiles_allowed]
	Helper.write_to_base_game_file("res://static/base_game/areas/", $Buttons/EditFileName, contents, TID)

func _on_load_area_pressed():
	var FileLoader: Control = preload("res://scenes/editor/file_loader/file_loader.tscn").instantiate()
	FileLoader.on_ready(file_loader_name)
	FileLoader.item_selected.connect(on_item_selected)
	add_child(FileLoader)
	
func on_item_selected(item_info: Dictionary) -> void:
	_on_world_difficulty_pressed(item_info.world)
	primary_color = item_info.pcolor
	accent_color = item_info.acolor
	load_primary_and_accent_colors()
	$Buttons/EditFileName.set_text(item_info.iname, item_info.sname)
