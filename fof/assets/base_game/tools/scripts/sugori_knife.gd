extends ToolGD

var sugori_knife_aura: AbilityGD
var gained_damage: bool = false
@export var extra_damage: int = 1
func onTrigger(_Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if trigger == TriggerGD.EQUIP_TOOL and args.Tool == self:
		onVFXTrigger(Unit)
	
	if trigger == TriggerGD.ON_ATTACK and _Unit == Unit and args.Unit.isInjured():
		Unit.extra_damage += extra_damage
		gained_damage = true
		
	elif trigger == TriggerGD.ON_AFTER_ATTACK and _Unit == Unit and gained_damage:
		Unit.extra_damage -= extra_damage
		gained_damage = false
		
	elif is_ascended:
		if trigger == TriggerGD.EQUIP_TOOL and args.Tool == self:
			sugori_knife_aura = Unit.onCreateAbility(preload("res://assets/base_game/tools/extras/sugori_knife_aura.tres"))
			sugori_knife_aura.vfx_callable = onVFXTrigger
			
		elif trigger == TriggerGD.UNEQUIP_TOOL and args.Tool == self:
			Unit.onRemoveAbility(sugori_knife_aura)

func onVFXTrigger(_Unit: UnitGD) -> void:
	VFX.onCreateUnitVFX(_Unit, "SugoriKnife")
