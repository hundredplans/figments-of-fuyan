class_name IObjectGD extends ObjectGD

@warning_ignore("unused_signal")
signal update_active_effect_description

const IOBJECT_OUTLINE_PATH: String = "res://resources/materials/game/base_material_outline_thick/material/yellow_outline.tres"

var AniPlayer: AnimationPlayer
var active_effects: Array = []
var ability_save: Dictionary = {}
var top_vertex_y: float # The y position of the top vertex

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
	
func onPlayAnimation(animation_name: String, play_backwards: bool = false) -> void:
	if !play_backwards: AniPlayer.play(animation_name)
	else: AniPlayer.play_backwards(animation_name) 
	
func onLoadDataLevelFofInit() -> void:
	super()
	ability_save = {}
	
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
	occupied_tiles.map(func(x: TileGD): return x.getCoords()), groups, active_effects, ability_save)

func onProcessAction(action: Action) -> void:
	super(action)
#region Animation
func onAbility() -> void:
	if isLevelVisible():
		AniPlayer.play("Ability")
#endregion

func onAdvanceTurn(team: int) -> void:
	if team != 0: return
	var actions: Array = []
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
	
func isActiveEffectDisabled(_Card: CardGD) -> bool:
	return false
