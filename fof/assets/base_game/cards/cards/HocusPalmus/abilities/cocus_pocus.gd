extends TargetAbilityGD

@export var HEAL: int = 2
func onTargetAbilityCondition() -> bool:
	tiles = {"range": [], "affect": []}
	if charges > 0:
		for ability in Unit.abilities:
			if ability.ability_name == "HocusPalmusOngoingAbility":
				if ability.affected_units.size() > 0:
					tiles["range"] = [ability.affected_units[0].Tile]
					
					if onFindSpawnTiles().size() > 0:
						tiles["affect"] = [ability.affected_units[0].Tile]
					return true
				else: tiles["affect"] = []; return false
	return false
	
func onFindSpawnTiles() -> Array:
	return Tiles.get_children().filter(func(x: TileGD): return Tiles.on_find_tile_primary_type(x) == "Spawn").filter(func(x: TileGD): return !Units.unit_by_tile_bool(x))
	
func onTargetAbility() -> void:
	charges -= 1
	var _Unit: UnitGD = Units.unit_by_tile(Tile)
	Unit.Model._look_at(Tile)
	if is_visible: Unit.Model.on_play_animation("Ability")
	call_deferred("onCocusPocus", _Unit)
	change_camera = false
	LevelMap.setActionLock("UnitActionRegular")
		
const DELAY_DURATION: float = 0.5
const SCALE_FINAL_DURATION: float = 0.75
const SCALE_INITIAL_DURATION: float = 0.75
const SCALE_INITIAL_SIZE := Vector3(2,2,2)
const SCALE_UNIT_INITIAL_SIZE: float = 0.01

func onCocusPocus(_Unit: UnitGD) -> void:
	VFX.onUpscaleCocusPocus(_Unit, SCALE_INITIAL_SIZE, SCALE_INITIAL_DURATION, SCALE_UNIT_INITIAL_SIZE, DELAY_DURATION, onCocusPocusInitialFinished.bind(_Unit))

func onCocusPocusInitialFinished(_Unit: UnitGD) -> void:
	var _tiles: Array = onFindSpawnTiles()
	Combat.onTeleport(_Unit, _tiles[randi() % _tiles.size()])
	VFX.onDownscaleCocusPocus(_Unit, SCALE_FINAL_DURATION, onCocusPocusFinished.bind(_Unit))
	
func onCocusPocusFinished(_Unit: UnitGD) -> void:
	Combat.onHealAbility(_Unit, Unit, HEAL)
	change_camera = true
