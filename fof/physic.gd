extends Node

func _ready() -> void:
	var a: Array = [
12,
12,
12,
12,
11.5,
88.5,
84,
78.5,
73.5,
68.5


	]

	var b: Array = [
88,
83,
78,
73,
68.5,
11.5,
11,
11.5,
11.5,
11.5,


	]
	
	for i in a: print(0.01 / pow(i, 2))
