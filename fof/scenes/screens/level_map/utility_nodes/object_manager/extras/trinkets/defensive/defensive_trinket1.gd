extends TrinketEffectGD

var charges: int = 2
var description: String = "This unit has ARMOR [1] for the next [X] hits"

func onReady() -> void:
	if !Unit.hasTrait(TraitInfoGD.ID.ARMOR):
		var armor_init := ArmorInitGD.new()
		armor_init.armor = 1
		var Trait: TraitGD = Unit.onAddTrait(armor_init)
		Trait.damage_blocked.connect(onDamageBlocked)
	else: onRemoveGameFX()

func getDescription() -> String:
	var description: String = super()
	return description.replace("[X]", "[" + str(charges) + "]")

func onDamageBlocked() -> void:
	charges -= 1
	if charges == 0:
		Unit.onRemoveTrait(TraitInfoGD.ID.ARMOR)
		onRemoveGameFX()
