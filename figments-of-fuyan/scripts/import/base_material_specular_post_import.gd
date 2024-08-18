@tool
extends EditorScenePostImport

func _post_import(scene: Node) -> Node:
	var base_material: ShaderMaterial = preload("res://resources/materials/game/base_material_specular.tres")
	for child in getChildrenRecursive(scene):
		if child is MeshInstance3D: child.mesh.surface_set_material(0, base_material)
	return scene
	
func getChildrenRecursive(node: Node, children := []):
	children.append(node)
	for child in node.get_children():
		children = getChildrenRecursive(child, children)
	return children
