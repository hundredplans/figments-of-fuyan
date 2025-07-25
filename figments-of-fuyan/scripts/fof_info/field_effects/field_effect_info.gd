class_name FieldEffectInfo extends FofInfo

@export var icon: Texture2D
@export_multiline var description: String
@export var display_number_type: DisplayNumberType
@export var remove_on_owner_death: bool = true

enum DisplayNumberType {NULL, CHARGES, TURNS}

static func getFofName() -> String: return "FieldEffect"
func getIcon() -> Texture2D: return icon
