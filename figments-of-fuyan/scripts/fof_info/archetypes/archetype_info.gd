class_name ArchetypeInfo extends FofInfo

@export var behaviours: Array[GDScript]
@export_multiline var description: String
@export_range(0, 100, 1) var calling_chance: int
@export_range(0, 100, 1) var accepting_chance: int

static func getFofName() -> String: return "Archetype"
