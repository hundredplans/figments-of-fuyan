extends IObjectGD

var AniPlayer: AnimationPlayer
func onReady() -> void:
	AniPlayer = preload("res://scenes/screens/level_map/utility_nodes/object_manager/extras/trinket_animation_player.tscn").instantiate()
	ObjModel.add_child(AniPlayer)
	AniPlayer.play("Idle")
	
func onTrigger(_Unit: UnitGD, trigger: int, _args: TriggerInfoGD) -> void:
	if trigger == TriggerGD.END_TURN_GLOBAL and BaseTile.Unit != null:
		var Unit: UnitGD = BaseTile.Unit
		AniPlayer.play("Pickup")
		ActionManager.onAddAction(ArgDelayActionGD.new(Callable(), onAfterDelay, Unit.isVis(), DelayGD.new(2)), ActionManagerGD.PUSH)
		
func onAfterDelay() -> void:
	ObjectManager.onRemoveIObject(self)
	var trinket_id: int = info.id - 21 # from 0 to 4 corresponding to array
	var trinket_info: Resource = preload("res://scenes/screens/level_map/utility_nodes/object_manager/extras/trinkets/trinket_info.tres")
	var Trinket: TrinketEffectGD = trinket_info.getTrinketScript(trinket_id)
	
	GameEffects.addGFX(BaseTile.Unit, GameFXGD.TRINKET, {"Trinket": Trinket})
	
