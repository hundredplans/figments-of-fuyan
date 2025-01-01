class_name MapEffectInfo extends FofInfo

@export_multiline var description: String
const SHILLING_ICON_PATH: String = "res://assets/sprites/ui/icons/shilling.png"

static func getInfoPath() -> String: return "res://resources/fof/map_effects"
static func getFofName() -> String: return "MapEffect"
func getIcon() -> Texture2D: return load(SHILLING_ICON_PATH)
