class_name PalmZiplineGD
extends IObjectGD

const ZIPLINE_DELAY: float = 3
var is_equal_height: bool
var tween_info: Array
# Class to sync all the functions for palm ziplines

func onReady() -> void:
	is_equal_height = info.id in [5, 6]
	
func onCondition(Unit: UnitGD) -> bool: return Unit.Tile in interactable_tiles
func getDisabled(Unit: UnitGD) -> bool:
	if interactable_tiles.all(func(x: TileGD): return Units.unit_by_tile_bool(x)): return true
	return Unit.turn_status == Unit.TURN_USED

func onTrigger(Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	pass
	#ActionManager.onAddAction(ArgDelayActionGD.new(onTriggerStarted.bind(Unit), onTriggerFinished.bind(Unit), true, DelayGD.new(ZIPLINE_DELAY)), ActionManager.APPEND)

func onTriggerStarted(Unit: UnitGD) -> void:
	for Tile in interactable_tiles.filter(func(x: TileGD): return x != Unit.Tile):
		Unit.Model._look_at(Tile)
		Unit.Model.onZipline()

func onTriggerFinished(Unit: UnitGD) -> void:
	Unit.Model.onZiplineFinished()
