extends Node3D

signal mesh_pressed
var ActiveMesh: MeshInstance3D

@export var gate: MeshToMaterial
@export var settings_door: MeshToMaterial
@export var play_table: MeshToMaterial

@onready var outlines: Array[MeshToMaterial] = [gate, settings_door, play_table]

func _ready() -> void:
	for child in get_children().filter(func(x: MeshInstance3D): return x.get_child_count() > 0):
		var StaticBody: StaticBody3D = child.get_child(0)
		StaticBody.mouse_entered.connect(onMouseEntered.bind(child))
		StaticBody.mouse_exited.connect(onMouseExited)

func onFindMeshToMaterial(mesh: MeshInstance3D) -> Material:
	for outline in outlines:
		if get_path_to(mesh) == outline.mesh: return outline.material
	return null

func onMouseEntered(mesh: MeshInstance3D) -> void:
	mesh.set_surface_override_material(0, onFindMeshToMaterial(mesh))
	ActiveMesh = mesh

func onMouseExited() -> void:
	ActiveMesh.set_surface_override_material(0, null)
	ActiveMesh = null

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("MainInput") and ActiveMesh:
		mesh_pressed.emit(ActiveMesh.name)
