class_name DObjectInfoGD
extends Resource

@export var id: int
@export var name: String
@export var dobject_script: GDScript
@export var health: int = 1
# Each hit takes 1 health charge if false
@export var cap_damage_at_one: bool = true
