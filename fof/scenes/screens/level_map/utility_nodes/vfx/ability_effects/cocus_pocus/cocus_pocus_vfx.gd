extends Node3D

var Vision: VisionGD
var units: Array
var type: String
var cocus_count: int = 0

func _ready() -> void:
	$AnimationPlayer.play("CocusPocusIdle")

func setVisible() -> void:
	for Unit in units:
		if Unit.team == 0: visible = true
		else: visible = Unit.Tile in Vision.getTeamVision()
