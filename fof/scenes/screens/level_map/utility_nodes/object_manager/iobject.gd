class_name IObjectGD
extends Resource

var Units: UnitsGD
var ActionManager: ActionManagerGD
var GameEffects: GameEffectsGD
var Combat: CombatGD
var Tiles: TilesGD
var StatusManager: StatusManagerGD

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
