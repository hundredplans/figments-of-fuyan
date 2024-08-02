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

var ObjModel: Node3D
var BaseTile: TileGD
var info: ObjectInteractTilesGD
# All interactable tiles, used to show path when hovered
@export var total_tiles: Array = []

func setInfo(_BaseTile: TileGD = null, _info: ObjectInteractTilesGD = null) -> void:
	BaseTile = _BaseTile
	info = _info
	ObjModel = BaseTile.types[1].model
	
	for ability in info.abilities:
		ability.charges = ability.max_charges
	
	if has_method("onReady"): call("onReady")

func _init() -> void:
	Helper.onCreateChildReferences(self)

func onAbilityCondition(Unit: UnitGD, ability: IObjectAbilityInfoGD) -> int:
	return 0 if Unit.Tile in ability.tiles else 2

	
# func onTrigger(Unit, trigger, args) -> Triggers when any trigger occurs
# func onReady() -> Called when initialized
# func onAbilityCondition() -> Return 0, 1, 2 (Enabled, Disabled, Invisible) for the unit mode boxes dependant on ability
# func onAbilityTrigger() -> Called when an ability is triggered
# func onAfterDelay() -> Called after the argdelay of an ability is done
