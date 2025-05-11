extends Node3D

@onready var Tiles: Node3D = %Tiles

func _ready() -> void:
	for Tile: Node3D in Tiles.get_children():
		var mesh_inst: MeshInstance3D = Tile.get_node("TopMeshInstance3D")
		var random_offset := Vector2(randf(), randf())
		var mat: ShaderMaterial = mesh_inst.get_surface_override_material(0)
		mesh_inst.set_instance_shader_parameter("uv_offset", random_offset)
