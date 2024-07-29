extends IObjectGD

var id: int
var ObjModel: Node3D
var palm_mini_tool_info: Resource = preload("res://assets/base_game/unique_tiles/extras/palm_mini_tool_info.tres")
@export var delay: float = 2

func onReady() -> void:
	id = info.id
	ObjModel = BaseTile.types[1].model

func onTrigger(Unit: UnitGD, trigger: int, _args: TriggerInfoGD) -> void:
	if trigger == TriggerGD.MOVE and Unit.Tile == BaseTile:
		ActionManager.onAddAction(ArgDelayActionGD.new(onDelayStart, onDelayFinished.bind(Unit), Unit.isVis(), DelayGD.new(delay)), ActionManager.APPEND)

func onDelayStart() -> void:
	palm_mini_tool_info.onCreateEquipModelAnimation(BaseTile, ObjModel, delay)

func onDelayFinished(Unit: UnitGD) -> void:
	ObjectManager.onRemoveIObject(self)
	Tools.onEquipTool(Unit, palm_mini_tool_info.getToolID(id))
	
