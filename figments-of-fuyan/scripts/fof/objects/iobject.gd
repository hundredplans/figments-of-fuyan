class_name IObjectGD extends ObjectGD

@warning_ignore("unused_signal")
signal update_active_effect_description

const IOBJECT_OUTLINE_PATH: String = "res://resources/materials/game/base_material_outline_thick/material/yellow_outline.tres"

var AniPlayer: AnimationPlayer

var active_effect_charges: int
var active_effect_used: bool

var ability_save: Dictionary = {}
var top_vertex_y: float # The y position of the top vertex

func onLoadData(data: SavedData) -> void:
	super(data)
	active_effect_charges = data.active_effect_charges
	active_effect_used = data.active_effect_used
	ability_save = data.ability_save

	for custom_variable in ability_save:
		set(custom_variable, ability_save[custom_variable])
	
	if get_child(0).has_node("AnimationPlayer"):
		AniPlayer = get_child(0).get_node("AnimationPlayer")
	
	add_to_group("IObjectsGD")
	
func onPlayAnimation(animation_name: String, play_backwards: bool = false) -> void:
	if !play_backwards: AniPlayer.play(animation_name)
	else: AniPlayer.play_backwards(animation_name) 
	
func onLoadDataLevelFofInit() -> void:
	super()
	ability_save = {}
	
	var _active_effect_charges: int = getDefaultActiveEffectCharges()
	if _active_effect_charges == -2: return
	
	var new_charges: int = _active_effect_charges - active_effect_charges 
	var set_to_infinite: bool = _active_effect_charges == -1
	onPushAction(ChangeActiveEffectChargesAction.new(self, new_charges, set_to_infinite))
	
func onLoadModel() -> void:
	super()
	setTopVertexY()

func onApplyGreyscaleMaterial() -> void:
	var greyscale_material: ShaderMaterial = load(info.GREYSCALE_MATERIAL) if !isLevelVisible() and !Helper.admin_datastore.see else load(IOBJECT_OUTLINE_PATH)
	for mesh in getMeshes():
		for surface_id in mesh.get_surface_override_material_count():
			mesh.set_surface_override_material(surface_id, greyscale_material)
	
func setOccupiedTiles(tile_position_to_tile: Dictionary) -> void:
	super(tile_position_to_tile)

func onSave() -> SavedDataIObject:
	return SavedDataIObject.new(info.id, false, public_id, coords, tile_rotation, vision_datastore, variation, map_rotation, map_position, height,\
	occupied_tiles.map(func(x: TileGD): return x.getCoords()), groups, active_effect_charges, ability_save, active_effect_used)

func onProcessAction(action: Action) -> void:
	super(action)
#region Animation
func onAbility() -> void:
	if isLevelVisible():
		AniPlayer.play("Ability")
#endregion

func onAdvanceTurn(team: int) -> void:
	if team != 0 and active_effect_charges != -2: return
	var actions: Array = [ChangeActiveEffectUsedAction.new(self, false)]
	onPushAction(actions)
	
func setTopVertexY() -> void:
	top_vertex_y = getMeshes(Model)\
		.map(func(x: MeshInstance3D): return x.mesh.get_faces())\
		.reduce(func(y: Array, z: Array): return y + z, [])\
		.map(func(v: Vector3): return v.y)\
		.max()
	
func getTopVertexY() -> float:
	return top_vertex_y
	
func onIObject(_action: Action) -> void:
	pass
		
func onIObjectSpecificTransforms(_tiles_to_value: Dictionary, _DFL: DefaultFightLogic) -> void:
	pass
	
func onActiveEffect(_PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles, _Card: CardGD) -> void: pass
func onActiveEffectPre(_PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles, _Card: CardGD) -> void: pass
func getActiveEffectTiles(_Card: CardGD) -> ActiveEffectTiles: return null

func isValidActiveEffect(_Card: CardGD) -> bool: # Can show up
	return active_effect_charges != -2
	
func isActiveEffectDisabled(Card: CardGD) -> bool: # Is greyedo ut
	return isValidActiveEffect(Card) and (active_effect_charges == 0 or active_effect_used)
	
func onAIAbilityChecker(_active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic, type := Game.AbilityAI.NULL) -> TileGD: # Card is inside DFL
	return null
	
func onAIAbilityCheckerDefault(Card: CardGD) -> ActiveEffectTiles:
	if isActiveEffectDisabled(Card): return null
	
	var active_effect_tiles: ActiveEffectTiles = getActiveEffectTiles(Card)
	if active_effect_tiles == null or active_effect_tiles.pickable_tiles.is_empty(): return null
	return active_effect_tiles
	
func setActiveEffectUsed(state: bool) -> void: active_effect_used = state
func getActiveEffectUsed() -> bool: return active_effect_used
func getActiveEffectCharges() -> int: return active_effect_charges
func setActiveEffectCharges(value: int) -> void: active_effect_charges = value
func getDefaultActiveEffectCharges() -> int: return getInfo().getActiveEffectCharges()

func getInfo() -> ObjectInfo:
	return info
