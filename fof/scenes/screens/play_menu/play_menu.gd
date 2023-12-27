extends Control

var seed: int = 0
func _ready() -> void:
	for hero_button in $SelectHero.get_children():
		hero_button.pressed.connect(on_select_hero)

func on_select_hero(hid: int) -> void:
	Helper.on_load_game_state(hid, seed)
	queue_free()
