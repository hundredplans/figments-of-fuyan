class_name LoreBookInfo extends FofInfo

@export var category: Categories
@export_multiline var text: String
enum Categories {Null, Sugori, Zengef, Befre, Varoma, AshboneCitadel}
static func getCategoryString(_category: Categories):
	match _category:
		Categories.Null: return ""
		Categories.Sugori: return "Sugori"
		Categories.Zengef: return "Zengef"
		Categories.Befre: return "Befre"
		Categories.Varoma: return "Varoma"
		Categories.AshboneCitadel: return "Ashbone Citadel"
