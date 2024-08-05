class_name TraitInfoGD
extends Resource

@export var id: ID
@export var gfx_id: int
@export var name: String
@export var trait_script: GDScript

enum ID {
	ARMOR,
	DESTRUCTIVE,
	AMPHIBIOUS,
}
