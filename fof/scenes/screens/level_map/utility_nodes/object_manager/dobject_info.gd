class_name DObjectInfoGD
extends Resource

@export var id: int
@export var name: String
@export var dobject_script: GDScript
@export var max_health: int = 1
# Each hit takes 1 health charge if false
@export var cap_damage_at_one: bool = true
@export var need_destructive: bool = true
@export var death_delay: float = 2
@export var attack_delay: float = 2
