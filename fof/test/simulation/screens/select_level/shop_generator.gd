extends Control
var can_drag: bool = false
var held: bool = true

func _on_destroy_button_pressed(): queue_free()

func on_generate_world(_difficulty: int) -> void:
	for child in $RolledCards.get_children(): child.free()
	var options: int = 3
	var roll_options: Array = ["RemoveCard", "Aura", "Boon", "Transform"]
	var roll_rarity: Array = [0.6, 0.35, 0.05]
	var rarities: Array = ["Common", "Rare", "Exalt"]
	
	match _difficulty:
		0, 1: roll_options = ["Aura", "Boon", "TransformEnergy"]
		2: roll_rarity = [0.4, 0.5, 0.1]
		3: options = 4; roll_rarity = [0.15, 0.55, 0.25]
	
	var roll_results: Array = []
	for option in range(options):
		var roll_i: float = randf()
		var total: float = 0
		var odds: float = 1.0 / roll_options.size()
		var i: int = 1
		for roll_option in roll_options:
			odds *= i
			if roll_i >= total and roll_i <= odds:
				if roll_option == "Transform" and roll_option in roll_results: roll_options.erase(roll_option)
				roll_results.append(roll_option)
				if roll_option in ["RemoveCard", "TransformEnergy", "TransformRarity"]: roll_options.erase(roll_option)
				break
			total = odds
			i += 1
	
	var j: int = 0
	for result in roll_results:
		match result:
			"Transform":
				var break_loop: bool = false
				for _result in roll_results:
					match _result:
						"TransformEnergy": roll_results[j] = "TransformRarity"; break_loop = true
						"TransformRarity": roll_results[j] = "TransformEnergy"; break_loop = true
					if break_loop: break
				if roll_results[j] == "Transform":
					roll_results[j] = ["TransformEnergy", "TransformRarity"][randi() % 2]
			"Aura", "Boon":
				var roll: float = randf()
				var i: int = 0
				var old_total: float = 0
				var full_total: float = 0
				
				for rarity in roll_rarity:
					full_total += rarity
					if roll >= old_total and roll <= full_total:
						roll_results[j] = result.insert(0, rarities[i])
						break
						
					old_total += rarity
					i += 1
		j += 1
		
	var card_results: Array = []
	for result in roll_results: 
		if result == "TransformRarity" and _difficulty == 3:
			result = "TransformRarity+1"
		
		if result.ends_with("Aura") or result.ends_with("Boon"):
			var path: String = "boons"
			if result.ends_with("Aura"): path = "auras"
			var dirfiles: Array = DirAccess.open("user://savefofle/auras_boons/" + path).get_files()
			var file_names: Array = Array(FileAccess.open("user://savefofle/loaded_boons.txt", FileAccess.READ).get_as_text().split("\n", false))
			dirfiles = dirfiles.filter(func(x: String): return x not in file_names)
			var rarity_result: int = 0
			if result.begins_with("Rare"): rarity_result = 1
			elif result.begins_with("Exalt"): rarity_result = 2
			return_matching_rarity_recursive([rarity_result, path, dirfiles], [], card_results)
			var auraboon: Control = load("res://test/simulation/screens/select_level/" + path.left(-1) + ".tscn").instantiate()
			if path == "boons": auraboon.load_boon(card_results[card_results.size() - 1])
			elif path == "auras": auraboon.load_aura(card_results[card_results.size() - 1])
			$RolledCards.add_child(auraboon)
			
			if result.ends_with("Boon"):
				auraboon.get_node("DestroyButton").pressed.disconnect(auraboon._on_destroy_button_pressed)
				auraboon.get_node("DestroyButton").pressed.connect(get_parent().on_boon_selected.bind(auraboon.get_node("Name").text + ".txt"))
			else: auraboon.get_node("DestroyButton").queue_free()
		else:
			var sprite := Sprite2D.new()
			sprite.texture = load("res://test/simulation/assets/shop_rolls/" + result + ".png")
			sprite.centered = false
			$RolledCards.add_child(sprite)
		
	sort_rolled_results()
		
func return_matching_rarity_recursive(info: Array, x: Array, y: Array) -> void:
	if x.size() > 0 and x not in y: y.append(x); return
	return_matching_rarity_recursive(info, return_matching_rarity(info[0], info[1], info[2]), y)
	
func sort_rolled_results() -> void:
	var total_x: int = 0
	if $RolledCards.get_child_count() == 3: total_x += 150
	for child in $RolledCards.get_children():
		child.position.y = 6
		child.position.x = total_x
		total_x += 300
		
func return_matching_rarity(rarity: int, path: String, dirfiles: Array) -> Array:
	var contents: Array = return_path_contents(path, dirfiles).filter(func(x: Array): return int(x[3]) == rarity)
	return contents[randi() % contents.size()]
	
func return_path_contents(path: String, dirfiles: Array) -> Array:
	return dirfiles.map(func(_file: String): return FileAccess.open("user://savefofle/auras_boons/" + path + "/" + _file, FileAccess.READ).get_as_text().split("\n", false))

func _process(_delta: float) -> void:
	if can_drag or held:
		if Input.is_action_just_pressed("LeftClick"):
			held = true
		elif Input.is_action_pressed("LeftClick") and held:
			position.x = (get_viewport().get_mouse_position().x) - 1200
			position.y = (get_viewport().get_mouse_position().y) - 200
		else:
			held = false

func _on_grab_zone_mouse_entered():
	can_drag = true

func _on_grab_zone_mouse_exited():
	can_drag = false
