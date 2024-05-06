class_name VFXGD
extends Node3D

@onready var SpawnParticles: Node3D = %SpawnParticles
var Tiles: TilesGD
var Units: UnitsGD
var SpectateCamera: Node3D

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
	var stat_string: String = str(abs(stat))
	var stat_array: Array = []
	
	for c in stat_string: stat_array.append(int(c))
	
	var i: int = 1
	for mesh in (["+" if stat > 0 else "-"] + stat_array).map(func(x: Variant):\
	return load("res://scenes/screens/level_map/utility_nodes/vfx/stat_particles/stat_particle/"\
	+ Helper.NUM_TO_STRING_NUM[x] + ".tres").duplicate()):
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
	AbilityActiveParticle.lifetime = Unit.height.top / 8

func onRemoveAbilityActiveParticle(Unit: UnitGD) -> void:
	if Unit != null:
		for child in Unit.UnitVFX.get_children():
			if child.type == "AbilityActive":
				child.queue_free()

func onCreateStaggerVFX(Unit: UnitGD) -> void:
	pass
	
func onRemoveStaggerVFX(Unit: UnitGD) -> void:
	pass
