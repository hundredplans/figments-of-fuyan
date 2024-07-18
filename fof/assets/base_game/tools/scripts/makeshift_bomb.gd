extends ToolGD

const MAX_GROW: float = 100
const GROW_STOP: float = 0.5
func onTrigger(_Unit: UnitGD, trigger: int, _args: TriggerInfoGD) -> void:
	if trigger == TriggerGD.LAST_WILL and Unit == _Unit:
		if !is_ascended:
			for __Unit in Units.onFindAdjacentUnits(Unit, 1):
				Combat.onDMG(__Unit, AppliedByGD.new(AppliedByGD.TOOL, self), 1)
		else:
			for __Unit in Units.onFindAdjacentUnits(Unit, 2).filter(func(x: UnitGD): return x.team != Unit.team):
				Combat.onDMG(__Unit, AppliedByGD.new(AppliedByGD.TOOL, self), 1)
		
	if trigger == TriggerGD.BEGIN_DEATH and Unit == _Unit:
		var tween := create_tween()
		tween.tween_method(onExplode, 0.0, MAX_GROW, GROW_STOP)
		tween.finished.connect(onExplodeFinished)

func onExplode(val: float) -> void:
	for mat in Unit.Model.materials:
		mat.set_shader_parameter("grow", val)
		mat.next_pass.set_shader_parameter("grow", val)
		
func onExplodeFinished() -> void:
	Unit.visible = false
			
