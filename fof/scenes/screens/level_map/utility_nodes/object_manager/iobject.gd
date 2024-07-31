class_name IObjectGD
extends Resource

var Units: UnitsGD
var ActionManager: ActionManagerGD
var GameEffects: GameEffectsGD
var Combat: CombatGD
var Tiles: TilesGD
var StatusManager: StatusManagerGD
var Vision: VisionGD
var ObjectManager: ObjectManagerGD
var Tools: ToolsGD
var SpectateCamera: SpectateCameraGD

var BaseTile: TileGD
var interactable_tiles: Array
var info: ObjectInteractTilesGD

func setInfo(_BaseTile: TileGD = null, _interactable_tiles: Array = [], _info: ObjectInteractTilesGD = null) -> void:
	BaseTile = _BaseTile
	interactable_tiles = _interactable_tiles
	info = _info
	
	for ability in info.abilities:
		ability.charges = ability.max_charges
	
	if has_method("onReady"): call("onReady")

func _init() -> void:
	Helper.onCreateChildReferences(self)

func onCondition(_Unit: UnitGD) -> bool: return false

# func onTrigger(Unit, trigger, args) -> Triggers when any trigger occurs
# func onReady() -> Called when initialized
# func onCondition() -> Finds whether to display all the unit mode boxes
