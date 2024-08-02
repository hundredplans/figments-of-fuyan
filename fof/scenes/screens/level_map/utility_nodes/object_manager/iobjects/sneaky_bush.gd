extends IObjectGD

var ObjModel: Node3D
func onReady() -> void:
	ObjModel = BaseTile.types[1].model

func onCondition(Unit: UnitGD) -> bool:
	return Unit.Tile in interactable_tiles
	
func onAbilityTrigger(Unit: UnitGD, _ability: IObjectAbilityInfoGD) -> void:
	var ani_player: AnimationPlayer = ObjModel.get_node("AnimationPlayer")
	ani_player.play("Destroy")
	
func onAfterDelay() -> void:
	ObjectManager.onRemoveIObject(self)
	
func onAbilityCondition(_Unit: UnitGD, _ability: IObjectAbilityInfoGD) -> int:
	return 0
