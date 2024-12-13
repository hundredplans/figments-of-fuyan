class_name StatsDatastore extends Resource

@export var attack: int
@export var health: int
@export var speed: int
@export var energy: int

func _init(_attack: int = 0, _health: int = 0, _speed: int = 0, _energy: int = 0) -> void:
	attack = _attack
	health = _health
	speed = _speed
	energy = _energy
