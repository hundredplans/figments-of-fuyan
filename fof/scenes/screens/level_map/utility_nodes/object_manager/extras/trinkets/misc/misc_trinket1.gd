extends TrinketEffectGD

var description: String = "Spawn a copy of this unit with 1 HEALTH, 1 ATTACK"
var delay: float = 2
func onReady() -> void:
	var spawn_tiles: Array = Tiles.onFindSpawnTiles(Unit.team)
	if !spawn_tiles.is_empty():
		var SpawnTile: TileGD = spawn_tiles.pick_random()
		var id: int = Unit.base_card.id
		var action := ArgDelayActionGD.new(Units.onUnitAwakened.bind(id, Unit.team, SpawnTile.tile.rotation, SpawnTile), onAfterDelay, Unit.isVis(), DelayGD.new(), true)
		ActionManager.onAddAction(action, ActionManagerGD.PUSH)
	onRemoveGameFX()

func onAfterDelay(_Unit: UnitGD) -> void:
	if _Unit != null:
		if _Unit.team == 0:
			ActionManager.onAddAction(ArgDelayActionGD.new(SpectateCamera.onSpectate.bind(_Unit), SpectateCamera.onSpectate.bind(Unit), true, DelayGD.new(delay)), ActionManagerGD.PUSH)
		var AppliedBy := AppliedByGD.new(AppliedByGD.TRINKET, self)
		var attack := StatInfoGD.new(_Unit, AppliedBy, StatsGD.ATTACK, 1, -1, true, false)
		var health := StatInfoGD.new(_Unit, AppliedBy, StatsGD.BOTH_HEALTH, 1, -1, true, false)
		Units.changeStats([attack, health])
		
