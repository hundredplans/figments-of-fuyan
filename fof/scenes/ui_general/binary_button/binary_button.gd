extends Control
@export var default: int = 0
@export var label_text: String
signal item_selected

func _ready():
	on_buttons_pressed()
	$Label.text = label_text
	$Outside.color = Helper.DARK_BROWN
	$Inside.color = Helper.LIGHT_BROWN
	(func():$Outside.size.x += $Label.size.x + 23; $Inside.size.x += $Label.size.x + 23).call_deferred()

func press():
	default = abs(default - 1)
	on_buttons_pressed()
	item_selected.emit(default)

func _on_no_pressed():
	if default != 0:
		default = 0
		on_buttons_pressed()
		item_selected.emit(default)

func _on_yes_pressed():
	if default != 1:
		default = 1
		on_buttons_pressed()
		item_selected.emit(default)
	
func on_buttons_pressed():
	match default:
		0:
			$No.modulate = Helper.RED
			$Yes.modulate = Helper.BASE
		1:
			$No.modulate = Helper.BASE
			$Yes.modulate = Helper.RED
			
