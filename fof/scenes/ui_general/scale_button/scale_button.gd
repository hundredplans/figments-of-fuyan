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
	
	$Outside.color = Helper.DARK_BROWN
	$Inside.color = Helper.LIGHT_BROWN
	$Label.text = label_text
