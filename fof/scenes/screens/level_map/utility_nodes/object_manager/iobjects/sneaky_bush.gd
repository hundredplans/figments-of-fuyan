extends IObjectGD
	
func onAbilityTrigger(Unit: UnitGD, _ability: IObjectAbilityInfoGD) -> void:
	var ani_player: AnimationPlayer = ObjModel.get_node("AnimationPlayer")
	ani_player.play("Destroy")
	
func onAfterDelay() -> void:
	ObjectManager.onRemoveIObject(self)
