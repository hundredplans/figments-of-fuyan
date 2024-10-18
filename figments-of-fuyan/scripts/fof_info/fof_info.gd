class_name FofInfo extends Resource

@export var id: int
@export var name: String
@export var gdscript: GDScript
@export var saved_data: GDScript

static func getFofName() -> String: return "Fof"

static func getInfoPath() -> String: return "res://resources/fof"
