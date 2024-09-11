class_name EncounterInfo extends FofInfo

@export var branch: BranchDatastore
@export var can_occur_randomly: bool = true

static func getInfoPath() -> String: return "res://resources/fof/encounters"
