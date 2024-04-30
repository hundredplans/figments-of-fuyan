extends TextureRect

func setFX(type: String, charges: int) -> void:
	texture = load("res://scenes/screens/level_ui/unit_status/unit_fx/textures/" + type.to_lower() + ".png")
	setCharges(charges)
	
func setCharges(charges: int) -> void:
	get_node("Label").text = str(charges)
