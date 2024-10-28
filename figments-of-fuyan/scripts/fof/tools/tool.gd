class_name ToolGD extends FofGD

var Card: CardGD
var ascended: bool
var active_effects: Array[ActiveEffectDatastore]
var ability_save: Dictionary

func onLoadData(data: SavedData) -> void:
	ascended = data.ascended
	active_effects = data.active_effects
	
	for active_effect in active_effects:
		active_effect.owner = self
		
	for custom_variable in ability_save:
		set(custom_variable, ability_save[custom_variable])
	
func onSave() -> SavedDataTool:
	return SavedDataTool.new(info.id, false, public_id, ascended, active_effects, ability_save)
	
func onCreateActiveEffects() -> void:
	active_effects = []
	onPushAction(info.active_abilities.map(func(x: ActiveEffectDatastore): return AddActiveEffectAction.new(self, x)))

func onAddActiveEffect(active_effect: ActiveEffectDatastore) -> void:
	active_effects.append(active_effect)

func getRarity() -> Game.Rarities:
	return info.RARITY

func getIcon() -> ImageTexture:
	return ImageTexture.create_from_image(info.icon)

func getDescription() -> String:
	return info.description if !ascended else info.ascended_description	

func onProcessAction(action: Action) -> void:
	if action.post:
		if action is AddToolAction and action.Tool == self:
			Card = action.Card
			onCreateActiveEffects()
			onToolEquipped()
		elif action is RemoveToolAction and action.Card == Card:
			onToolUnequipped()

func getActiveEffectTiles(_active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	return null
	
func onActiveEffect(_active_effect: ActiveEffectDatastore, _PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles) -> void:
	pass
	
func onToolEquipped() -> void:
	pass
	
func onToolUnequipped() -> void:
	onClear()
