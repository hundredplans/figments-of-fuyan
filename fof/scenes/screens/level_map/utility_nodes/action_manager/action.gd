class_name ActionGD
extends Resource

var SpectateCamera: SpectateCameraGD
var PlayerManager: PlayerManagerGD
var Units: UnitsGD
var LevelUI: LevelUIGD
var LevelMap: LevelMapGD
var AIManager: AIManagerGD
var Combat: CombatGD
var StatusManager: StatusManagerGD
var Hand: HandGD
var Vision: VisionGD
var GameEffects: GameEffectsGD
var ActionManager: ActionManagerGD
var Tiles: TilesGD
var TriggerManager: TriggerManagerGD

var Unit: UnitGD
var is_visible: bool
var delay: DelayGD

func _init() -> void: Helper.onCreateChildReferences(self)
