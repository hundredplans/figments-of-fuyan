@tool
extends EditorScenePostImport

func _post_import(scene):
	apply_import_settings(scene)
	return scene
	
func apply_import_settings(scene):
	var _aniplayer: AnimationPlayer = scene.get_node("AnimationPlayer")
	_aniplayer.set_default_blend_time(0.3)
	for animation_name in ["Walk", "Idle"]:
		_aniplayer.get_animation(animation_name).set_loop_mode(1)
	
