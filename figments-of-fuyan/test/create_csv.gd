extends Node

var eye_color: Array = ["blue", "brown", "grey", "white", "green", "black"]
var hair_color: Array = ["blue", "brown", "grey", "white", "green", "black"]
var firstname: Array = ["Jan", "Tom", "Rob", "Bob", "Marge", "Bart"]
var lastname: Array = ["Plutonski", "Dabrowski", "Anisimow", "Romski", "Domski"]
var gender: Array = ["male", "female", "other"]
var fields: Array = ["firstname", "lastname", "hair_color", "eye_color", "gender"]

func _ready() -> void:
	var file: FileAccess = FileAccess.open("file.csv", FileAccess.WRITE)
	

	var first_line: String = fields.reduce(func(x: String, y: String): return x + "," + y, "")
	first_line = first_line.substr(1)
	file.store_line(first_line)
	for __ in range(1000):
		var next_line: String
		for field in fields:
			next_line += "," + get(field).pick_random() 
		next_line = next_line.substr(1)
		file.store_line(next_line)
	file.close()
