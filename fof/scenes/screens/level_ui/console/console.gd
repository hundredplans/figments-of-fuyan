extends Control

var VFX: VFXGD
var Combat: CombatGD
var LevelUI: LevelUIGD
var Units: UnitsGD
var Tiles: TilesGD
var PlayerManager: PlayerManagerGD
var LevelMap: LevelMapGD
var Hand: HandGD
var Deck: DeckGD
var SpectateCamera: SpectateCameraGD

@onready var CommandLine: LineEdit = %CommandLine
@onready var PastCommandsLabel: Label = %PastCommandsLabel
@onready var DisplayCommands: VBoxContainer = %DisplayCommands

var active_command: CommandGD
var command_args: Array = []
var last_commands: Array = []
var command_keeper: Dictionary = {}

func _ready() -> void:
	onCreateCommandKeeper()
	onCreateDisplayCommands()
	var dev := preload("res://static/dev/dev.tres")
	move_state_state = dev.move_states_visible
	ai_stats_state = dev.ai_stats_visible
	
func onCreateDisplayCommands() -> void:
	for command in command_keeper.values():
		var label := preload("res://scenes/screens/level_ui/console/display_command_label.tscn").instantiate()
		label.get_node("Label").text = command.name + " "
		label.get_node("Placeholder").text = command.placeholder
		DisplayCommands.add_child(label)
	
func onCreateCommandKeeper() -> void:
	const DIR_PATH: String = "res://scenes/screens/level_ui/console/commands/"
	for file in Array(DirAccess.get_files_at(DIR_PATH))\
	.filter(func(x: String): return x.ends_with(".tres")):
		var command_gd: CommandGD = load(DIR_PATH + file)
		command_keeper[command_gd.name] = command_gd
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Console"):
		onConsolePressed()
func onConsolePressed() -> void:
	visible = !visible
	if visible: CommandLine.call_deferred("grab_focus")
func _on_command_line_text_submitted(command: String):
	CommandLine.release_focus()
	last_commands.append({"text": command, "ttpos": null})
	onProcessCommand(command)
	PastCommandsLabel.text += command + "\n"
	
func onProcessCommand(command: String) -> void:
	var command_gd: CommandGD = command_keeper[command.get_slice(" ", 0)]
	command_args = command.split(" ")
	command_args.remove_at(0)
	active_command = command_gd
	
	if command_gd.unit_command: LevelUI.onSelectTileConsoleMode(); visible = false
	else: onCommandSelected(command_gd)
func onTileSelected(Tile: TileGD) -> void:
	command_args.push_front(Tile)
	last_commands[last_commands.size() - 1].ttpos = Tile.onTTpos()
	onCommandSelected(active_command)
	
func onCommandSelected(command: CommandGD) -> void:
	callv("on" + command.name.capitalize(), command_args.map(onTransformArg))

func onTransformArg(x: Variant) -> Variant:
	if typeof(x) == TYPE_STRING and x.is_valid_int():
		return int(x)
	return x
	
func onPhase() -> void:
	LevelMap.on_advance_game_phase()
	
func onHand() -> void:
	var card_options: Array = range(7, 25)
	for i in range(Hand.get_children().size()):
		Hand.get_child(i).queue_free()
		LevelUI.CardBox.get_child(i).queue_free()
		
	for i in range(3):
		var deck_card: DeckCardGD = Deck.on_create_card(card_options[randi() % card_options.size()], 0, [])
		Deck.on_force_draw_card(deck_card)
	
func onFatigue(Tile: TileGD):
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	PlayerManager.passed_turns.erase(Unit)
	PlayerManager.onSelectActiveUnit(Unit)
	
func onSpawn(Tile: TileGD, id: int, team: int) -> void:
	await Units.onUnitAwakened(id, 0, [], team, 0, Tile)
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	PlayerManager.passed_turns.erase(Unit)
	PlayerManager.onSelectActiveUnit(Unit)
	
func onStagger(Tile: TileGD):
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	var AppliedBy := AppliedByGD.new("Console")
	Combat.onStagger(Unit, AppliedBy)

func onDraw(id: int) -> void:
	var deck_card := DeckCardGD.new()
	deck_card.on_create_card(id, 0, [])
	Deck.on_force_draw_card(deck_card)

func onDamage(Tile: TileGD, damage: int) -> void:
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	var AppliedBy := AppliedByGD.new("Ability")
	Combat.onDMG(Unit, AppliedBy, damage)
	
func onAistats() -> void:
	ai_stats_state = !ai_stats_state
	for Unit in Units.on_units(TeamRelationGD.new(1)):
		VFX.onUpdateAiStats(Unit)
	
var ai_stats_state: bool = false
var move_state_state: bool = false
func onMoveStates() -> void:
	move_state_state = !move_state_state
	for Unit in Units.on_units(TeamRelationGD.new(1)):
		VFX.onUpdateMoveState(Unit)
		
func onHeal(Tile: TileGD, heal: int) -> void:
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	Combat.onHeal(HealInfoGD.new(Unit, AppliedByGD.new("Ability"), heal))

func onStat(Tile: TileGD, type: String, value: int) -> void:
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	Combat.onBuffInfo(BuffInfoGD.new(Unit, AppliedByGD.new("Console"), type, value))

@onready var PlaceholderLabel: Label = %PlaceholderLabel
func _on_command_line_text_changed(text: String):
	if text.is_empty(): PlaceholderLabel.text = ""; return
	for command_name in command_keeper:
		if command_name.begins_with(text):
			PlaceholderLabel.text = command_name + " " + command_keeper[command_name].placeholder
			return
	PlaceholderLabel.text = ""

func _on_copy_button_pressed():
	var commands := preload("res://static/dev/commands.tres")
	commands.last_commands = last_commands
	ResourceSaver.save(commands)

func _on_paste_button_pressed():
	var commands := preload("res://static/dev/commands.tres")
	for command in commands.last_commands:
		_on_command_line_text_submitted(command.text)
		if command.ttpos != null:
			var Tile: TileGD = Tiles.position_to_tile(command.ttpos)
			LevelUI.onSelectTileFinish(Tile)
