extends Control

signal mouse_in_ui
@onready var CommandList: Container = %CommandList
@onready var CommandLineEdit: LineEdit = %CommandLineEdit
@onready var HistoryLabel: Label = %HistoryLabel
var commands: Array
var SpectateObject: GameObjectGD
var level: LevelGD # For pushing actions

func _ready() -> void:
	const DIR_PATH: String = "res://resources/game/commands/"
	commands = Array(DirAccess.get_files_at(DIR_PATH)).map(func(x: String): return load(DIR_PATH + x))
	for command in commands:
		var label := Label.new()
		CommandList.add_child(label)
		label.text = command.name + " " + command.placeholder

func _on_line_edit_text_submitted(new_text: String) -> void:
	var args: Array = new_text.split(" ")
	if !args.is_empty():
		var command_name: String = args[0]
		var command: Command = onFindCommandByName(command_name)
		if command != null:
			args.remove_at(0)
			
			for i in range(args.size()):
				if args[i].is_valid_int(): args[i] = int(args[i])
				elif args[i].to_lower() in ["t", "true"]: args[i] = true
				elif args[i].to_lower() in ["f", "false"]: args[i] = false
			
			callv(command_name, args)
			HistoryLabel.text += CommandLineEdit.text + "\n"
			CommandLineEdit.text = ""

func onFindCommandByName(command_name: String) -> Command:
	for command in commands:
		if command.name == command_name: return command
	return null

func status_effect(name_id: Variant, turns: int = 1) -> void:
	if SpectateObject is CardGD:
		var info: StatusEffectInfo = getNameIDFofInfo(name_id, StatusEffectInfo)
		if info != null:
			SpectateObject.onCreateBaseStatusEffect(info.id, turns)

func damage(damage: int) -> void:
	if SpectateObject is CardGD:
		SpectateObject.onPushAction(DamageAction.new(SpectateObject, SpectateObject, damage))

func tool(name_id: Variant, ascended: bool = false) -> void:
	if SpectateObject is CardGD:
		var info: ToolInfo = getNameIDFofInfo(name_id, ToolInfo)
		if info != null:
			level.onPushAction(\
			AddToolAction.new(SpectateObject, SavedData.onLoadModel(info.saved_data.new(info.id, true, 0, ascended), SpectateObject)))

func addboon(name_id: Variant, ascended: bool = false) -> void:
	var info: BoonInfo = getNameIDFofInfo(name_id, BoonInfo)
	level.onPushAction(AddBoonAction.new(info.id, ascended))

func removeboon(name_id: Variant) -> void:
	var info: BoonInfo = getNameIDFofInfo(name_id, BoonInfo)
	level.onPushAction(RemoveBoonAction.new(info.id))

func getNameIDFofInfo(name_id: Variant, type: GDScript) -> FofInfo:
	var id: int = name_id if name_id is int else 0
	if name_id is String:
		for fof_info in Helper.fof_info_dict[type].values():
			if fof_info.name.to_lower() == name_id: return fof_info
		
	if id != 0: return Helper.getFofInfoID(type, id)
	return null
			
func onCameraUpdated(_SpectateObject: GameObjectGD = null) -> void:
	SpectateObject = _SpectateObject

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Console"):
		visible = !visible
		if visible:
			CommandLineEdit.grab_focus()
			CommandLineEdit.editable = false
			await get_tree().create_timer(0.02).timeout
			CommandLineEdit.editable = true
		
	
func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
