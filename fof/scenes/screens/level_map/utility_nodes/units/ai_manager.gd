class_name AIManagerGD
extends Node

var Tiles: TilesGD
var Units: UnitsGD
var movement_order: Array = []

func onDeathFinished(Unit: UnitGD) -> void:
	movement_order.erase(Unit)

func onAIEndTurnPhaseStart() -> void:
	for Unit in Units.on_units(1):
		Unit.stats("speed", 0, "EndAIPhase", true)

func onAIPhaseStart() -> void:
	for Unit in Units.on_units(1):
		Unit.stats("speed", Unit.max_speed, "StartAIPhase", true)
		Unit.attack_amount = 1
		#Unit.turn_status = 0
		
	onMoveAIUnits()

func onMoveAIUnits() -> void:
	for Unit in movement_order:
		Tiles.on_create_movement_paths(Unit)
		print(Tiles.movement_paths.size())
		var movement_paths: Array = []
		for key in Tiles.movement_paths:
			if typeof(key) != TYPE_STRING and Tiles.movement_paths[key].size == Unit.speed:
				movement_paths.append(Tiles.movement_paths[key])
		
		print(movement_paths.size())
		print()
		if movement_paths.size() > 0:
			var chosen_path: Dictionary = movement_paths[randi() % movement_paths.size()]
			if chosen_path.size > 0: Tiles.on_remove_tile_material(Unit.Tile, "EmptyTile")
			for i in range(chosen_path.size):
				Units.move_to_tile(Unit, chosen_path.tiles[i], chosen_path.types[i])

func onUnitAwakened(Unit: UnitGD) -> void:
	if Unit.team == 1:
		onSortMovementOrder(Unit)

func onSortMovementOrder(Unit: UnitGD) -> void: # Lower is higher priority
	match movement_order.size():
		0: movement_order.append(Unit)
		1: movement_order.insert(int(movement_order[0].ai.aic > Unit.ai.aic), Unit)
		_:
			if !movement_order[0].ai.aic >= Unit.ai.aic:
				var is_inserted: bool = false
				for i in range(movement_order.size() - 1):
					if movement_order[i].ai.aic <= Unit.ai.aic and Unit.ai.aic <= movement_order[i + 1].ai.aic:
						movement_order.insert(i + 1, Unit)
						is_inserted = true
						break
				if !is_inserted: movement_order.append(Unit)
			else: movement_order.insert(0, Unit)
