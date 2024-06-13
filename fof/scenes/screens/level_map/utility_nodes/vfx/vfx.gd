class_name VFXGD
extends Node3D

@onready var SpawnParticles: Node3D = %SpawnParticles
var Tiles: TilesGD
var Units: UnitsGD
var SpectateCamera: SpectateCameraGD
var Vision: VisionGD

func _ready() -> void:
	onCreateUnitVFXKeeper()

func onStartPhaseStart() -> void:
	onGenerateSpawnParticles()

func onGenerateSpawnParticles() -> void:
	for SpawnParticle in SpawnParticles.get_children(): SpawnParticle.queue_free()
	for Tile in Tiles.on_is_type_get_tiles("Spawn", "obj"):
		if !Units.unit_by_tile_bool(Tile):
			onCreateSpawnParticle(Tile)

func onHandPhaseStart() -> void:
	onGenerateSpawnParticles()
			
func onPlayerPhaseStart() -> void:
	for SpawnParticle in SpawnParticles.get_children(): SpawnParticle.queue_free()

const SPAWN_PARTICLE_OFFSET: float = 0.3
func onCreateSpawnParticle(Tile: TileGD) -> void:
	var SpawnParticle: GPUParticles3D = preload("res://scenes/screens/level_map/utility_nodes/vfx/spawn_particle/spawn_particle.tscn").instantiate()
	SpawnParticles.add_child(SpawnParticle)
	SpawnParticle.position = Tile.position
	SpawnParticle.position.y += SPAWN_PARTICLE_OFFSET
	SpawnParticle.Tile = Tile

func onRemoveSpawnParticle(Tile: TileGD) -> void:
	for SpawnParticle in SpawnParticles.get_children():
		if SpawnParticle.Tile == Tile: 
			SpawnParticle.queue_free()
			break

const PARTICLE_VFX_MATERIALS: Dictionary = {
	"health": preload("res://scenes/screens/level_map/utility_nodes/vfx/stat_particles/stat_materials/health_material.tres"),
	"heal": preload("res://scenes/screens/level_map/utility_nodes/vfx/stat_particles/stat_materials/heal_material.tres"),
	"attack": preload("res://scenes/screens/level_map/utility_nodes/vfx/stat_particles/stat_materials/attack_material.tres"),
	"speed": preload("res://scenes/screens/level_map/utility_nodes/vfx/stat_particles/stat_materials/speed_material.tres"),
}
	
@onready var StatParticles: Node3D = %StatParticles
func onCreateStatParticle(stat: int, type: String, Tile: TileGD, y_offset: float) -> void:
	var StatParticle := preload("res://scenes/screens/level_map/utility_nodes/vfx/stat_particles/stat_particle.tscn").instantiate()
	var i: int = 1
	for mesh in (["+" if stat > 0 else "-"] + [stat]).map(func(x: Variant):\
	return load("res://scenes/screens/level_map/utility_nodes/vfx/stat_particles/stat_particle/"\
	+ Helper.onStatParticleStrNum(abs(x) if typeof(x) == TYPE_INT else x) + ".tres").duplicate()):
		mesh.surface_set_material(0, PARTICLE_VFX_MATERIALS[type])
		StatParticle["draw_pass_" + str(i)] = mesh
		
		i+= 1
		
	add_child(StatParticle)
	StatParticle.SpectateCamera = SpectateCamera
	StatParticle.emitting = true
	StatParticle.position = Tiles.getUnitPositionOnTile(Tile)
	StatParticle.position.y += y_offset

var unit_vfx_keeper: Dictionary = {}
func onCreateUnitVFXKeeper() -> void:
	const DIR_PATH: String = "res://scenes/screens/level_map/utility_nodes/vfx/unit_vfx/unit_vfx/"
	for file in Array(DirAccess.get_files_at(DIR_PATH))\
	.filter(func(x: String): return x.ends_with(".tres")):
		var vfx_gd: UnitVFXGD = load(DIR_PATH + file)
		unit_vfx_keeper[vfx_gd.name] = vfx_gd

