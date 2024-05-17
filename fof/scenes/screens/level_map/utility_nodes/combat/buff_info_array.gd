class_name BuffInfoArrayGD
extends Resource
# Meant to use for a BuffInfo of the same stat where we add all the values, can't be used for absolutes
# Interact with this via Combat
var Unit: UnitGD
@export var value: int = 1
@export var stat: String
@export var array: Array # List of BuffInfo's and their respective values
