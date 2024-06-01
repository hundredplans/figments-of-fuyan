extends Control

signal heal_set
signal damage_set
signal stagger_set
signal spawn_set
signal stat_set
signal fatigue_set

var Combat: CombatGD
var LevelUI: LevelUIGD
var Units: UnitsGD
var Tiles: TilesGD
var PlayerManager: PlayerManagerGD

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
	call("on" + command.get_slice(" ", 0).capitalize() + "Unit")
	command_args = command.split(" ")
	
var command_args: Array = []
func onSpawnUnit() -> void:
	onSelectTile(spawn_set)
	
func onDamageUnit() -> void:
	onSelectTile(damage_set)
	
func onFatigueUnit() -> void:
	onSelectTile(fatigue_set)
	
func onHealUnit() -> void:
	onSelectTile(heal_set)
	
func onStaggerUnit() -> void:
	onSelectTile(stagger_set)

func onStatUnit() -> void:
	onSelectTile(stat_set)
	
func onSelectTile(sig: Signal) -> void:
	visible = false
	LevelUI.onSelectTileConsoleMode(sig)
	
func onTileSelected(_Tile: TileGD) -> void:
	LevelUI.onSelectTileFinish()
	
func onSpawnTileSet(Tile: TileGD) -> void:
	await Units.on_unit_awakened(int(command_args[1]), 0, [], int(command_args[2]), 0, Tile)
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
