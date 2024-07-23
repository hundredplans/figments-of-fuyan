extends UniqueTileGD

func onTrigger(Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if trigger == TriggerGD.MOVE and (Unit.Tile == Tile or Unit.Tile == args.Tile):
		var was_water: bool = args.Tile.isDeepWater()
		var is_water: bool = Unit.Tile.isDeepWater()
		if (is_water and !was_water): onEnterWater(Unit)
		elif (!is_water and was_water): onExitWater(Unit)
		
func onEnterWater(Unit: UnitGD) -> void:
	var AppliedBy := AppliedByGD.new(AppliedByGD.DEEP_WATER)
	if !Tiles.onCanDrown(Unit):
		Units.changeStats(StatInfoGD.new(Unit, AppliedBy, StatsGD.BOTH_SPEED, -1))
	else: Combat.onDestroyUnit(Unit, AppliedBy)

func onExitWater(Unit: UnitGD) -> void:
	Units.changeStats(StatInfoGD.new(Unit, AppliedByGD.new(AppliedByGD.DEEP_WATER), StatsGD.BOTH_SPEED, 1))
