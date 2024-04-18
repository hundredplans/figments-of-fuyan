extends Control

signal pressed
var level_id: int = 0
var can_press: bool = false

func on_load_save_file(info: Dictionary, area_info: AreaInfoGD) -> void:
	$SaveInfo/Name.text = str(info.save_file) + "- " + str(area_info.folder_name)
	for node in [$SaveInfo/Progress, $SaveInfo/Status, $SaveInfo/Name, $SaveInfo/Seed]:
		node.modulate = area_info.accent_color
		
	$Background/Outside.color = area_info.accent_color
	$Background/Inside.color = area_info.primary_color
	
	$Background/ArtBorderInside.color = area_info.primary_color
	
	$SaveInfo/ShillingCounter.set_shilling_count(info.shillings)
	$SaveInfo/HeroArt.texture = load("res://assets/base_game/cards/cards/" + Helper.getHeroCardInfo(info.hero_id)\
	.base_cards[info.hero_level].folder_name + "/art_mini.png")
	
	$SaveInfo/Progress.text = str(area_info.world_id) + "-" + str(abs(info.map_progress[1] - 10))
	$SaveInfo/Seed.text = str(info.gseed)
	
	level_id = info.level_id
	match info.level_id:
		0: $SaveInfo/Status.text = "World Map"
		_: $SaveInfo/Status.text = "In Battle"

func _on_mouse_entered(): modulate = Helper.DARK_GREY; can_press = true
func _on_mouse_exited(): modulate = Helper.BASE; can_press = false

func _process(_delta: float) -> void:
	if can_press and Input.is_action_just_pressed("LeftClick"): pressed.emit(get_index() + 1)
