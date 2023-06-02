extends Control
var tips: PackedStringArray
func _ready(): 
	tips = load_tips().tips
	select_random_tip()
func _on_reset_tips_timeout(): select_random_tip()
func select_random_tip() -> void:
	
	var random_tip: int = randi() % tips.size()
	var current_tip: String = $TipText.get_text()
	if current_tip:
		tips.append(current_tip)
	$TipText.set_text(tips[random_tip])
	tips.remove_at(random_tip)
	$ResetTips.start()
func load_tips():
	var path := "res://static_data/start_screen_tips.json"
	return JSON.parse_string(FileAccess.get_file_as_string(path))
