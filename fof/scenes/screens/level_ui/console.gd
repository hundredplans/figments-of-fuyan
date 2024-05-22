extends Control

signal heal_set
signal damage_set
signal stagger_set
signal spawn_set
signal stat_set

var Combat: CombatGD
var LevelUI: LevelUIGD
var Units: UnitsGD
var Tiles: TilesGD

@onready var CommandLine: LineEdit = %CommandLine
@onready var PastCommandsLabel: Label = %PastCommandsLabel

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Console"):
		onConsolePressed()
		
func onConsolePressed() -> void:
	visible = !visible
	if visible: CommandLine.call_deferred("grab_focus")

func _on_command_line_text_submitted(command: String):
	CommandLine.release_focus()
	onProcessCommand(command)
	PastCommandsLabel.text += command + "\n"

func onProcessCommand(command: String) -> void:
	call("on" + command.get_slice(" ", 0).capitalize() + "Unit", command.split(" "))

var command_args: Array = []
func onSpawnUnit(args: Array) -> void:
	onSelectTile(spawn_set)
	command_args = args
	
func onDamageUnit(args: Array) -> void:
	onSelectTile(damage_set)
	command_args = args
	
func onHealUnit(args: Array) -> void:
	onSelectTile(heal_set)
	command_args = args
	
func onStaggerUnit(_args: Array) -> void:
	onSelectTile(stagger_set)

func onStatUnit(args: Array) -> void:
	onSelectTile(stat_set)
	command_args = args
	
func onSelectTile(sig: Signal) -> void:
	visible = false
	LevelUI.onSelectTileConsoleMode(sig)
	
func onTileSelected(_Tile: TileGD) -> void:
	LevelUI.onSelectTileFinish()
	
func onSpawnTileSet(Tile: TileGD) -> void:
	Units.on_unit_awakened(int(command_args[1]), 0, [], int(command_args[2]), 0, Tile)

func onStaggerSet(Tile: TileGD):
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	
	var AppliedBy := AppliedByGD.new("Console")
	Combat.onStagger(Unit, AppliedBy)

func onDamageSet(Tile: TileGD) -> void:
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	
	var AppliedBy := AppliedByGD.new("Ability")
	
	Combat.onDMG(Unit, AppliedBy, int(command_args[1]))
	
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
