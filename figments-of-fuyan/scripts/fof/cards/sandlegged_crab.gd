extends CardGD

var remove_armor_next_turn: bool = false
var armor_public_id: int = 0

func onProcessAction(action: Action) -> void:
	if action.post:
		if action is ChangePhaseAction and Game.isAdvanceTurn(action.phase, team) and armor_public_id > 0:
			onPushAction(RemoveTraitAction.new(Game.onFindPublicIDObject(armor_public_id)))
			armor_public_id = 0

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Hardened Shell":
		return ActiveEffectTiles.new([Tile], [Tile])
	return null
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Hardened Shell":
		var ArmorTrait: TraitGD = onCreateArmorTrait(1)
		armor_public_id = ArmorTrait.public_id
		onPushAction(AddTraitAction.new(ArmorTrait, self))
		onAbility()

func onSave() -> SavedDataCard:
	ability_save['armor_public_id'] = armor_public_id
	return super()
