extends ToolGD

@export var distance: int = 1
func onRefreshAbility(ability: ToolAbilityInfoGD) -> void:
	var in_range: Array = Tiles.onFindUnitAdjacentTiles(Unit, distance)
	var units: Array = in_range.filter(func(x: TileGD): return x.Unit != null and x.Unit.team != Unit.team and x.Unit.attack <= 2)
	ability.AbilityTiles.setInfo(in_range, units)
	
func onAbilityTrigger(ability: ToolAbilityInfoGD) -> void:
	GameEffects.addGFX(ability.Tile.Unit, GameFXGD.STAGGER)
	ability.charges -= 1
	Tools.onBreak(self)
