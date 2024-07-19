extends UniqueTileGD

func onReady() -> void:
	var model: Node3D = Tile.types[0].model.get_node("CrabArmArmature")
	model.visible = false
	model.position.y -= 0.2

#func onCreateGFX() -> void:
	#custom_triggers = [
		#TriggerGD.new(self, Unit, onNextTurn, TriggerGD.TURN_PASSED, TriggerGD.REMOVE_FX)
	#]
	#GameEffects.onDefaultStun(Unit)
	#Unit.Model.onMarioJump()
#
#func onNextTurn() -> void:
	#var AppliedBy := AppliedByGD.new(AppliedByGD.GAME_EVENT)
	#Units.changeStats(StatInfoGD.new(Unit, AppliedBy, StatsGD.BOTH_SPEED, -1, 1))
