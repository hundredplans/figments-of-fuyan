extends Control
signal pressed
@export var label_text: String
@export var flip_h: bool

func _ready() -> void:
	$Label.text = label_text
	$Button.flip_h = flip_h
	
	if flip_h:
		$Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		$Label.position.x += 200

func _on_button_pressed():
	AudioMaster.play_sfx("MouseClick")
	pressed.emit()
