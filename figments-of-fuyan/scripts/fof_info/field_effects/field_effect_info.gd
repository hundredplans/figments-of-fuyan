class_name FieldEffectInfo extends FofInfo

@export var icon: Texture2D
@export_multiline var description: String
@export_multiline var ascended_description: String
@export var ascended_type: AscendedTypes
@export var display_number_type: DisplayNumberType
@export var remove_on_owner_death: bool = true

enum DisplayNumberType {NULL, CHARGES, TURNS}
enum AscendedTypes {NULL, CARD, OWNER}

static func getFofName() -> String: return "FieldEffect"
func getIcon() -> Texture2D: return icon
