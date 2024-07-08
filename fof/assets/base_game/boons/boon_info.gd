class_name BoonInfoGD
extends FofInfoGD

@export var icon: Texture2D
@export_multiline var description: String
@export_multiline var ascended_description: String
@export var rarity: RARITIES
@export var script_name: String

enum RARITIES {
	SCRAP,
	COMMON,
	RARE,
	EXALT,
	BOSS,
}