func onCreateUnitVFX(Unit: UnitGD, type: String, set_info_args: Array = []) -> Node3D:
	var vfx_gd: UnitVFXGD = unit_vfx_keeper[type]
	var unit_vfx: Node3D = vfx_gd.model.instantiate()
	
	if vfx_gd.is_height_absolute: unit_vfx.position.y = vfx_gd.height
	else: unit_vfx.position.y = Unit.height.stat + vfx_gd.height
	unit_vfx.type = vfx_gd.name
	
	Unit.UnitVFX.add_child(unit_vfx)
	if set_info_args.size() > 0 and unit_vfx.has_method("setInfo"):
		unit_vfx.callv("setInfo", set_info_args)
	return unit_vfx
	
func onUnitVFXExists(Unit: UnitGD, type: String):
	return Unit.UnitVFX.get_children().any(func(x: Node3D): return type == x.type)
	
func onRemoveUnitVFX(Unit: UnitGD, type: String) -> void:
	for child in Unit.UnitVFX.get_children().filter(func(x: Node3D): return x.type == type): child.queue_free()

func onCreateCocusPocus(Unit: UnitGD, _Unit: UnitGD) -> void:
	var previous_cocus: Array = onFindVFX(Unit, "CocusPocus")
	if previous_cocus.size() == 0:
		onCreateUnitVFX(Unit, "CocusPocus", [Vision, _Unit])
	else:
		previous_cocus[0].cocus_count += 1
		previous_cocus[0].units.append(_Unit)

func onFindVFX(Unit: UnitGD, type: String) -> Array:
	return Unit.UnitVFX.get_children().filter(func(x: Node3D): return x.type == type)

func onVisibleCocusPocus(Unit: UnitGD) -> void:
	for child in onFindVFX(Unit, "CocusPocus"):
		child.setVisible()

func onRemoveCocusPocus(Unit: UnitGD, _Unit: UnitGD) -> void:
	for child in onFindVFX(Unit, "CocusPocus"):
		child.cocus_count -= 1
		child.units.append(_Unit)
		if child.cocus_count == 0: child.queue_free()
		else: child.setVisible()

func onUpscaleCocusPocus(Unit: UnitGD, upscale: Vector3, duration: float, unit_size: float, delay_duration: float, callable: Callable) -> void:
	for child in Unit.UnitVFX.get_children():
		if child.type == "CocusPocus":
			var ScaleTween := create_tween()
			ScaleTween.tween_property(child, "scale", upscale, duration)
			
			var PosTween := create_tween()
			PosTween.tween_property(child, "position:y", 0, duration)
			
			var ScaleUnitTween := create_tween()
			ScaleUnitTween.tween_property(Unit.Model, "scale:y", unit_size, duration)
			ScaleUnitTween.finished.connect(func(): await get_tree().create_timer(delay_duration).timeout; callable.call())
			return

func onDownscaleCocusPocus(Unit: UnitGD, duration: float, callable: Callable) -> void:
	for child in Unit.UnitVFX.get_children():
		if child.type == "CocusPocus":
			var ScaleTween := create_tween()
			ScaleTween.tween_property(child, "scale", Vector3(0.001, 0.001, 0.001), duration)
			
			var PosTween := create_tween()
			PosTween.tween_property(child, "position:y", Unit.height.stat + 0.85, duration)
			
			var ScaleUnitTween := create_tween()
			ScaleUnitTween.tween_property(Unit.Model, "scale:y", 1, duration)
			ScaleUnitTween.finished.connect(callable)
			return

func onUpdateVFXVision(Unit: UnitGD, _state: bool) -> void:
	if Unit.base_card.id == 22:
		for _Unit in Units.on_units(TeamRelationGD.new(1)):
			for VFX in _Unit.UnitVFX.get_children():
				if VFX.type == "CocusPocus":
					VFX.setVisible()

func onUpdateMoveState(Unit: UnitGD) -> void:
	if onUnitVFXExists(Unit, "MoveState"):
		onRemoveUnitVFX(Unit, "MoveState")
	else: onCreateUnitVFX(Unit, "MoveState", [Unit.ai_info])

func onUpdateAiStats(Unit: UnitGD) -> void:
	if onUnitVFXExists(Unit, "AIStats"):
		onRemoveUnitVFX(Unit, "AIStats")
	else:
		var unit_vfx: Node3D = onCreateUnitVFX(Unit, "AIStats", [Unit, SpectateCamera.Camera])
		Unit.update_ai_stat.connect(unit_vfx.setAIStats)
