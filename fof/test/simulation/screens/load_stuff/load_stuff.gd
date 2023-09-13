extends Control

@onready var parent: Control = get_tree().get_root().get_child(0)
var load_path: String

const base_load_card_path: String = "user://savefofle/cards"
const base_load_level_path: String = "user://savefofle/levels"
const base_load_aura_path: String = "user://savefofle/auras_boons/auras"
const base_load_boon_path: String = "user://savefofle/auras_boons/boons"
const base_load_aura_boon_path: String = "user://savefofle/auras_boons"

signal card_selected
signal level_selected
signal aura_selected
signal boon_selected

var load_state: int = 0
var confirm_deletion: bool = true

func _on_exit_button_pressed(): queue_free()
func _ready() -> void:
	load_stuff()

func load_stuff():
	var load_stuff_scene: PackedScene = preload("res://test/simulation/screens/load_stuff/load_stuff_button.tscn")
	for child in $LoadZone.get_children(): $LoadZone.remove_child(child); child.queue_free()
	match load_state:
		0: load_path = parent.load_card_path
		1: load_path = parent.load_level_path
		2: load_path = parent.load_aura_path
		3: load_path = parent.load_boon_path
		5: load_path = parent.load_aura_boon_path
		
	for dir in DirAccess.open(load_path).get_directories():
		var load_stuff_node: Control = load_stuff_scene.instantiate()
		var load_stuff_button: Button = load_stuff_node.get_node("LoadStuff")
		load_stuff_node.get_node("DestroyButton").queue_free()
		load_stuff_button.text = dir
		load_stuff_button.pressed.connect(on_load_directory.bind("/" + dir))
		$LoadZone.add_child(load_stuff_node)
		
	for file in Array(DirAccess.open(load_path).get_files()).filter(func(x: String): return x.ends_with(".txt")):
		var load_stuff_node: Control = load_stuff_scene.instantiate()
		var load_stuff_button: Button = load_stuff_node.get_node("LoadStuff")
		load_stuff_button.text = file.left(-4)
		load_stuff_button.pressed.connect(on_load_stuff.bind(file))
		load_stuff_node.get_node("DestroyButton").pressed.connect(on_destroy_button_pressed.bind(load_stuff_node, file))
		$LoadZone.add_child(load_stuff_node)
		
		if load_state == 0:
			var nfile := FileAccess.open(parent.load_card_path + "/" + file, FileAccess.READ)
			var card_info: Array = nfile.get_as_text().split("\n")
			var rarity: int = 0
			load_stuff_button.text += " | " + str(card_info[6])
			if card_info.size() > 7: rarity = int(card_info[7])
			match rarity:
				0: load_stuff_node.modulate = Color(0.43,0.43,0.43,1)
				1: load_stuff_node.modulate = Color(0.31, 0.478, 0.439,1)
				2: load_stuff_node.modulate = Color(0.966, 0.697, 0.253,1)
				3: load_stuff_node.modulate = Color(0.639, 0.075, 0.722,1)
				4: load_stuff_node.modulate = Color(0.773, 0.031, 0.141,1)
				5: load_stuff_node.modulate = Color(0.374, 0.6, 1, 1)
				6: load_stuff_node.modulate = Color(0.196, 0.196, 0.196, 1)
		elif load_state in [2, 3, 5]:
			match int(FileAccess.open(load_path + "/" + file, FileAccess.READ).get_as_text().split("\n", false)[3]):
				0: load_stuff_node.modulate = Color(0.43,0.43,0.43,1)
				1: load_stuff_node.modulate = Color(0.31, 0.478, 0.439,1)
				2: load_stuff_node.modulate = Color(0.966, 0.697, 0.253,1)
				3: load_stuff_node.modulate = Color(0.639, 0.075, 0.722,1)
				4: load_stuff_node.modulate = Color(0.773, 0.031, 0.141,1)
				5: load_stuff_node.modulate = Color(0.374, 0.6, 1, 1)
				6: load_stuff_node.modulate = Color(0.196, 0.196, 0.196, 1)
	$Path.text = load_path
	var x: int = 0
	var y: int = 0
	for child in $LoadZone.get_children():
		if child.is_inside_tree():
			child.position.x += x
			child.position.y += y
			x += 340
			if x >= (340) * 5:
				x = 0
				y += 90
			
