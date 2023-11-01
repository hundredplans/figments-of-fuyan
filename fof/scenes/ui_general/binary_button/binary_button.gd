extends Control
@export var default: int = 0
@export var label_text: String
@export var ignore_repeat: bool = true
signal item_selected

func _enter_tree():
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
	if default != 0 or !ignore_repeat:
		default = 0
		on_buttons_pressed()
		item_selected.emit(default)

func _on_yes_pressed():
	if default != 1 or !ignore_repeat:
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
			
