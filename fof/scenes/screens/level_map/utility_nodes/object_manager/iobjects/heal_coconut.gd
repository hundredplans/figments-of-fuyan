extends IObjectGD

var ObjModel: Node3D
@export var delay: float = 1.5

func onReady() -> void:
	ObjModel = BaseTile.types[1].model

func onTrigger(Unit: UnitGD, trigger: int, _args: TriggerInfoGD) -> void:
	if trigger == TriggerGD.MOVE and Unit.Tile == BaseTile:
		ActionManager.onAddAction(ArgDelayActionGD.new(onDelayStart, onDelayFinished.bind(Unit), Unit.isVis(), DelayGD.new(delay)), ActionManager.APPEND)
		
func onDelayStart() -> void:
	var tween := BaseTile.get_tree().create_tween()
	tween.tween_property(ObjModel, "scale:y", 0.01, delay / 3)
	
func onDelayFinished(Unit: UnitGD) -> void:
	Units.changeStats(StatInfoGD.new(Unit, AppliedByGD.new(AppliedByGD.IOBJECT, self), StatsGD.HEALTH, 1))
	ObjectManager.onRemoveIObject(self)
	
