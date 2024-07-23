class_name HurtActionGD
extends ActionGD

const type: int = ActionManagerGD.HURT
var AppliedBy: AppliedByGD
var units: Array = []

func _init(UnitA: Variant, _AppliedBy: AppliedByGD = null,  _delay: DelayGD = null) -> void:
	if UnitA is UnitGD: units = [UnitA]
	elif UnitA is Array: units = UnitA
	is_visible = units.any(func(x: UnitGD): return x.isVis())
	AppliedBy = _AppliedBy
	delay = _delay
	if delay == null: delay = DelayGD.new(1.5)
	super()

func onTrigger() -> void:
	for _Unit in units: _Unit.Model.on_hurt()
