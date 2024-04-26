extends TargetAbilityGD
var ability_name: String = "Palmsale"

func onTargetAbilityCondition(Unit: UnitGD) -> Array: # Returns valid Tiles
	return Tiles.onFindUnitAdjacentTiles(Unit, 1)
	
