class_name ToolInfoGD
extends Resource

@export var id: int
@export var icon: Texture2D
@export var rarity: RARITIES
@export var tool_script: GDScript

@export_group("Text")
@export var display_name: String
@export_multiline var description: String
@export_multiline var ascended_description: String
@export_group("")
@export var tool_abilities: Array[ToolAbilityInfoGD]

enum RARITIES {
	MINI,
	SCRAP,
	COMMON,
	RARE,
	EXALT,
	BOSS,
}
