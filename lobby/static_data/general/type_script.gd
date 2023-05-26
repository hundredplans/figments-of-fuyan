extends Resource

@export var types_to_stat: Dictionary = {
	"u": ["att", "hp", "spd", "nrg"],
	"s": [null, null, null, "nrg"],
	"p": [null, "hp", "pop", "nrg"],
	"t": ["att", "hp", "rng", "nrg"],
	"w": [null, "hp", null, "nrg"],
	"r": [null, null, "bod", "bld"],
	"c": [null, "hp", null, null],
}
