extends UnitVFXBase

func setInfo(id: int) -> void:
	var model_path: String
	match id:
		1: model_path = "res://scenes/screens/level_map/utility_nodes/vfx/unit_vfx/tool_effects/pendant/life_pendant.glb"
		4: model_path = "res://scenes/screens/level_map/utility_nodes/vfx/unit_vfx/tool_effects/pendant/fire_pendant.glb"
		6: model_path = "res://scenes/screens/level_map/utility_nodes/vfx/unit_vfx/tool_effects/pendant/wind_pendant.glb"
	$Pendant.add_child(load(model_path).instantiate())

func _ready() -> void:
	$AnimationPlayer.play("Idle")
