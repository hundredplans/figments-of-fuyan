class_name HurtActionGD
extends ActionGD

const type: int = ActionManagerGD.HURT
var AppliedBy: AppliedByGD

func _init(_Unit: UnitGD = null, _AppliedBy: AppliedByGD = null, _is_visible: bool = false, _delay: DelayGD = null) -> void:
	Unit = _Unit
	AppliedBy = _AppliedBy
	delay = _delay
	is_visible = _is_visible
	if delay == null: delay = DelayGD.new(1.5)
	super()

func onTrigger() -> void:
	Unit.Model.on_hurt()
