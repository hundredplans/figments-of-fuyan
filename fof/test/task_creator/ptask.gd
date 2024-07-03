class_name PTaskGD
extends Resource

enum Category {
	BOONS,
	OTHER,
}

enum Type {
	FEATURE,
	BUG,
	CHECK,
	KUBA
}

@export var category: int
@export var type: int
@export var description: String
@export var EDT: int
@export var necessity: int

func _init(_category: int = 0, _type: int = 0, _description: String = "", _EDT: int = 0, _necessity: int = 0) -> void:
	category = _category
	type = _type
	description = _description
	EDT = _EDT
	necessity = _necessity