func on_load_directory(dir_name: String) -> void:
	match load_state:
		0: parent.load_card_path += dir_name
		1: parent.load_level_path += dir_name
		2: parent.load_aura_path += dir_name
		3: parent.load_boon_path += dir_name
		5: parent.load_aura_boon_path += dir_name
	load_stuff()

func _on_back_button_pressed():
	match load_state:
		0:
			if parent.load_card_path != base_load_card_path:
				var last_slash: int = parent.load_card_path.rfind("/")
				parent.load_card_path = parent.load_card_path.substr(0, last_slash)
		1: 
			if parent.load_level_path != base_load_level_path:
				var last_slash: int = parent.load_level_path.rfind("/")
				parent.load_level_path = parent.load_level_path.substr(0, last_slash)
		2:
			if parent.load_aura_path != base_load_aura_path:
				var last_slash: int = parent.load_aura_path.rfind("/")
				parent.load_aura_path = parent.load_aura_path.substr(0, last_slash)
		3:
			if parent.load_boon_path != base_load_boon_path:
				var last_slash: int = parent.load_boon_path.rfind("/")
				parent.load_boon_path = parent.load_boon_path.substr(0, last_slash)
		5:
			if parent.load_aura_boon_path != base_load_aura_boon_path:
				var last_slash: int = parent.load_aura_boon_path.rfind("/")
				parent.load_aura_boon_path = parent.load_aura_boon_path.substr(0, last_slash)
	load_stuff()

func on_load_stuff(file: String) -> void:
	match load_state:
		0: 
			var new_load_path: String = parent.load_card_path.right(parent.load_card_path.length() - base_load_card_path.length())
			if new_load_path: new_load_path += "/"
			else: new_load_path.insert(0, "U")
			card_selected.emit(new_load_path + file)
		1:
			var new_load_path: String = parent.load_level_path.right(parent.load_level_path.length() - base_load_level_path.length())
			if new_load_path: new_load_path += "/"
			else: new_load_path.insert(0, "U")
			level_selected.emit(new_load_path + file)
		2:
			var new_load_path: String = parent.load_aura_path.right(parent.load_aura_path.length() - base_load_aura_path.length())
			if new_load_path: new_load_path += "/"
			else: new_load_path.insert(0, "U")
			aura_selected.emit(new_load_path + file)
		3:
			var new_load_path: String = parent.load_boon_path.right(parent.load_boon_path.length() - base_load_boon_path.length())
			if new_load_path: new_load_path += "/"
			else: new_load_path.insert(0, "U")
			boon_selected.emit(new_load_path + file)
		5:
			var new_load_path: String = parent.load_aura_boon_path.right(parent.load_aura_boon_path.length() - base_load_aura_boon_path.length())
			if new_load_path: new_load_path += "/"
			else: new_load_path.insert(0, "U")
			
			if new_load_path.contains("boons"): boon_selected.emit(new_load_path + file)
			elif new_load_path.contains("auras"): aura_selected.emit(new_load_path + file)
			
func on_destroy_button_pressed(node: Control, file: String) -> void:
	match confirm_deletion:
		true:
			var confirm_deletion_node: Control = preload("res://test/simulation/screens/load_stuff/confirm_deletion.tscn").instantiate()
			add_child(confirm_deletion_node)
			for child in confirm_deletion_node.get_node("Buttons").get_children():
				match child.name:
					"Yes": child.pressed.connect(on_delete_stuff.bind(node,file,confirm_deletion_node))
					"No": child.pressed.connect(func(): confirm_deletion_node.queue_free())
		false: on_delete_stuff(node, file, null)

func on_delete_stuff(node: Control, file: String, confirm_deletion_node: Control) -> void:
	node.queue_free()
	if confirm_deletion_node != null:
		confirm_deletion_node.queue_free()
	
	var path: String
	match load_state:
		0: path = parent.load_card_path
		1: path = parent.load_level_path
		5: path = parent.load_aura_boon_path
		
	var dir := DirAccess.open(path)
	dir.remove(file)
	
