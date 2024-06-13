class_name AIInfoGD
extends Resource

signal update_move_state
var ExploreTile: TileGD
var move_state: String
var danger: int = 0
var safety: int = 0

func setMoveState(text: String) -> void:
	move_state = text
	update_move_state.emit(text)
