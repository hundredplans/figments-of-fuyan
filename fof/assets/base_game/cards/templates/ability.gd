class_name AbilityGD
extends Resource

@export var ability_name: String
var charges: int = -1
@export var max_charges: int = -1
@export var ability_index: int = -1
## The delay after ability triggering before camera changes who's spectated.
@export var delay: float = 2.0
var is_visible: bool = false

var GameEffects: GameEffectsGD
var Combat: CombatGD
var Tiles: TilesGD
var Units: UnitsGD
var Vision: VisionGD
var VFX: VFXGD

func onGainStats(Unit: UnitGD, stat_type: String, val: int, AppliedBy: AppliedByGD) -> void:
	if val > 0: Unit.stats(stat_type, val, AppliedBy)
	else: print_debug("You are gaining negative stats!")
