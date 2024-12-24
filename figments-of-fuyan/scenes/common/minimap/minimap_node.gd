extends Control

@onready var TxRect: TextureRect = %TextureRect
@export var WHITE_OUTLINE: ShaderMaterial
var map_location: MapLocation
var links: Array

func setInfo(tx: Texture2D, _map_location: MapLocation, _links: Array, is_entered: bool) -> void: # null tx means it's a filler
	TxRect.texture = tx
	map_location = _map_location
	links = _links
	
	if is_entered:
		TxRect.material = WHITE_OUTLINE
