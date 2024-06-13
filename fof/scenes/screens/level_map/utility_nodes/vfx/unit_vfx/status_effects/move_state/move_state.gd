extends Label3D

var type: String
func setInfo(ai_info: AIInfoGD) -> void:
	ai_info.update_move_state.connect(setText)

func setText(_text: String) -> void: text = _text
