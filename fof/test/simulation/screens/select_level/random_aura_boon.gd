extends Control

var world_distinguisher: Array = [
	["Swamp", "Critters", "Bouldaak Jungle", "Palm", "Fungite"],
	["Mages", "Wild West", "Sugori", "Dwarven"],
	["Varoma", "Kaluta", "Befre"]
	]

var states: Dictionary = {
	"Aura": false,
	"Boon": false,
	"Common": true,
	"Rare": true,
	"Exalt": true,
}

var can_drag: bool = false
var held: bool = true

func _ready() -> void:
	on_modulate_buttons()

func on_modulate_buttons() -> void:
	for child in $ChoiceButtons.get_children():
		if states[child.name]:
			child.modulate = Color(1,0,0)
		else:
			child.modulate = Color(1,1,1)

func _process(_delta: float) -> void:
	if can_drag or held:
		if Input.is_action_just_pressed("LeftClick"):
			held = true
		elif Input.is_action_pressed("LeftClick") and held:
			position.x = (get_viewport().get_mouse_position().x) - 305
			position.y = (get_viewport().get_mouse_position().y) - 46
		else:
			held = false
			
func _on_grab_zone_mouse_entered():
	can_drag = true
func _on_grab_zone_mouse_exited():
	can_drag = false

func _on_remove_button_pressed(): queue_free()

func on_state_button_pressed(btn_name: String) -> void:
	states[btn_name] = !states[btn_name]
	on_modulate_buttons()

func _on_roll_button_pressed():
	var equipped_boons: Array = Array(FileAccess.open("user://savefofle/loaded_boons.txt", FileAccess.READ).get_as_text().split("\n", false)).map(func(x: String): return x.left(-4))
	var roll_pool: Array = []
	
	for aura_boon in ["Aura", "Boon"].filter(func(x: String): return states[x]).map(func(x: String): return x.to_lower() + "s"):
		var dir: DirAccess = DirAccess.open("user://savefofle/auras_boons/" + aura_boon)
		for file_info in Array(dir.get_files()).map(func(x: String): return FileAccess.open("user://savefofle/auras_boons/" + aura_boon + "/" + x, FileAccess.READ).get_as_text().split("\n", false)):
			if file_info[0] not in equipped_boons:
				var i: int = 0
				for difficulty in ["Common", "Rare", "Exalt"]:
					if states[difficulty] and str(i) == file_info[3]:
						roll_pool.append(file_info)
					i += 1
	if roll_pool:
		var weighted_roll: int = 0
		for difficulty in ["Common", "Rare", "Exalt"]:
			if states[difficulty]:
				weighted_roll += 1
				
		match weighted_roll:
			1: $Result.text = roll_pool[randi() % roll_pool.size()][0]
			3: 
				if get_parent().loaded_level:
					var i: int = 0
					for difficulty in world_distinguisher:
						if get_parent().loaded_level.split("/", false)[0] in difficulty:
							var world_odds: Array = [[0.65,0.35,0.05],[0.45,0.45,0.1],[0.3,0.5,0.2]][i-1]
							var difficulty_tier: Array = []
							for k in range(0, 3):
								difficulty_tier.append([])
								difficulty_tier[k] = roll_pool.filter(func(x: Array): return x[3] == str(k))
							
							var random: float = randf()
							var total: float = 0
							var j: int = 0
							for odd in world_odds:
								if random < odd + total:
									$Result.text = difficulty_tier[j][randi() % difficulty_tier[j].size()][0]
									return
								total += odd
								j += 1
							break
						i += 1
						if i > 3:
							$Result.text = roll_pool[randi() % roll_pool.size()][0]
				else:
					$Result.text = roll_pool[randi() % roll_pool.size()][0]
 
