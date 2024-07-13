class_name BoonInfoGD
extends FofInfoGD

@export var icon: Texture2D
@export_multiline var description: String
@export_multiline var ascended_description: String
@export var rarity: RARITIES
@export var boon_script: GDScript
@export var track_charges: bool

enum RARITIES {
	MINI,
	SCRAP,
	COMMON,
	RARE,
	EXALT,
	BOSS,
}
