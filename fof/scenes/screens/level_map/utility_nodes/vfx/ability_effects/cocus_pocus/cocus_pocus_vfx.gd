extends Node3D

var ability: AbilityGD
var type: String
func _ready() -> void:
	$AnimationPlayer.play("CocusPocusIdle")
