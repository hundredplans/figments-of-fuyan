class_name IObjectGD extends ObjectGD

var AniPlayer: AnimationPlayer
var active_effects: Array = []
var ability_save: Dictionary = {}

func onLoadData(data: SavedData) -> void:
	super(data)
	active_effects = data.active_effects
	ability_save = data.ability_save

	for active_effect in active_effects:
		active_effect.owner = self

	for custom_variable in ability_save:
		set(custom_variable, ability_save[custom_variable])
	
	if get_child(0).has_node("AnimationPlayer"):
		AniPlayer = get_child(0).get_node("AnimationPlayer")
	
	add_to_group("IObjectsGD")

func onSave() -> SavedDataIObject:
	return SavedDataIObject.new(info.id, false, public_id, coords, tile_rotation, level_visible, is_revealed, variation, map_rotation, map_position, height,\
	occupied_tiles.map(func(x: TileGD): return x.getCoords()), active_effects, ability_save)

func onProcessAction(action: Action) -> void:
	if action.post:
		if action is ChangePhaseAction and action.phase == Game.Phases.START:
			onCreateActiveEffects()

#region Active Effects
func getValidActiveEffects(Card: CardGD) -> Array: # Returns the ability effects the Card can view
	return []

func onCreateActiveEffects() -> void:
	var active_effects: Array = info.active_effects
	if !active_effects.is_empty():
		onPushAction(active_effects.map(func(x: ActiveEffectDatastore): return AddActiveEffectAction.new(self, x)))

func onAddActiveEffect(active_effect: ActiveEffectDatastore) -> void:
	active_effects.append(active_effect)
	
func onActiveEffect(_active_effect: ActiveEffectDatastore, _PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles) -> void:
	pass
	
func onActiveEffectPre(_active_effect: ActiveEffectDatastore, _PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles) -> void:
	pass
#endregion
