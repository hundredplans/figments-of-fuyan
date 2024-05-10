extends TextureRect

var type: String
func setFX(_type: String, charges: int) -> void:
	type = _type
	texture = load("res://scenes/screens/level_ui/unit_status/unit_fx/textures/" + type.to_lower() + ".png")
	setCharges(charges)
	
func setCharges(charges: int) -> void:
	get_node("Label").text = str(charges)
