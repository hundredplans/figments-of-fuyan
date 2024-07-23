extends ToolGD

@export var heal: int = 1
@export var distance: int = 1
func onRefreshAbility(ability: ToolAbilityInfoGD) -> void:
	var in_range: Array = Tiles.onFindUnitAdjacentTiles(Unit, distance) + [Unit.Tile]
	ability.AbilityTiles.setInfo(in_range, in_range.filter(func(x: TileGD): return Units.unit_by_tile_team_bool(x, Unit.team)))
	
func onAbilityTrigger(ability: ToolAbilityInfoGD) -> void:
	var AppliedBy := AppliedByGD.new(AppliedByGD.TOOL, self)
	if ability.Tile != Unit.Tile:
		Combat.onHeal(HealInfoGD.new(ability.Tile.Unit, heal, AppliedBy))
	Combat.onHeal(HealInfoGD.new(Unit, heal, AppliedBy))
	ability.charges -= 1
	Tools.onBreak(self)
