class_name ArmorGD
extends TraitGD

signal damage_blocked
var armor: int

func onReady(init: TraitInitGD) -> void:
	armor = init.armor
