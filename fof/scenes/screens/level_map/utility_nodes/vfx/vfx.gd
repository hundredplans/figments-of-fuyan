class_name VFXGD
extends Node3D

@onready var SpawnParticles: Node3D = %SpawnParticles
var Tiles: TilesGD
var Units: UnitsGD
var SpectateCamera: SpectateCameraGD
var Vision: VisionGD

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

func onCreateAbilityActiveParticle(Unit: UnitGD) -> void:
	var AbilityActiveParticle: GPUParticles3D = preload("res://scenes/screens/level_map/utility_nodes/vfx/ability_active/ability_active_particle.tscn").instantiate()
	Unit.UnitVFX.add_child(AbilityActiveParticle)
	AbilityActiveParticle.type = "AbilityActive"

func onRemoveAbilityActiveParticle(Unit: UnitGD) -> void:
	if Unit != null:
		for child in Unit.UnitVFX.get_children():
			if child.type == "AbilityActive":
				child.queue_free()

func onCreateStaggerVFX(Unit: UnitGD) -> void:
	var StaggerVFX: Node3D = preload("res://scenes/screens/level_map/utility_nodes/vfx/status_effects/stagger/stagger_status_effect.tscn").instantiate()
	Unit.UnitVFX.add_child(StaggerVFX)
	StaggerVFX.type = "Stagger"
	StaggerVFX.position.y = Unit.height.stat + 0.1
	
func onRemoveStaggerVFX(Unit: UnitGD) -> void:
	for child in Unit.UnitVFX.get_children():
		if child.type == "Stagger":
			child.queue_free()

func onCreateDazeVFX(Unit: UnitGD) -> void:
	var DazeVFX: Node3D = preload("res://scenes/screens/level_map/utility_nodes/vfx/status_effects/daze/daze_status_effect.tscn").instantiate()
	Unit.UnitVFX.add_child(DazeVFX)
	DazeVFX.type = "Daze"
	DazeVFX.position.y = Unit.height.stat + 0.1
	
func onRemoveDazeVFX(Unit: UnitGD) -> void:
	for child in Unit.UnitVFX.get_children():
		if child.type == "Daze":
			child.queue_free()

func onCreateHelpfulHelmet(Unit: UnitGD) -> void:
	var HelpfulHelmet: Node3D = preload("res://scenes/screens/level_map/utility_nodes/vfx/ability_effects/helpful_helmet/helpfulhelmet.tscn").instantiate()
	Unit.UnitVFX.add_child(HelpfulHelmet)
	HelpfulHelmet.type = "HelpfulHelmet"
	HelpfulHelmet.position.y = Unit.height.stat + 0.1

func onCreateCocusPocus(Unit: UnitGD, _Unit: UnitGD) -> void:
	var CocusPocus: Node3D = preload("res://scenes/screens/level_map/utility_nodes/vfx/ability_effects/cocus_pocus/cocus_pocus.tscn").instantiate()
	var previous_cocus: Array = Unit.UnitVFX.get_children().filter(func(x: Node3D): return x.type == "CocusPocus")
	if previous_cocus.size() == 0:
		Unit.UnitVFX.add_child(CocusPocus)
		CocusPocus.Vision = Vision
		CocusPocus.type = "CocusPocus"
		CocusPocus.units.append(_Unit)
		CocusPocus.position.y = Unit.height.stat + 0.85
		CocusPocus.cocus_count = 1
		CocusPocus.setVisible()
	else: previous_cocus[0].cocus_count += 1; CocusPocus.units.append(_Unit)

func onFindVFX(Unit: UnitGD, type: String) -> Array:
	return Unit.UnitVFX.get_children().filter(func(x: Node3D): return x.type == type)

func onVisibleCocusPocus(Unit: UnitGD) -> void:
	for child in onFindVFX(Unit, "CocusPocus"):
		child.setVisible()

func onRemoveCocusPocus(Unit: UnitGD, _Unit: UnitGD) -> void:
	for child in Unit.UnitVFX.get_children():
		if child.type == "CocusPocus":
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
