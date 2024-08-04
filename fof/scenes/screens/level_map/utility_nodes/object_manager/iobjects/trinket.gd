extends IObjectGD

const TRINKET_TYPE_CONVERSION: Dictionary = {
	21: "offensive"
}

var AniPlayer: AnimationPlayer
func onReady() -> void:
	AniPlayer = preload("res://scenes/screens/level_map/utility_nodes/object_manager/extras/trinket_animation_player.tscn").instantiate()
	ObjModel.add_child(AniPlayer)
	AniPlayer.play("Idle")
	
func onTrigger(_Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if trigger == TriggerGD.END_TURN_GLOBAL and BaseTile.Unit != null:
		var Unit: UnitGD = BaseTile.Unit
		AniPlayer.play("Pickup")
		#GameEffects.addGFX(Unit, GameFXGD.TRINKET, {"type": TRINKET_TYPE_CONVERSION})
		ActionManager.onAddAction(ArgDelayActionGD.new(Callable(), onAfterDelay, Unit.isVis(), DelayGD.new(2)), ActionManagerGD.PUSH)
		
func onAfterDelay() -> void:
	ObjectManager.onRemoveIObject(self)
