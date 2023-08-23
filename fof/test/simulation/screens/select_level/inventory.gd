extends Control

func _on_clear_inventory_pressed():
	var file := FileAccess.open("user://savefofle/loaded_boons.txt", FileAccess.WRITE)
	file.store_string("")
	file = null
	for child in $BoonZone.get_children(): child.queue_free()

func _on_destroy_button_pressed(): queue_free()

func _ready() -> void:
	for file_name in FileAccess.open("user://savefofle/loaded_boons.txt", FileAccess.READ).get_as_text().split("\n", false):
		var boon: Control = preload("res://test/simulation/screens/select_level/boon.tscn").instantiate()
		boon.remove_from_inventory.connect(on_remove_from_inventory)
		boon.load_boon(FileAccess.open("user://savefofle/auras_boons/boons/" + file_name, FileAccess.READ).get_as_text().split("\n", false))
		$BoonZone.add_child(boon)
	sort_boons()

func on_remove_from_inventory(boon_name: String) -> void:
	var file := FileAccess.open("user://savefofle/loaded_boons.txt", FileAccess.READ)
	var textarr: Array = file.get_as_text().split("\n", false)
	if boon_name in textarr: textarr.erase(boon_name)
	file = null
	
	file = FileAccess.open("user://savefofle/loaded_boons.txt", FileAccess.WRITE)
	var strarr: String
	for s in textarr: strarr += s + "\n"
	file.store_string(strarr)
	file = null

func sort_boons() -> void:
	var x: int = 0
	var y: int = 0
	for child in $BoonZone.get_children():
		child.position = Vector2(x, y)
		x += 300
		if x > 1500:
			x = 0
			y += 350
