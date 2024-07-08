extends Control

signal pressed
var level_id: int = 0
var can_press: bool = false

func setInfo(save_info: SaveInfoGD) -> void:
	var area_info: AreaInfoGD = save_info.area_info
	$SaveInfo/Name.text = str(save_info.id) + "- " + str(area_info.folder_name)
	for node in [$SaveInfo/Progress, $SaveInfo/Status, $SaveInfo/Name, $SaveInfo/Seed]:
		node.modulate = area_info.accent_color
		
	$Background/Outside.color = area_info.accent_color
	$Background/Inside.color = area_info.primary_color
	
	$Background/ArtBorderInside.color = area_info.primary_color
	
	$SaveInfo/ShillingCounter.set_shilling_count(save_info.shillings)
	$SaveInfo/HeroArt.texture = load("res://assets/base_game/cards/cards/" + Helper.getHeroCardInfo(save_info.hero_id)\
	.base_cards[save_info.hero_level].folder_name + "/art_mini.png")
	
	$SaveInfo/Progress.text = str(area_info.world_id) + "-" + str(abs(save_info.map_progress[1] - 10))
	$SaveInfo/Seed.text = str(save_info.gseed)
	
	match save_info.getLevelID():
		0: $SaveInfo/Status.text = "World Map"
		_: $SaveInfo/Status.text = "In Battle"

func _on_mouse_entered(): modulate = Helper.DARK_GREY; can_press = true
func _on_mouse_exited(): modulate = Helper.BASE; can_press = false

func _process(_delta: float) -> void:
	if can_press and Input.is_action_just_pressed("LeftClick"): pressed.emit(get_index() + 1)
