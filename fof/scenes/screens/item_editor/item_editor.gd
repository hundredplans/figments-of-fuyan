extends Control

@onready var Tiles: Node3D = $ViewTile/SubViewport/Tiles
@onready var ItemName: Label = $ItemName
@onready var ItemSettings: Control = $ItemSettings
@onready var Items: Control = $AvailableItems/Items

var item_settings: Dictionary
var selected_item: Vector2i
var id_to: Array = Helper._id_to

func _ready():
	_on_item_type_item_selected(0)

func _on_item_type_item_selected(i: int) -> void:
	for child in Tiles.get_children(): child.queue_free()
	ItemName.text = ""
	for child in ItemSettings.get_children(): child.queue_free()
	item_settings = {}
	selected_item = Vector2i.ZERO
	for child in Items.get_children(): child.queue_free()
	
	var y: int = 0
	for n in range(id_to[i + 1].size()):
		if n > 0:
			var btn := Button.new()
			Items.add_child(btn)
			btn.size.x = Items.size.x
			btn.text = convert_item_name(id_to[i + 1][n])
			btn.position.y = y
			btn.pressed.connect(on_item_selected.bind(Vector2(i + 1, n)))
			y += 31

func convert_item_name(n: String) -> String:
	return n.split("/")[n.get_slice_count("/") - 1]

const SELECTED_ITEM_X: Dictionary = {
	1: ["Visibility", "Solidity", "Height"],
	2: ["Visibility", "Solidity"],
	3: ["Visibility", "Solidity", "Height"],
	4: ["Height"],
}

func on_item_selected(nm: Vector2) -> void:
	ItemName.text = convert_item_name(id_to[nm.x][nm.y])
	selected_item = nm
	load_item_settings()
	item_settings.id = [selected_item.x, selected_item.y]
	add_option_buttons(SELECTED_ITEM_X[int(selected_item.x)])

func load_item_settings() -> void:
	var items: Array = Array(Helper.return_file_contents("user://save/item_properties.txt").split("\n", false)).map(func(x: String): return str_to_var(x))
	var has_broke: bool = false
	for item in items:
		if Vector2i(item.id[0], item.id[1]) == selected_item:
			has_broke = true
			item_settings = item
			break
			
	if !has_broke:
		item_settings = items[0]
		
	load_multi_tile()
	
func add_option_buttons(arr: Array) -> void:
	for child in ItemSettings.get_children(): child.queue_free()
	var x: int = 200
	for i in arr:
		var btn: Control
		match i:
			"Visibility":
				btn = preload("res://scenes/ui_general/op_button/op_button.tscn").instantiate()
				btn.options = ["None", "Half-Vision", "Full-Vision"]
			"Solidity":
				btn = preload("res://scenes/ui_general/binary_button/binary_button.tscn").instantiate()
			"Height":
				btn = preload("res://scenes/ui_general/op_button/op_button.tscn").instantiate()
				btn.options = [0.5, 1, 2, 3, 4, 5]
		
		if !item_settings.multi_tile:
			btn.default = item_settings["0-0-0"][i.to_lower()]
			btn.item_selected.connect(get("on_" + i.to_lower() + "_set"))
		
		btn.label_text = i
		btn.position.x = x
		
		ItemSettings.add_child(btn)
		x += 400
		
func on_solidity_set(i: int) -> void:
	item_settings["0-0-0"].solidity = i

func on_visibility_set(i: int) -> void:
	item_settings["0-0-0"].visibility = i

func on_height_set(i: int) -> void:
	item_settings["0-0-0"].height = i

func _on_save_button_pressed():
	if item_settings:
		var contents: Array = Array(Helper.return_file_contents("user://save/item_properties.txt").split("\n", false)).map(func(x: String): return str_to_var(x))
		var has_broke: bool = false
		for i in range(contents.size()):
			if Vector2i(contents[i].id[0], contents[i].id[1]) == selected_item:
				contents[i] = item_settings
				has_broke = true
				break
				
		if !has_broke: contents.append(item_settings)
		var scontents: String = ""
		for i in contents: scontents += var_to_str(i).replace("\n", "") + "\n"
		Helper.write_to_file("user://save/", "item_properties", ".txt", scontents)
	
const MODEL_BASE_PATHS: Dictionary = {
	1: "res://assets/models/objects/",
	2: "res://assets/models/walls/",
	3: "res://assets/models/decorations/tiles/",
	4: "res://assets/models/decorations/walls/",
}
	
func load_multi_tile() -> void:
	for child in Tiles.get_children(): child.queue_free()
	if !item_settings.multi_tile:
		var single_item: Node3D = preload("res://scenes/screens/item_editor/single_item.tscn").instantiate()
		var mdl: Node3D = load(MODEL_BASE_PATHS[selected_item.x] + id_to[selected_item.x][selected_item.y] + ".glb").instantiate()
		mdl.position.y = 0.3
		single_item.add_child(mdl)
		Tiles.add_child(single_item)
