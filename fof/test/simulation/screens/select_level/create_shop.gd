extends Control

var world_distinguisher: Array = [
	["Swamp", "Critters", "Bouldaak Jungle", "Palm", "Fungite"],
	["Mages", "Wild West", "Sugori", "Dwarven", "Nolaka"],
	["Varoma", "Kaluta", "Befre", "Hama Cik"]
	]
var can_drag: bool = false
var held: bool = true

func _process(_delta: float) -> void:
	if can_drag or held:
		if Input.is_action_just_pressed("LeftClick"):
			held = true
		elif Input.is_action_pressed("LeftClick") and held:
			position.x = (get_viewport().get_mouse_position().x) - 1100
			position.y = (get_viewport().get_mouse_position().y) - 217
		else:
			held = false
func _on_grab_zone_mouse_entered():
	can_drag = true
func _on_grab_zone_mouse_exited():
	can_drag = false
func _on_remove_button_pressed():
	queue_free()

func calculate_difficulty(area_name: String) -> int:
	var difficulty: int = 3
	if area_name:
		var i: int = 0
		for diff in world_distinguisher:
			if area_name in diff:
				difficulty = i + 1
				break
			i += 1
	return difficulty
	
func return_random_card_in_rarities(rarities: Array, odds: Array) -> Array:
	if rarities.all(func(x: Array): return x.size() > 0):
		var random: float = randf()
		var total: float = 0
		var i: int = 0
		for odd in odds:
			if random < odd + total:
				return rarities[i][randi() % rarities[i].size()]
			total += odd
			i += 1
	return []
	
func random_card_in_area(odds: Array, area_name: String, avoid: Array=[]) -> Array:
	var files: Array = return_file_names("user://savefofle/cards/" + area_name)
	var rarities: Array = [[],[],[]]
	for file in files:
		if avoid and file != avoid[0] + ".txt" or !avoid:
			var file_info: Array = FileAccess.open("user://savefofle/cards/" + area_name + "/" + file, FileAccess.READ).get_as_text().split("\n")
			if int(file_info[7]) in [0,1,2]:
				rarities[int(file_info[7])].append(file_info)
	
	return return_random_card_in_rarities(rarities, odds)
	
func random_card_in_another_area(odds: Array, area_name: String, difficulty: int, avoid: Array=[]) -> Array:
	var rarities: Array = [[], [], []]
	for other_area in world_distinguisher[difficulty - 1]:
		if area_name != other_area:
			var files: Array = return_file_names("user://savefofle/cards/" + other_area)
			for file in files:
				if avoid and other_area + "/" + file != avoid[0] + ".txt" or !avoid:
					var file_info: Array = FileAccess.open("user://savefofle/cards/" + other_area + "/" + file, FileAccess.READ).get_as_text().split("\n")
					file_info[0] = other_area + "/" + file_info[0]
					if int(file_info[7]) in [0,1,2]:
						rarities[int(file_info[7])].append(file_info)
	
	return return_random_card_in_rarities(rarities, odds)
	
func return_area_name() -> String:
	if get_parent().loaded_level:
		return get_parent().loaded_level.split("/", false)[0]
	return "Varoma"
	
func random_aura_boon(odds: Array, aura_boon: String, avoid: String="") -> Array:
	var files: Array = return_file_names("user://savefofle/auras_boons/" + aura_boon)
	var exclude_names: Array = []
	if aura_boon == "boons":
		exclude_names = FileAccess.open("user://savefofle/loaded_boons.txt", FileAccess.READ).get_as_text().split("\n", false)
	
	var rarities: Array = [[], [], []]
	for file in files:
		if file not in exclude_names and file != avoid:
			var file_info: Array = FileAccess.open("user://savefofle/auras_boons/" + aura_boon + "/" + file, FileAccess.READ).get_as_text().split("\n")
			if int(file_info[3]) in [0,1,2]:
				rarities[int(file_info[3])].append(file_info)
			
	return return_random_card_in_rarities(rarities, odds)
	
func return_cost(rarity: int, type: String):
	var types: Dictionary = {
		"Aura": [12, 20, 32],
		"Boon": [16, 26, 38],
		"AreaCard": [22, 36, 50],
		"OtherAreaCard": [22, 36, 50],
	}
	return types[type][rarity]
	
