extends UniqueTileGD

func onTrigger(Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if Unit.Tile == Tile and trigger == TriggerGD.MOVE:
		pass
	#var is_water: bool = Unit.Tile.isDeepWater()
	#var was_water: bool = PreviousTile.isDeepWater()
	#
	#if (is_water and !was_water): GameEffects.addGFX(Unit, GameFXGD.DEEP_WATER)
	#elif (!is_water and was_water): GameEffects.onFindRemoveFX(Unit, GameFXGD.DEEP_WATER)


#func onCreateGFX() -> void:
	#custom_triggers = [
		#TriggerGD.new(self, Unit, onRemoved, TriggerGD.REMOVE, TriggerGD.NULL)
	#]
	#
	#var AppliedBy := AppliedByGD.new(AppliedByGD.DEEP_WATER)
	#if !Tiles.onCanDrown(Unit):
		#Units.changeStats(StatInfoGD.new(Unit, AppliedBy, StatsGD.BOTH_SPEED, -1))
	#else: Combat.onDestroyUnit(Unit, AppliedBy)
#
#func onRemoved() -> void:
	#Units.changeStats(StatInfoGD.new(Unit, AppliedByGD.new(AppliedByGD.DEEP_WATER), StatsGD.BOTH_SPEED, 1))
