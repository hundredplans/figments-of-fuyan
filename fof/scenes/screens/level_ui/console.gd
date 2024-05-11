extends Control

signal stagger_set
signal spawn_set

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
	if command.begins_with("spawn"):
		onSpawnUnit(command.split(" "))
	
	elif command.begins_with("stagger"):
		onStaggerUnit()

var command_args: Array = []
func onSpawnUnit(args: Array) -> void:
	onSelectTile(spawn_set)
	command_args = args
	
func onStaggerUnit() -> void:
	onSelectTile(stagger_set)
	
func onSelectTile(sig: Signal) -> void:
	visible = false
	LevelUI.onSelectTileConsoleMode(sig)
	
func onTileSelected(_Tile: TileGD) -> void:
	LevelUI.onSelectTileFinish()
	
func onSpawnTileSet(Tile: TileGD) -> void:
	Units.on_unit_awakened(int(command_args[1]), 0, [], int(command_args[2]), 0, Tile)

func onStaggerSet(Tile: TileGD):
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	
	var AppliedBy := AppliedByGD.new()
	AppliedBy.type = "Console"
	Combat.onStagger(Unit, AppliedBy)
