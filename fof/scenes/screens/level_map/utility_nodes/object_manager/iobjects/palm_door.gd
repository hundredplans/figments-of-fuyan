extends IObjectGD

# Returns 0 if enabled, 1 for disabled, 2 for invisible
func onAbilityCondition(Unit: UnitGD, ability: IObjectAbilityInfoGD) -> int:
	return 0

func onCondition(Unit: UnitGD) -> bool:
	return Unit.Tile in interactable_tiles
