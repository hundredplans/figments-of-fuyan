class_name VFXGD
extends Node3D

@onready var Oneshot: Node3D = %Oneshot
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
	Oneshot.add_child(Particle)
	
	Particle.emitting = true
	Particle.position = Tiles.getUnitPositionOnTile(Tile)
	Particle.position.y += y_offset
	
	
