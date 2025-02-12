extends Node3D

signal mouse_in_mesh

#region Exports
@export var main_menu_meshes: Array[MeshToMaterial]
@export var play_table_meshes: Array[MeshToMaterial]
@export var camera_item_array: Array[CameraItem]

@export var GREYSCALE_MATERIAL: ShaderMaterial
#endregion

#region Base Functions

func _ready() -> void:
	for body in getStaticBodies(main_menu_meshes): body.input_ray_pickable = true
	for body in getStaticBodies(play_table_meshes): body.input_ray_pickable = false
	
	var save_file_count: int = Helper.getSaveFileCount()
	for mesh in getMeshes(main_menu_meshes + play_table_meshes):
		if !onDisableMesh(mesh, save_file_count):
			var StaticBody: StaticBody3D = mesh.get_child(0)
			StaticBody.mouse_entered.connect(onMouseEnteredMesh.bind(mesh))
			StaticBody.mouse_exited.connect(onMouseExitedMesh)
		
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("MainInput") and !mouse_in_ui:
		if ActiveMesh: mesh_chosen.emit(CameraItem.getCameraItemInArray(camera_item_array, ActiveMesh.name))
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
	if mouse_in_ui: return
	if mesh != null:
		mesh.set_surface_override_material(0, onFindMeshToMaterial(mesh, main_menu_meshes + play_table_meshes))
	
	mouse_in_mesh.emit(mesh, true)
	ActiveMesh = mesh

func onMouseExitedMesh() -> void:
	if mouse_in_ui: return
	if ActiveMesh != null:
		ActiveMesh.set_surface_override_material(0, null)
		
	mouse_in_mesh.emit(ActiveMesh, false)
	ActiveMesh = null
	
func onDisableMesh(mesh: MeshInstance3D, save_file_count: int) -> bool:
	if (mesh.name in ["Continue", "LoadGame"] and save_file_count == 0)\
	or (mesh.name == "NewGame" and save_file_count >= 5):
		mesh.set_surface_override_material(0, GREYSCALE_MATERIAL)
		return true
	return false
#endregion

#region NewGame
func onNewGameHideFrame(state: bool) -> void:
	for mesh in getMeshes(play_table_meshes): mesh.visible = !state
#endregion

#region Travel
func onTravelStateChanged(travel_info: CameraTravelDatastore) -> void:
	for body in getStaticBodies(main_menu_meshes):
		body.input_ray_pickable = travel_info.end.name == "MainMenu" and !travel_info.is_start

	for body in getStaticBodies(play_table_meshes):
		body.input_ray_pickable = travel_info.end.name == "PlayTable" and !travel_info.is_start
#endregion

#region Mouse In UI
func getMouseInUI() -> bool:
	return mouse_in_ui
	
var mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	onMouseExitedMesh()
	mouse_in_ui = state
#endregion

#region Remove Save
func onRemoveSave() -> void:
	var save_file_count: int = Helper.getSaveFileCount()
	for mesh in getMeshes(play_table_meshes):
		onDisableMesh(mesh, save_file_count)
#endregion
