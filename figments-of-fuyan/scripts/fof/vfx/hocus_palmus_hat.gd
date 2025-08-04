extends VFXGD

const OFFSET: float = 0.2
var is_start_hat: bool

const HAT_TIME: float = 1.5

func onVFX() -> void:
	super()
	var Card: CardGD = get_parent()
	if !Card.isLevelVisible():
		if is_start_hat:
			scale.y = 0.01
		elif !is_start_hat:
			scale.y = 1
		
		onForceAction(DestroyVFXAction.new(self))
		return
	
	if is_start_hat:
		position.y = Card.getTopFromInfo() + OFFSET
		
		var down_tween := create_tween()
		down_tween.tween_property(self, "position:y", -position.y, HAT_TIME)\
			.as_relative().set_trans(Tween.TRANS_SINE)
			
		var scale_tween := create_tween()
		scale_tween.tween_property(Card.getModel(), "scale:y", -0.99, HAT_TIME)\
			.as_relative().set_trans(Tween.TRANS_SINE)
			
	elif !is_start_hat:
		position.y = 0
		
		var up_tween := create_tween()
		up_tween.tween_property(self, "position:y", Card.getTopFromInfo() + OFFSET, HAT_TIME)\
			.as_relative().set_trans(Tween.TRANS_SINE)
			
		var scale_tween := create_tween()
		scale_tween.tween_property(Card.getModel(), "scale:y", 0.99, HAT_TIME)\
			.as_relative().set_trans(Tween.TRANS_SINE)

func setStartHat(_is_start_hat: bool) -> void:
	is_start_hat = _is_start_hat
