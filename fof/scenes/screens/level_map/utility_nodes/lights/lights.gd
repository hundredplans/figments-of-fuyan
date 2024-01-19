class_name LightsGD
extends Node

@onready var TileSpotlight: SpotLight3D = $TileHighlight
const LIGHT_TYPE_TO_COLOR: Dictionary = {
	"Spawn": Color(0,1,0),
	"Regular": Color(1,1,1)
}

func _ready() -> void:
	TileSpotlight.visible = false

func on_tile_hovered(tile: Node3D, type: String) -> void:
	TileSpotlight.visible = true
	TileSpotlight.position = Vector3(tile.global_position.x, tile.global_position.y + 1.3, tile.global_position.z)
	TileSpotlight.light_color = LIGHT_TYPE_TO_COLOR[type]

func on_tile_unhovered() -> void:
	TileSpotlight.visible = false
