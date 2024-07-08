extends UnitVFXBase

func setInfo(ai_info: AIInfoGD) -> void:
	ai_info.update_move_state.connect(setText)

func setText(_text: String) -> void: $Label.text = _text
