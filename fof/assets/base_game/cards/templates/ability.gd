class_name AbilityGD
extends Resource

@export var ability_name: String
var charges: int = -1
@export var max_charges: int = -1
@export var ability_index: int = -1
## The delay after ability triggering before camera changes who's spectated.
@export var delay: float = 2.0
var is_visible: bool = false

var LevelMap: LevelMapGD
var SpectateCamera: Node3D
var GameEffects: GameEffectsGD
var Combat: CombatGD
var Tiles: TilesGD
var Units: UnitsGD
var Vision: VisionGD
var VFX: VFXGD
var LevelUI: LevelUIGD
var StatusManager: StatusManagerGD
var AIManager: AIManagerGD
var ActionManager: ActionManagerGD

func _init() -> void: Helper.onCreateChildReferences(self)
	
func onAbilityDelay(callable: Callable, _delay: float = 2) -> void:
	ActionManager.onAddAction(DelayActionGD.new(onCall.bind(callable), is_visible, DelayGD.new(_delay)), ActionManagerGD.PUSH)

func onCall(callable: Callable) -> void:
	callable.call()
