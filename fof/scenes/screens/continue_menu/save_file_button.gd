extends Control

signal pressed
var Heroes: Node
var level_id: int = 0
var can_press: bool = false

func on_load_save_file(info: Dictionary, area_info: Dictionary) -> void:
	$SaveInfo/Name.text = str(info.save_file) + "- " + str(area_info.sname)
	for node in [$SaveInfo/Progress, $SaveInfo/Status, $SaveInfo/Name, $SaveInfo/Seed]:
		node.modulate = area_info.acolor
		
	$Background/Outside.color = area_info.acolor
	$Background/Inside.color = area_info.pcolor
	$SaveInfo/ShillingCounter.set_shilling_count(info.shillings)
	$SaveInfo/HeroArt.texture = load("res://assets/base_game/cards/" + Helper.id_to_bgfn(Heroes.hid_to_base(info.hero_id), "Card") + "/art_max.png")
	$SaveInfo/Progress.text = str(area_info.world) + "-" + str(abs(info.map_progress[1] - 10))
	$SaveInfo/Seed.text = str(info.gseed)
	
	level_id = info.level_id
	match info.level_id:
		0: $SaveInfo/Status.text = "World Map"
		_: $SaveInfo/Status.text = "In Battle"

func _on_mouse_entered(): modulate = Helper.DARK_GREY; can_press = true
func _on_mouse_exited(): modulate = Helper.BASE; can_press = false

func _process(_delta: float) -> void:
	if can_press and Input.is_action_just_pressed("LeftClick"): pressed.emit(get_index() + 1)
