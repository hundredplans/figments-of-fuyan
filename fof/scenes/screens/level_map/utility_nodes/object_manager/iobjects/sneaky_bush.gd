extends IObjectGD
	
var invisible_fx: GameFXGD
var blind_fx: GameFXGD
var LastUnit: UnitGD

func onTrigger(Unit: UnitGD, trigger: int, _args: TriggerInfoGD) -> void:
	if trigger == TriggerGD.MOVE and Unit.Tile == BaseTile:
		invisible_fx = GameEffects.addGFX(Unit, GameFXGD.INVISIBLE)
		blind_fx = GameEffects.addGFX(Unit, GameFXGD.BLIND)
		LastUnit = Unit
	elif trigger == TriggerGD.MOVE and Unit.Tile != BaseTile and LastUnit == Unit:
		GameEffects.onRemoveFX(blind_fx)
	
func onAbilityTrigger(_Unit: UnitGD, _ability: IObjectAbilityInfoGD) -> void:
	var ani_player: AnimationPlayer = ObjModel.get_node("AnimationPlayer")
	ani_player.play("Destroy")
	
func onAfterDelay() -> void:
	GameEffects.onRemoveFX(blind_fx)
	GameEffects.onRemoveFX(invisible_fx)
	ObjectManager.onRemoveIObject(self)
