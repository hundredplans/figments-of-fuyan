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
		
func onCreateOneShot(type: String, Tile: TileGD, y_offset: float = 0) -> void:
	var Particle: GPUParticles3D
	match type:
		"Heal": Particle = preload("res://scenes/screens/level_map/utility_nodes/vfx/heal_particle/heal_particle.tscn").instantiate()
	Particle.SpectateCamera = SpectateCamera
	#Oneshot.add_child(Particle)
	
	Particle.emitting = true
	Particle.position = Tiles.getUnitPositionOnTile(Tile)
	Particle.position.y += y_offset

const PARTICLE_VFX_MATERIALS: Dictionary = {
	"health": preload("res://scenes/screens/level_map/utility_nodes/vfx/stat_particles/stat_materials/health_material.tres"),
	"heal": preload("res://scenes/screens/level_map/utility_nodes/vfx/stat_particles/stat_materials/heal_material.tres"),
	"attack": preload("res://scenes/screens/level_map/utility_nodes/vfx/stat_particles/stat_materials/attack_material.tres"),
	"speed": preload("res://scenes/screens/level_map/utility_nodes/vfx/stat_particles/stat_materials/speed_material.tres"),
}
	
func _ready():
	onCreateStatParticle(1, "health", null)
	
func onCreateStatParticle(stat: int, type: String, Tile: TileGD) -> void:
	var StatParticle := preload("res://scenes/screens/level_map/utility_nodes/vfx/stat_particles/stat_particle.tscn").instantiate()
	
	
	var stat_string: String = str(abs(stat))
	var stat_array: Array = []
	var mesh := onCreateSurfaceArray()
	mesh.surface_set_material(0, PARTICLE_VFX_MATERIALS[type])
	for char in stat_string: stat_array.append(int(char))
	
	for _mesh in (["+" if stat > 0 else "-"] + stat_array).map(func(x: Variant):\
		return load("res://scenes/screens/level_map/utility_nodes/vfx/stat_particles/stat_particle/"\
		+ Helper.NUM_TO_STRING_NUM[x] + ".tres")):
			print(_mesh)
		

	StatParticle.emitting = true
	#StatParticle.position = Tiles.getUnitPositionOnTile(Tile)

func onCreateSurfaceArray() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var surface_array: Array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	return mesh
