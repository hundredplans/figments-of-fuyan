extends CardGD

var remove_armor_next_turn: bool = false
var armor_id: int

func onProcessAction(action: Action) -> void:
	if action.post:
		if action is ChangePhaseAction and Game.isAdvanceTurn(action.phase, team) and armor_id > 0:
			onPushAction(RemoveOverworldTraitAction.new(self, armor_id, OverworldTrait.AddedBy.OTHER))
			armor_id = 0

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Hardened Shell":
		return ActiveEffectTiles.new([Tile], [Tile])
	return null
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Hardened Shell":
		var trait_data := SavedDataArmor.new(1, true, 0)
		trait_data.armor = 1
		armor_id = 1
		onPushAction(AddOverworldTraitAction.new(self, OverworldTrait.new(trait_data, OverworldTrait.AddedBy.OTHER, true), true))
		
		onAbility()

func onSave() -> SavedDataCard:
	ability_save['armor_id'] = armor_id
	return super()
