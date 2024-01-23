class_name PlayerManagerGD
extends Node

var SpectateCamera: Camera3D
var Units: UnitsGD
func on_card_placed(hand_card: HandCardGD, Tile: TileGD) -> void:
	Units.on_unit_awakened(hand_card.id, hand_card.tool_id, hand_card.effects, 0, Tile.info.obj.rotation, Tile)
	SpectateCamera.on_spectate("Unit", Units.on_units().size() - 1)
