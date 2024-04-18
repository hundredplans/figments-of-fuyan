extends Control
var info: Dictionary

func apply_info(Heroes: HeroesGD) -> void:
	$Card.Heroes = Heroes
	$Card.set_info(info)
	$ID.text = str(info.id)
