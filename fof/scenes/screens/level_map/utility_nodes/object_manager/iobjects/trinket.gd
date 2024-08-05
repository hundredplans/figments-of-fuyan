extends IObjectGD

const TRINKET_TYPE_CONVERSION: Dictionary = {
	21: "offensive"
}

var AniPlayer: AnimationPlayer
func onReady() -> void:
	AniPlayer = preload("res://scenes/screens/level_map/utility_nodes/object_manager/extras/trinket_animation_player.tscn").instantiate()
	ObjModel.add_child(AniPlayer)
	
	var mesh: MeshInstance3D = ObjModel.get_child(0)
	for i in mesh.get_surface_override_material_count():
		var mat: Material = load("res://assets/materials/base_materials/base_material_half_transparent_flat.tres").duplicate()
		mat.texture = mesh.get_active_material(i).albedo_texture
		mesh.set_surface_override_material(i, mat)
	
	AniPlayer.play("Idle")
	
func onTrigger(_Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if trigger == TriggerGD.END_TURN_GLOBAL and BaseTile.Unit != null:
		var Unit: UnitGD = BaseTile.Unit
		AniPlayer.play("Pickup")
		ActionManager.onAddAction(ArgDelayActionGD.new(Callable(), onAfterDelay, Unit.isVis(), DelayGD.new(2)), ActionManagerGD.PUSH)
		
func onAfterDelay() -> void:
	ObjectManager.onRemoveIObject(self)
	var trinket_id: int = info.id - 21 # from 0 to 4 corresponding to array
	var trinket_info: Resource = preload("res://scenes/screens/level_map/utility_nodes/object_manager/extras/trinkets/trinket_info.tres")
	var Trinket: TrinketEffectGD = trinket_info.getTrinketScript(trinket_id)
	Trinket.trinket_id = trinket_id
	
	GameEffects.addGFX(BaseTile.Unit, GameFXGD.TRINKET, {"Trinket": Trinket})
	
