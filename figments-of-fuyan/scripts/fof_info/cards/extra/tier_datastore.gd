class_name TierDatastore extends Resource
# For each if the new value isn't set it takes the value from the previous tier
@export var attack: int = -1
@export var health: int = -1
@export var speed: int = -1
@export var energy: int = -1

@export var description: String
@export var active_abilities: Array[ActiveEffectDatastore]
@export var traits: Array[SavedDataTrait]
