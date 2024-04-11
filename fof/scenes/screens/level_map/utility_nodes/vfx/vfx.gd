class_name VFXGD
extends Node3D

@onready var SpawnParticles: Node3D = %SpawnParticles
var Tiles: TilesGD
var Units: UnitsGD

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
		