func roll_cards() -> void:
	for child in $RolledCards.get_children(): child.queue_free()
	for child in $Labels.get_children(): child.queue_free()
	var area_name: String = return_area_name()
	var difficulty: int = calculate_difficulty(area_name)
	var world_odds: Array = [[0.6,0.35,0.05],[0.45,0.45,0.1],[0.3,0.5,0.2]][difficulty-1]
	var transform: Array = [["RemoveCard", 20], ["TransformEnergy", 30], ["TransformRarity", 25]]
	if difficulty == 4: transform.append(["TransformRarity+1", 40])
	
	var slot_one_aura: Array = random_aura_boon(world_odds, "auras")
	var slot_one_boon: Array = random_aura_boon(world_odds, "boons")
	
	var slot_one_area_card: Array = random_card_in_area(world_odds, area_name)
	var slot_one_non_area_card: Array = random_card_in_another_area(world_odds, area_name, difficulty)
	
	var slots: Array = [transform[randi() % transform.size()], 
	slot_one_area_card, random_card_in_area(world_odds, area_name, slot_one_area_card),
	slot_one_non_area_card, random_card_in_another_area(world_odds, area_name, difficulty, slot_one_non_area_card),
	slot_one_aura, random_aura_boon(world_odds, "auras", slot_one_aura[0] + ".txt"),
	slot_one_boon, random_aura_boon(world_odds, "boons", slot_one_boon[0] + ".txt"),
	]
	
	var i: int = 0
	var nslots: Array = [slots[0]]
	for slot in slots:
		var type: String = "Card"
		match i:
			0: type = "ShopRoll"
			1,2: type = "AreaCard"
			3,4: type = "OtherAreaCard"
			5,6: type = "Aura"
			7,8: type = "Boon"
		if i != 0:
			if slot:
				var find_rarity: int = 7 if i < 5 else 3
				nslots.append([slot, return_cost(int(slot[find_rarity]), type)])
			else: nslots.append([])
		if nslots[i]:
			var multiply: int = [-1, 1][randi() % 2]
			nslots[i][1] = round(nslots[i][1] + (multiply * nslots[i][1] / 10))
			
			var item: Node
			match type:
				"ShopRoll": 
					item = Sprite2D.new()
					item.texture = load("res://test/simulation/assets/shop_rolls/" + nslots[i][0] + ".png")
					item.centered = false
				"AreaCard": 
					item = preload("res://test/simulation/screens/select_level/card.tscn").instantiate()
					item.default_state = nslots[i][0]
					item.team_changed.connect(on_card_team_pressed.bind(area_name + "/" + nslots[i][0][0] + ".txt"))
					item._on_default_state_pressed()
					item.can_hold = false
				"OtherAreaCard":
					item = preload("res://test/simulation/screens/select_level/card.tscn").instantiate()
					var old_name: String = nslots[i][0][0] + ".txt"
					nslots[i][0][0] = nslots[i][0][0].split("/", false)[1]
					item.default_state = nslots[i][0]
					item.team_changed.connect(on_card_team_pressed.bind(old_name))
					item._on_default_state_pressed()
					item.can_hold = false
				"Aura":
					item = preload("res://test/simulation/screens/select_level/aura.tscn").instantiate()
					item.load_aura(nslots[i][0])
					item.get_node("DestroyButton").queue_free()
				"Boon":
					item = preload("res://test/simulation/screens/select_level/boon.tscn").instantiate()
					item.load_boon(nslots[i][0])
					item.get_node("DestroyButton").pressed.disconnect(item._on_destroy_button_pressed)
					item.get_node("DestroyButton").pressed.connect(get_parent().on_boon_selected.bind(item.get_node("Name").text + ".txt"))
				
			
			var label := Label.new()
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.text = str(nslots[i][1])
			
			if i == 0:
				item.position = Vector2(1000, 420)
				
			if i > 0 and i < 5:
				item.position = Vector2((i - 1) * 250, 20)
				
			if i >= 5:
				item.position = Vector2((i - 5) * 250, 420)
			$RolledCards.add_child(item)
			$Labels.add_child(label)
			label.position = Vector2(item.position.x + 80, item.position.y - 50)
			
		i += 1
	
func _ready() -> void: roll_cards()
	
func on_card_team_pressed(x: Control, old_name: String) -> void:
	x.queue_free()
	var card: Control = get_parent().on_card_selected(old_name)
	if card: card._on_change_team_pressed()
	
func return_file_names(path: String) -> Array:
	var dir: DirAccess = DirAccess.open(path)
	if dir != null: return dir.get_files()
	return []

func _on_roll_button_pressed(): roll_cards()
