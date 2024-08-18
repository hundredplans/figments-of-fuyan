extends Node3D

#region Exports
@export var main_menu_meshes: Array[MeshToMaterial]
@export var play_table_meshes: Array[MeshToMaterial]
#endregion

#region Base Functions
func _ready() -> void:
	_on_main_menu_world_end_travel()
	for mesh in getMeshes(main_menu_meshes + play_table_meshes):
		var StaticBody: StaticBody3D = mesh.get_child(0)
		StaticBody.mouse_entered.connect(onMouseEnteredMesh.bind(mesh))
		StaticBody.mouse_exited.connect(onMouseExitedMesh)
		
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("MainInput"):
		if ActiveMesh: mesh_chosen.emit(ActiveMesh.name)
#endregion

#region Helper Functions
func onFindMeshToMaterial(mesh: MeshInstance3D, arr: Array[MeshToMaterial]) -> Material:
	for mesh_material in arr:
		if get_path_to(mesh) == mesh_material.mesh: return mesh_material.material
	return null
	
func getMeshes(arr: Array) -> Array:
	return arr.map(func(x: MeshToMaterial): return get_node(x.mesh))
	
func getStaticBodies(arr: Array) -> Array:
	return getMeshes(arr).map(func(x: MeshInstance3D): return x.get_child(0))
#endregion

#region Mouse Mesh
signal mesh_chosen
var ActiveMesh: MeshInstance3D
func onMouseEnteredMesh(mesh: MeshInstance3D) -> void:
	if mesh != null:
		mesh.set_surface_override_material(0, onFindMeshToMaterial(mesh, main_menu_meshes + play_table_meshes))
	ActiveMesh = mesh

func onMouseExitedMesh() -> void:
	if ActiveMesh != null:
		ActiveMesh.set_surface_override_material(0, null)
	ActiveMesh = null
#endregion

#region NewGame
func onNewGameHideFrame(state: bool) -> void:
	for mesh in getMeshes(play_table_meshes): mesh.visible = !state
#endregion

#region Travel
func _on_main_menu_world_begin_travel(__: String, ___: bool) -> void:
	for body in getStaticBodies(main_menu_meshes + play_table_meshes): body.input_ray_pickable = false

func _on_main_menu_world_end_travel(mesh_name: String = "", is_exit: bool = true) -> void:
	for body in getStaticBodies(main_menu_meshes):
		body.input_ray_pickable = is_exit and !mesh_name == "NewGame"
	
	for body in getStaticBodies(play_table_meshes):
		body.input_ray_pickable = (!is_exit and mesh_name == "PlayTable") or (is_exit and mesh_name == "NewGame")
#endregion
