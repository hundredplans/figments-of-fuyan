class_name VFXInfo extends FofInfo

static func getInfoPath() -> String: return "res://resources/fof/vfx/"

static func getFofName() -> String: return "VFX"

@export var delay: float
@export var scene: PackedScene # Can also be a glb
