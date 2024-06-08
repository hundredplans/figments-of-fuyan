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

var command_keeper: Dictionary = {}
func _ready() -> void:
	onCreateCommandKeeper()
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
	last_commands.append([command])
	onProcessCommand(command)
	PastCommandsLabel.text += command + "\n"

func onProcessCommand(command: String) -> void:
	var command_gd: CommandGD = command_keeper[command.get_slice(" ", 0)]
	command_args = command.split(" ")
	command_args.remove_at(0)
	#if command_gd.unit_command: pass
	#else: onCommandSelected(command_gd)
	
func onTileSelected(Tile: TileGD, command_gd: CommandGD) -> void:
	command_args.push_front(Tile.Unit)
	#last_commands.append()
	
func onCommandSelected() -> void: pass
	#if commands_args.size() > 0 and commands_args[0] is UnitGD: last_commands.append(commands_args[0].Tile)
	#else: last_commands.append(null)
	
func onAdvanceUnit() -> void:
	LevelMap.on_advance_game_phase()
	onTriggerNonUnit()
	
func onHandUnit() -> void:
	var card_options: Array = range(7, 25)
	for i in range(Hand.get_children().size()):
		Hand.get_child(i).queue_free()
		LevelUI.CardBox.get_child(i).queue_free()
	for i in range(3):
		var deck_card: DeckCardGD = Deck.on_create_card(card_options[randi() % card_options.size()], 0, [])
		Deck.on_force_draw_card(deck_card)
	onTriggerNonUnit()
	
func onTriggerNonUnit() -> void:
	last_commands[last_commands.size() - 1].append(null)
	
var command_args: Array = []
	
func onSelectTile(sig: Signal) -> void:
	visible = false
	LevelUI.onSelectTileConsoleMode(sig)
	active_sig = sig
	
var active_sig: Signal
var last_commands: Array = []
#func onTileSelected(Tile: TileGD) -> void:
	#last_commands[last_commands.size() - 1].append(Tile.onTTpos())
	#LevelUI.onSelectTileFinish()
	
func onSpawnTileSet(Tile: TileGD) -> void:
	await Units.onUnitAwakened(int(command_args[1]), 0, [], int(command_args[2]), 0, Tile)
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	PlayerManager.passed_turns.erase(Unit)
	PlayerManager.on_select_active_unit(Unit)
	
func onStaggerSet(Tile: TileGD):
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	var AppliedBy := AppliedByGD.new("Console")
	Combat.onStagger(Unit, AppliedBy)

func onDamageSet(Tile: TileGD) -> void:
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	var AppliedBy := AppliedByGD.new("Ability")
	Combat.onDMG(Unit, AppliedBy, int(command_args[1]))
	
func onAIStatsSet(Tile: TileGD) -> void:
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	if VFX.onUnitVFXExists(Unit, "AIStats"):
		VFX.onRemoveUnitVFX(Unit, "AIStats")
	else: VFX.onCreateUnitVFX(Unit, "AIStats", [Unit, SpectateCamera.Camera])
	
func onHealSet(Tile: TileGD) -> void:
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	Combat.onHeal(HealInfoGD.new(Unit, AppliedByGD.new("Ability"), int(command_args[1])))

func onStatSet(Tile: TileGD) -> void:
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	Combat.onBuffInfo(BuffInfoGD.new(Unit, AppliedByGD.new("Console"), command_args[1], int(command_args[2])))

@onready var PlaceholderLabel: Label = %PlaceholderLabel
func _on_command_line_text_changed(text: String):
	match text:
		"spawn": PlaceholderLabel.text = "spawn id team"
		"damage": PlaceholderLabel.text = "damage value"
		"heal": PlaceholderLabel.text = "heal value"
		"stat": PlaceholderLabel.text = "stat type value"
		_: PlaceholderLabel.text = ""

func onFatigueSet(Tile: TileGD):
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	PlayerManager.passed_turns.erase(Unit)
	PlayerManager.on_select_active_unit(Unit)


func _on_copy_button_pressed():
	var commands := preload("res://static/dev/commands.tres")
	commands.last_commands = last_commands
	ResourceSaver.save(commands)

func _on_paste_button_pressed():
	var commands := preload("res://static/dev/commands.tres")
	for command in commands.last_commands:
		_on_command_line_text_submitted(command[0])
		if command[1] != null:
			var Tile: TileGD = Tiles.position_to_tile(command[1])
			active_sig.emit(Tile)
