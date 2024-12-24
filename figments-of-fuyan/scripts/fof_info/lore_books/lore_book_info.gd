class_name LoreBookInfo extends FofInfo

@export var category: Categories
@export_multiline var text: String
enum Categories {Null, Sugori, Zengef, Befre, Varoma, AshboneCitadel, Magic, Pustan, RuuBo, Bauland, Nolaka,\
	NewShreev, HolyShreev, Milshreev, Stoneland, Acedonia, Dalanet, Goblinland, HamaCik, Janaite, Jiralta,\
	Kaluta, Manok, Roroni, Rutof, Triarwell, Unim, LostBooks, Monsters, Ideas}
static func getCategoryString(_category: Categories):
	match _category:
		Categories.Null: return ""
		Categories.Sugori: return "Sugori"
		Categories.Zengef: return "Zengef"
		Categories.Befre: return "Befre"
		Categories.Varoma: return "Varoma"
		Categories.AshboneCitadel: return "Ashbone Citadel"
		Categories.Magic: return "Magic"
		Categories.Pustan: return "Pustan"
		Categories.RuuBo: return "Ruu Bo"
		Categories.Bauland: return "Bauland"
		Categories.Nolaka: return "Nolaka"
		Categories.NewShreev: return "New Shreev"
		Categories.HolyShreev: return "Holy Shreev"
		Categories.Milshreev: return "Milshreev"
		Categories.Stoneland: return "Stoneland"
		Categories.Acedonia: return "Acedonia"
		Categories.Dalanet: return "Dalanet"
		Categories.Goblinland: return "Goblinland"
		Categories.HamaCik: return "Hama Cik"
		Categories.Janaite: return "Janaite"
		Categories.Jiralta: return "Jiralta"
		Categories.Kaluta: return "Ka'luta"
		Categories.Manok: return "Manok"
		Categories.Roroni: return "Roroni"
		Categories.Rutof: return "Rutof"
		Categories.Triarwell: return "Triarwell"
		Categories.Unim: return "Unim"
		Categories.LostBooks: return "Lost Books"
		Categories.Monsters: return "Monsters"
		Categories.Ideas: return "Ideas"
