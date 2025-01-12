extends MapNodeScreen

@export var kill_amounts: Array[int]
@export var BountyBoardCheckScreenPacked: PackedScene

func onDimBackground() -> bool: return true

func _on_leave_button_pressed() -> void:
	finished.emit()
	queue_free()

func _on_check_button_pressed() -> void:
	var BountyBoardCheckScreen: Control = BountyBoardCheckScreenPacked.instantiate()
	add_child(BountyBoardCheckScreen)
	BountyBoardCheckScreen.setInfo(kill_amounts)
