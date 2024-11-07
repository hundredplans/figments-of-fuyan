extends CardGD

var valid_cards: Array = []
func onProcessAction(action: Action) -> void:
	super(action)
	if isValidTrauma(action) and action.Defender in valid_cards:
		onPushAction(TraumaAction.new(self, action))

func onTrauma(death_action: DeathAction) -> void:
	onPushAction(StatAction.new(StatInfo.new(self, Game.Stats.ATTACK, 1)))

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Charming Stance":
		var tiles: Array = getVisibleTiles()
		tiles.erase(Tile)
		return ActiveEffectTiles.new(tiles, tiles.filter(onPickable))
	return null
	
func onActiveEffectPre(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Charming Stance":
		var cards: Array = active_effect_tiles.pickable_tiles.map(func(x: TileGD): return Game.getAllyFieldCard(x, team))
		force_action.emit(ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, PickedTile)))
	
func onPickable(x: TileGD) -> bool:
	var Card: CardGD = Game.getAllyFieldCard(x, team)
	if Card != null and Card.isHealable():
		return true
	return false
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Charming Stance":
		var cards: Array = active_effect_tiles.pickable_tiles.map(func(x: TileGD): return Game.getAllyFieldCard(x, team))
		var actions: Array = [StatAction.new(
			cards.map(func(x: CardGD): return StatInfo.new(x, Game.Stats.HEALTH, 1))
		)]
		
		for Card in cards.filter(func(x: CardGD): return x not in valid_cards):
			Card.onAddBaseFieldEffect(3, self)
			valid_cards.append(Card)
			
		onPushAction(actions)
		onAbility()
		
func onSave() -> SavedDataCard:
	ability_save["valid_cards"] = valid_cards.map(func(x: FieldEffectGD): return x.public_id)
	return super()
	
func onLoadData(data: SavedData) -> void:
	super(data)
	valid_cards = valid_cards.map(func(x: int): return Game.onFindPublicIDObject(x))

func getDescription() -> String:
	var active_effect: ActiveEffectDatastore = getActiveEffectByName("Charming Stance")
	if active_effect != null:
		return Helper.getDescriptionNumeric(super(), [active_effect.charges], [["ABILITY ", ("[1]" if !ascended else "[2]")]])
	return super()
