extends IObjectGD

# Make recharge at the end

var was_extinguished: bool
var was_fuel_added: bool
var cards_in_range: Array

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is OccupyAction and was_fuel_added:
			onUpdateCardsInRange(action)
	elif !action.post:
		if action is StatAction and was_fuel_added and action.isHeal():
			onHeal(action)

func onLoadDataLevel() -> void:
	super()

func getValidActiveEffects(Card: CardGD) -> Array:
	var arr: Array = active_effects if isAdjacent(Card.getCoords()) else [] # For debugging
	return arr

func getActiveEffectTiles(_active_effect: ActiveEffectDatastore, Card: CardGD) -> ActiveEffectTiles:
	return ActiveEffectTiles.new([Card.Tile], [Card.Tile])

func onActiveEffect(active_effect: ActiveEffectDatastore, _PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles, _Card: CardGD) -> void:
	var Tile: TileGD = getTile()
	if active_effect.name == "Extinguish":
		var tiles: Array = Game.getAdjacentOrCloserTiles(Tile, 2)
		var units: Array = Game.get_tree().get_nodes_in_group("FieldCardsGD").filter(func(x: CardGD): return x.Tile in tiles)
		onPushAction(StatAction.new(units.map(func(x: CardGD): return StatInfo.new(x, Game.Stats.ATTACK, 1))))
		was_extinguished = true
		
		for owned_active_effect in active_effects:
			if owned_active_effect.name == "Add Fuel":
				onPushAction(ChangeActiveEffectChargesAction.new(owned_active_effect, -1))
	
	elif active_effect.name == "Add Fuel":
		var tiles: Array = getFuelTilesInRange()
		var units: Array = Game.get_tree().get_nodes_in_group("FieldCardsGD").filter(func(x: CardGD): return x.Tile in tiles)
		for FieldCard in units: onAddFieldEffect(FieldCard)
		was_fuel_added = true
		
		for owned_active_effect in	 active_effects:
			if owned_active_effect.name == "Extinguish":
				onPushAction(ChangeActiveEffectChargesAction.new(owned_active_effect, -1))
		
func onActiveEffectPre(active_effect: ActiveEffectDatastore, _PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles, _Card: CardGD) -> void:
	if active_effect.name == "Extinguish":
		onExtinguishVFX()
		
	elif active_effect.name == "Add Fuel":
		onAddFuelVFX()
		
func onAddFieldEffect(Card: CardGD) -> void:
	var FieldEffect: FieldEffectGD = SavedData.onLoadModel(SavedDataFieldEffect.new(7, true), Card)
	Card.onAddFieldEffect(FieldEffect, self)
	cards_in_range.append(Card)
	
func onRemoveFieldEffect(Card: CardGD) -> void:
	Card.onRemoveFieldEffectsByOwner(self)
	cards_in_range.erase(Card)

func onUpdateCardsInRange(action: Action) -> void:
	if action.Card in cards_in_range:
		if action.Tile == null: onRemoveFieldEffect(action.Card)
		elif action.Tile not in getFuelTilesInRange(): onRemoveFieldEffect(action.Card)
		
	elif !action.Card in cards_in_range:
		if action.Tile != null and action.Tile in getFuelTilesInRange():
			onAddFieldEffect(action.Card)
		
func getFuelTilesInRange() -> Array:
	return Game.getAdjacentOrCloserTiles(getTile(), 3)
	
func onSave() -> SavedDataIObject:
	ability_save['cards_in_range'] = cards_in_range.map(func(x: CardGD): return x.public_id)
	ability_save['was_fuel_added'] = was_fuel_added
	ability_save['was_extinguished'] = was_extinguished
	return super()

func onHeal(action: Action) -> void:
	for stat_info in action.stat_infos.filter(func(x: StatInfo): return x.Card in cards_in_range):
		for i in range(stat_info.types.size()):
			if stat_info.types[i] == Game.Stats.HEALTH and stat_info.values[i] > 0:
				stat_info.values[i] *= 2

var SmokeParticle: GPUParticles3D
func onHiddenVFX() -> void:
	if !was_extinguished and SmokeParticle != null:
		SmokeParticle.queue_free()

func onVisibleDefaultVFX() -> void:
	if SmokeParticle == null:
		SmokeParticle = load(info.SMOKE_PARTICLE_SCENE_PATH).instantiate()
		SmokeParticle.position.y += 0.3
		add_child(SmokeParticle)
		if was_fuel_added: onAddFuelVFX()
	
func onUpdateLevelVisible() -> void:
	super()
	
	if isLevelVisible(): onVisibleDefaultVFX()
	else: onHiddenVFX()
	
func onAddFuelVFX() -> void:
	if SmokeParticle != null:
		SmokeParticle.amount_ratio = 1
	
func onExtinguishVFX() -> void:
	if SmokeParticle != null:
		SmokeParticle.emitting = false
		await SmokeParticle.finished
		SmokeParticle.queue_free()
