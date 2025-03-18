class_name EncounterInfo extends FofInfo

enum States {NEUTRAL, NEGATIVE, POSITIVE}
@export var pages: Array[EncounterPageDatastore]
@export var is_global: bool
@export var state: States
static func getInfoPath() -> String: return "res://resources/fof/encounters"
static func getFofName() -> String: return "Encounter"
