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
	if command.begins_with("spawn"):
		onSpawnUnit(command.split(" "))
	
	elif command.begins_with("stagger"):
		onStaggerUnit()
		
	elif command.begins_with("damage"):
		onDamageUnit(command.split(" "))

	elif command.begins_with("heal"):
		onHealUnit(command.split(" "))

	elif command.begins_with("stat"):
		onStatUnit(command.split(" "))

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
	
func onStaggerUnit() -> void:
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
	
	var AppliedBy := AppliedByGD.new()
	AppliedBy.type = "Console"
	Combat.onStagger(Unit, AppliedBy)

func onDamageSet(Tile: TileGD) -> void:
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	
	var AppliedBy := AppliedByGD.new()
	AppliedBy.type = "Ability"
	
	Combat.onDMG(Unit, AppliedBy, int(command_args[1]))
	
func onHealSet(Tile: TileGD) -> void:
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	
	var AppliedBy := AppliedByGD.new()
	AppliedBy.type = "Ability"
	
	var healInfo := HealInfoGD.new()
	healInfo.AppliedBy = AppliedBy
	healInfo.Healee = Unit
	healInfo.heal = int(command_args[1])
	
	Combat.onHeal(healInfo)

func onStatSet(Tile: TileGD) -> void:
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	var buff_info := BuffInfoGD.new()
	var AppliedBy := AppliedByGD.new()
	AppliedBy.type = "Console"
	buff_info.AppliedBy = AppliedBy
	buff_info.Unit = Unit
	buff_info.stat = command_args[1]
	buff_info.value = int(command_args[2])
	Combat.onBuffInfo(buff_info)
