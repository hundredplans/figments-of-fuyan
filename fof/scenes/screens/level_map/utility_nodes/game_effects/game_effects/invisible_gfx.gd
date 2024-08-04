extends GameFXGD

var status_fx: StatusFXGD
func onCreateGFX() -> void:
	custom_triggers = [
		TriggerGD.new(self, Unit, onRemove, TriggerGD.REMOVE, TriggerGD.NULL),
		TriggerGD.new(self, Unit, Callable(), TriggerGD.MOVE, TriggerGD.REMOVE_FX)
	]
	status_fx = StatusManager.onCreateStatusFX(Unit, StatusFXInfoGD.IDS.INVISIBLE)
	Unit.setCollisionLayer()
	
func onRemove() -> void:
	StatusManager.onRemoveStatusFX(status_fx)
	Unit.setCollisionLayer()
	
var adjacent_enemies: Array = []
func onTrigger(_Unit: UnitGD, trigger: int, _args: TriggerInfoGD) -> void:
	if trigger == TriggerGD.MOVE and Unit != _Unit or (trigger == TriggerGD.BEGIN_DEATH and _Unit in adjacent_enemies) or (trigger == TriggerGD.AWAKEN and _Unit.team != Unit.team):
		if _Unit in adjacent_enemies:
			if Tiles.tile_distance(Unit.Tile, _Unit.Tile) != 1: Unit.setCollisionLayer(); adjacent_enemies.erase(_Unit)
		elif Tiles.tile_distance(Unit.Tile, _Unit.Tile) == 1: Unit.setCollisionLayer(); adjacent_enemies.append(_Unit)
