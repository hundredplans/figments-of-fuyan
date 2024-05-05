extends WhenHealedGD

func onWhenHealed(a: Dictionary) -> void:
	if a.is_visible: a.Unit.Model.on_play_animation("Ability")
