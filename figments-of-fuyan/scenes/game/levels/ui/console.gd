extends Control

signal mouse_in_ui
@onready var CommandList: Container = %CommandList
@onready var CommandLineEdit: LineEdit = %CommandLineEdit
@onready var HistoryLabel: Label = %HistoryLabel

var past_index: int = 0
var past_commands: Array[String] = []
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
			past_commands.append(CommandLineEdit.text)
			past_index += 1
			HistoryLabel.text += CommandLineEdit.text + "\n"
			CommandLineEdit.text = ""

func onFindCommandByName(command_name: String) -> Command:
	for command in commands:
		if command.name == command_name: return command
	return null

func see() -> void:
	var game_objects: Array = get_tree().get_nodes_in_group("LevelTileObjectsGD") + get_tree().get_nodes_in_group("FieldCardsGD")
	Helper.admin_datastore.see = !Helper.admin_datastore.see
	
	for GameObject in game_objects:
		GameObject.onUpdateLevelVisible()

func tier(value: int) -> void:
	if SpectateObject is CardGD:
		SpectateObject.onRetiered(value)

func status_effect(name_id: Variant, turns: int = 1) -> void:
	if SpectateObject is CardGD:
		var info: StatusEffectInfo = getNameIDFofInfo(name_id, StatusEffectInfo)
		if info != null:
			SpectateObject.onCreateBaseStatusEffect(info.id, turns)

func world(difficulty: int) -> void:
	Game.getSaveFile().onPushAction(AreaFinishedAction.new(difficulty))
	
func deckcard(name_id: Variant, _tier: int = 1) -> void:
	var card_info: CardInfo = getNameIDFofInfo(name_id, CardInfo)
	var card_data: SavedDataCard = card_info.saved_data.new(card_info.id, true)
	card_data.tier = _tier
	Game.setCardDataFromInfo(card_data, card_info)
	
	var Card: CardGD = SavedData.onLoadModel(card_data, Game.getSaveFile())
	Game.getArea().onPushAction(AddToDeckAction.new(Card))

func damage(damage_dealt: int) -> void:
	if SpectateObject is CardGD:
		SpectateObject.onPushAction(DamageAction.new(SpectateObject, SpectateObject, damage_dealt))

func tool(name_id: Variant, _tier: int = 1) -> void:
	var ToolCard: CardGD = SpectateObject if SpectateObject != null and SpectateObject is CardGD else\
		Game.getSaveFile().getChampionCard()
		
	if name_id is int and name_id == 0: # Remove tool if id is 0
		Game.getArea().onPushAction(RemoveToolAction.new(ToolCard))
		return
		
	var info: ToolInfo = getNameIDFofInfo(name_id, ToolInfo)
	if info != null:
		var Tool: ToolGD = SavedData.onLoadModel(info.saved_data.new(info.id, true, 0), ToolCard)
		Tool.tier = _tier
		Game.getArea().onPushAction(AddToolAction.new(ToolCard, Tool))

func stat(type: Game.Stats, value: int) -> void:
	if SpectateObject is CardGD:
		Game.getLevel().onPushAction(StatAction.new(StatInfo.new(SpectateObject, type, value)))

func knockback(amount: int, direction: int) -> void:
	if SpectateObject is CardGD:
		Game.getLevel().onPushAction(KnockbackStartAction.new(SpectateObject, null, amount, direction))

func endgame(win_state: bool) -> void:
	Game.getArea().onPushAction(EndGameAction.new(int(win_state), true))

func shillings(delta: int) -> void:
	Game.getArea().onPushAction(ChangeShillingsAction.new(delta))

func addboon(name_id: Variant, _tier: int = 1) -> void:
	var info: BoonInfo = getNameIDFofInfo(name_id, BoonInfo)
	Game.getArea().onPushAction(AddBoonAction.new(info.id, _tier))

func insert(name_id: Variant, _tier: int = 1) -> void:
	var card_info: CardInfo = getNameIDFofInfo(name_id, CardInfo)
	var card_data: SavedDataCard = card_info.saved_data.new(card_info.id, true)
	card_data.tier = _tier
	Game.setCardDataFromInfo(card_data, card_info)
	var Card: CardGD = SavedData.onLoadModel(card_data, level)
	Game.getArea().onPushAction(InsertAction.new(Card))
	
func brain(state: bool) -> void:
	Game.brain = state

func energy(delta: int) -> void:
	Game.getArea().onPushAction(EnergyAction.new(delta))

func removeboon(name_id: Variant) -> void:
	var info: BoonInfo = getNameIDFofInfo(name_id, BoonInfo)
	Game.getArea().onPushAction(RemoveBoonAction.new(info.id))

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
			await get_tree().process_frame
			CommandLineEdit.grab_focus()
	elif Input.is_action_just_pressed("UpArrow") and CommandLineEdit.has_focus():
		onChangeToPastCommand(-1)
	elif Input.is_action_just_pressed("DownArrow") and CommandLineEdit.has_focus():
		onChangeToPastCommand(1)
		
func onChangeToPastCommand(direction: int) -> void:
	if past_commands.is_empty(): return
	past_index = clamp(past_index + direction, 0, past_commands.size())
	CommandLineEdit.text = past_commands[past_index] if past_index != past_commands.size() else ""

func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
