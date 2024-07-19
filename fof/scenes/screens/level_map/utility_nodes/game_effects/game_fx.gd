class_name GameFXGD
extends Node

var Unit: UnitGD
var type: int
var triggers: Array = []
var custom_triggers: Array = []

var Combat: CombatGD
var VFX: VFXGD
var StatusManager: StatusManagerGD
var SpectateCamera: SpectateCameraGD
var Tiles: TilesGD
var PlayerManager: PlayerManagerGD
var Units: UnitsGD
var GameEffects: GameEffectsGD

enum {DAZE, STAGGER, ABILITY_ACTIVE, HELPFUL_HELMET, CHARMING_STANCE, ENERGIZED_BOON}

func _init() -> void:
	Helper.onCreateChildReferences(self)

func setInfo(_Unit: UnitGD, _type: int, _triggers: Array, a: Dictionary) -> void:
	Unit = _Unit
	type = _type
	triggers = _triggers
	for key in a: set(key, a[key])

func onAfterCreateGFX() -> void:
	triggers += custom_triggers
	for trigger in triggers: trigger.GameFX = self
	custom_triggers = []
