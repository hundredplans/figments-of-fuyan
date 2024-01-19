class_name UnitsGD
extends Node3D

var UnitScene: PackedScene = preload("res://scenes/screens/level_map/utility_nodes/units/unit.tscn")
func on_card_placed(hand_card: HandCardGD, tile_position: Vector3) -> void:
	var Unit: UnitGD = UnitScene.instantiate()
	add_child(Unit)
	Unit.on_create_unit(hand_card.id, hand_card.tool_id, hand_card.effects, 0, tile_position)

func on_player_phase_start() -> void:
	pass

func on_units(team: int, relation: String) -> Array:
	return get_children().filter(on_match_team_relation.bind(team, relation))

func on_match_team_relation(unit: UnitGD, team: int, relation: String) -> bool:
	return (unit.team == team and relation == "Ally") or (unit.team != team and relation == "Enemy")
