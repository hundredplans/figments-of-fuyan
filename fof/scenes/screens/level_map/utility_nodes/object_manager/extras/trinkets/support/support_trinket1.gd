extends TrinketEffectGD

var description: String = "This unit has DESTRUCTIVE"
func onReady() -> void:
	Unit.onQuickAddTrait(TraitInfoGD.ID.DESTRUCTIVE)
	var trinket_info: Resource = load("res://scenes/screens/level_map/utility_nodes/object_manager/extras/trinkets/trinket_info.tres")
	for _Unit in Unit.getVisibleAllies():
		var Trinket: TrinketEffectGD = trinket_info.getTrinketScript(trinket_id)
		GameEffects.addGFX(_Unit, GameFXGD.TRINKET, {"Trinket": Trinket, "avoid_ready": true})
		_Unit.onQuickAddTrait(TraitInfoGD.ID.DESTRUCTIVE)
	
