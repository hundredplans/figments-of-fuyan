extends Control

@export var default: int
@export var totalmin: int
@export var totalmax: int
@export var step: int
@export var bigstep: int
@export var label_text: String

func _ready() -> void:
	if default >= totalmin and default <= totalmax:
		$Number.text = str(default)
	
	$Label.text = label_text
	
	for child in [$Outside, $Steppers/Left/BigStep, $Steppers/Right/BigStep]:
		child.color = Helper.DARK_BROWN
	
	for child in [$Inside, $Steppers/Left/SmallStep, $Steppers/Right/SmallStep]:
		child.color = Helper.LIGHT_BROWN
