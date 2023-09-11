extends Control

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
	var roll_pool: Array = []
	for aura_boon in ["Aura", "Boon"].filter(func(x: String): return states[x]).map(func(x: String): return x.to_lower() + "s"):
		var dir: DirAccess = DirAccess.open("user://savefofle/auras_boons/" + aura_boon)
		for file_info in Array(dir.get_files()).map(func(x: String): return FileAccess.open("user://savefofle/auras_boons/" + aura_boon + "/" + x, FileAccess.READ).get_as_text().split("\n", false)):
			var i: int = 0
			for difficulty in ["Common", "Rare", "Exalt"]:
				if states[difficulty] and str(i) == file_info[3]:
					roll_pool.append(file_info[0])
				i += 1
	if roll_pool:
		$Result.text = roll_pool[randi() % roll_pool.size()]
 
