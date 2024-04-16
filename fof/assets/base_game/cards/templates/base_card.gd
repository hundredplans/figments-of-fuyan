class_name BaseCardGD
extends FofInfoGD

@export var area_id: int
@export_range(0, 99) var attack: int
@export_range(0, 99) var health: int
@export_range(0, 9) var speed: int
@export_range(0, 99) var energy: int
@export_enum("Scrap", "Neutral", "Common", "Rare", "Exalt", "Miniboss", "Boss", "Champion") var rarity: int

@export_multiline var raw_text: String
@export_multiline var flavor_text: String
@export_multiline var text: String

@export_range(1, 7) var aic: int
@export_range(1, 7) var aii: int
@export_range(1, 7) var aiw: int
@export_range(1, 7) var ait: int
@export_range(1, 7) var aia: int

@export var weapon_offset: float = 0.1
@export var weapon: float = 0.5
@export var eye: float = 1.0
@export var top: float = 1.5
@export var stat: float = 2.0

@export var ability_names: Array[String]
