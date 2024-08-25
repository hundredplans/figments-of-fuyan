class_name BoonInfoGD extends Resource

@export var id: int
@export var name: String
@export_multiline var description: String
@export var gdscript: GDScript
@export var RARITY: RARITIES

enum RARITIES {SCRAP, MINI, COMMON, RARE, EXALT, MINIBOSS, BOSS, CHAMPION}
