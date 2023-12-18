extends Control
signal pressed

var nlabel: Label
var can_press: bool = false

@export var label_text: String

func _process(_delta: float) -> void:
	if can_press and Input.is_action_just_pressed("LeftClick"):
		pressed.emit()

func _ready():
	$Label.text = label_text

func _on_mouse_entered(): can_press = true
func _on_mouse_exited(): can_press = false

func change_found_searches(i: int, mode: int = 0) -> void:
	if nlabel == null and i != 0:
		nlabel = Label.new()
		nlabel.label_settings = preload("res://scenes/screens/lore_books_editor/nlabel.tres")
		nlabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		nlabel.position = Vector2(230, 15)
		nlabel.size = Vector2(60, 20)
		add_child(nlabel)
		
	if nlabel:
		if i == 0:
			print("here")
			nlabel.queue_free()
			nlabel = null
		else:
			match mode:
				0: nlabel.text = str(i)
				1: nlabel.text = str(int(nlabel.text) - i)
				2: nlabel.text = str(int(nlabel.text) + i)
