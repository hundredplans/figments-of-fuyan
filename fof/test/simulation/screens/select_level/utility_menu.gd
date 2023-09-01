extends Control

@onready var card_zone: Node2D = get_parent().get_node("CardZone")
const stats: Array = ["Att", "Hp", "Spd"]

func _ready():
	$UtilityPressed.play("utility_pressed")

func _on_save_cards_pressed(i: int):
	var write_string: String = ""
	for child in card_zone.get_children():
		if child.team == i:
			var aura_resource_path: String
			if child.get_node("AuraSelected/AuraArt").texture: aura_resource_path = child.get_node("AuraSelected/AuraArt").texture.resource_path
			write_string += "%s|%s|%s|%s|%s|%s~" % [child.card_path.left(-4), child.scale.x, child.global_position.x, child.global_position.y, child.team, aura_resource_path]

	if write_string:
		var num: int = 0
		for file_name in DirAccess.get_files_at("user://savefofle/levels/None/"):
			if file_name.begins_with("cards") and file_name.length() > 9:
				var nnum: int = int(file_name.left(-4).substr(5, -1))
				if nnum > num:
					num = nnum
				
		var file := FileAccess.open("user://savefofle/levels/None/cards%s.txt" % str(num + 1), FileAccess.WRITE)
		file.store_string(write_string)
		file = null

func on_change_stat(team: int, mult: int, i: int):
	for card in card_zone.get_children():
		if card.team == team:
			var text: String = card.get_node(stats[i]).text
			if text.is_valid_int():
				var result: int = clamp(int(text) + (1 * mult), 0, 9)
				card.get_node(stats[i]).text = str(result)

func on_screen_clear_pressed(i: int):
	var overpos: Array = [Vector2(0, 1920), Vector2(1920, 3840)]
	for child in card_zone.get_children():
		if child.position.x > overpos[i].x and child.position.x < overpos[i].y:
			child.queue_free()
