extends Control

signal mouse_in_ui
@onready var CommandList: Container = %CommandList
@onready var CommandLineEdit: LineEdit = %CommandLineEdit
var commands: Array
var SpectateObject: GameObjectGD

func _ready() -> void:
	const DIR_PATH: String = "res://resources/game/commands/"
	commands = Array(DirAccess.get_files_at(DIR_PATH)).map(func(x: String): return load(DIR_PATH + x))
	for command in commands:
		var label := Label.new()
		CommandList.add_child(label)
		label.text = command.name + " " + command.placeholder

func _on_line_edit_text_submitted(new_text: String) -> void:
	CommandLineEdit.release_focus()
	var args: Array = new_text.split(" ")
	if !args.is_empty():
		var command_name: String = args[0]
		var command: Command = onFindCommandByName(command_name)
		if command != null:
			args.remove_at(0)
			
			for arg in args:
				if arg.is_valid_int(): arg = int(arg)
			
			callv(command_name, args)

func onFindCommandByName(command_name: String) -> Command:
	for command in commands:
		if command.name == command_name: return command
	return null

func status_effect(name_id: Variant, turns: int = 1) -> void:
	if SpectateObject is CardGD:
		var id: int = name_id if name_id is int else 0
		if name_id is String:
			for status_effect in Helper.fof_info_dict[StatusEffectInfo]:
				if status_effect.name == name_id: id = status_effect.id; break
			
		if id != 0:
			SpectateObject.onCreateBaseStatusEffect(name_id, turns)

func onCameraUpdated(_SpectateObject: GameObjectGD = null) -> void:
	SpectateObject = _SpectateObject

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Console"): visible = !visible
	
func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
