extends VFXGD

const OFFSET: float = 0.2
var is_start_hat: bool

func onVFX() -> void:
	super()
	var Card: CardGD = get_parent()
	if !Card.isLevelVisible():
		onForceAction(DestroyVFXAction.new(self))
		return
	
	if is_start_hat:
		position.y = Card.info.top + OFFSET
		
		var down_tween := create_tween()
		down_tween.tween_property(self, "position:y", -position.y, info.delay)\
			.as_relative().set_trans(Tween.TRANS_SINE)
			
		var scale_tween := create_tween()
		scale_tween.tween_property(Card.getModel(), "scale:y", -0.99, info.delay)\
			.as_relative().set_trans(Tween.TRANS_SINE)
			
	elif !is_start_hat:
		position.y = 0
		
		var up_tween := create_tween()
		up_tween.tween_property(self, "position:y", Card.info.top + OFFSET, info.delay)\
			.as_relative().set_trans(Tween.TRANS_SINE)
			
		var scale_tween := create_tween()
		scale_tween.tween_property(Card.getModel(), "scale:y", 0.99, info.delay)\
			.as_relative().set_trans(Tween.TRANS_SINE)

func setStartHat(_is_start_hat: bool) -> void:
	is_start_hat = _is_start_hat
