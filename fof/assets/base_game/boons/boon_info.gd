class_name BoonInfoGD
extends FofInfoGD

@export var icon: Texture2D
@export_multiline var description: String
@export_multiline var ascended_description: String
@export var rarity: RARITIES

enum RARITIES {
	SCRAP,
	COMMON,
	RARE,
	EXALT,
	BOSS,
}
