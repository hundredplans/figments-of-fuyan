extends PanelContainer

signal mouse_in_ui
@onready var SpawnIDEdit: LineEdit = %SpawnIDEdit

var Spawn: SpawnGD
func setInfo(_Spawn: SpawnGD) -> void:
	Spawn = _Spawn
	SpawnIDEdit.text = str(Spawn.spawn_id)
	position = get_viewport().get_mouse_position() + (size / 2)

func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)


func _on_spawn_id_edit_text_changed(new_text: String) -> void:
	if new_text.is_valid_int() and int(new_text) > 0:
		Spawn.spawn_id = int(new_text)
