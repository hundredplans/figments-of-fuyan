class_name TrinketEffectGD
extends Resource

var GameFX: GameFXGD
var Unit: UnitGD
var trinket_id: int
# The id within the trinket type
var trinket_inside_id: int
enum {OFFENSIVE, DEFENSIVE, MISC, DEBUFF, SUPPORT}

var SpectateCamera: SpectateCameraGD
var ActionManager: ActionManagerGD
var Vision: VisionGD
var Tiles: TilesGD
var Units: UnitsGD
var GameEffects: GameEffectsGD

func _init(_trinket_id: int = 0, _trinket_inside_id: int = 0) -> void:
	trinket_id = _trinket_id
	trinket_inside_id = _trinket_inside_id
	Helper.onCreateChildReferences(self)
	
func setInfo(_Unit: UnitGD, _GameFX: GameFXGD) -> void:
	Unit = _Unit
	GameFX = _GameFX

func getDescription() -> String:
	return "Trinket " + str(trinket_inside_id + 1) + ": " + get("description")

func onRemoveGameFX() -> void:
	GameEffects.onRemoveFX(GameFX)

func onTrigger(__: UnitGD, ___: int, ____: TriggerInfoGD) -> void: pass
