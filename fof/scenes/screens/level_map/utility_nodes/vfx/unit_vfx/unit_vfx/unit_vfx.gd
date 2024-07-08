class_name UnitVFXGD
extends Resource

@export var model: PackedScene
# Absolute: Relative to the floor of the Tile // Non-Absolute: Relative to the unit's stat height
@export var is_height_absolute: bool = false
@export var height: float = 0.1
@export var name: String
@export var inherit_rotation: bool = false
