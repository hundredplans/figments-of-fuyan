extends Control

#region Globals
var World: Node3D
var save_file: SaveFileGD
var area: AreaGD
@onready var AreaNameLabel: Label = %AreaNameLabel
@onready var AniPlayer: AnimationPlayer = %UIAnimationPlayer
@onready var ShillingsLabel: FancyTextLabel = %ShillingsLabel
@onready var BackgroundDarkener: Control = %BackgroundDarkener
@onready var LegendBox: VBoxContainer = %LegendBox
@onready var LegendContainer: PanelContainer = %LegendContainer
@onready var BoonBox: GridContainer = %BoonBox
@onready var TimeLabel: Label = %TimeLabel

@onready var ToolBeltSlotOne: Control = %ToolBeltSlotOne
@onready var ToolBeltSlotTwo: Control = %ToolBeltSlotTwo

@onready var DeckPanel: PanelContainer = %DeckPanel
#endregion

#region Exports
@export var LegendKeyPacked: PackedScene
@export var DeckScreenPacked: PackedScene
#endregion

#region Base Functions
func _ready() -> void:
	BackgroundDarkener.visible = false
	ToolBeltSlotOne.visible = false
	ToolBeltSlotTwo.visible = false

func setInfo(_save_file: SaveFileGD) -> void:
	save_file = _save_file
	save_file.update_shillings.connect(onUpdateShillings)
	save_file.update_toolbelt.connect(onUpdateToolbelt)
	save_file.update_boons.connect(func(_x: BoonGD): BoonBox.onUpdate())
	onUpdateShillings(save_file.getShillings())
	
	area = save_file.area
	area.init_load.connect(onInitLoad)
	
	TimeLabel.setInfo(save_file)
	BoonBox.setInfo(save_file)
	BoonBox.onUpdate()
	setLegendBox()
	onUpdateToolbelt()
	
	for map_node in get_tree().get_nodes_in_group("MapNodesGD"):
		map_node.create_screen.connect(onCreateScreen)
		map_node.finished.connect(onMapNodeFinished)
		map_node.hovered.connect(onMapNodeHovered)
	
func onInitLoad() -> void: # Basically the area fof init
	onMapStartAnimation()

#endregion

#region Map Start
func onMapStartAnimation() -> void:
	if !Helper.getAdmin():
		AreaNameLabel.text = area.info.name
		AniPlayer.play("MapStart")
#endregion

#region Shillings
func onUpdateShillings(count: int) -> void:
	ShillingsLabel.setText("SH: " + str(count))
#endregion

#region Map Node
func onCreateScreen(map_node: MapNodeGD, ActiveScreen: Control) -> void:
	add_child(ActiveScreen)
	ActiveScreen.setInfo(save_file, area, World, self, map_node)
	BackgroundDarkener.visible = ActiveScreen.onDimBackground()
	LegendContainer.visible = false
	
func onMapNodeFinished(_map_node: MapNodeGD) -> void:
	BackgroundDarkener.visible = false
	LegendContainer.visible = true

func onMapNodeHovered(map_node: MapNodeGD, state: bool, HoverUI: Control = null) -> void:
	if state and HoverUI != null:
		add_child(HoverUI)
		HoverUI.setInfo(map_node, area)
#endregion

#region Legend
func setLegendBox() -> void:
	var map_node_name_icon: Dictionary
	
	for map_node in get_tree().get_nodes_in_group("MapNodesGD"):
		map_node_name_icon[map_node.info.name] = map_node
		
	var map_nodes: Array = map_node_name_icon.values()
	map_nodes.sort_custom(func(x: MapNodeGD, y: MapNodeGD): return x.info.legend_order < y.info.legend_order)
	
	for MapNode in map_nodes:
		var LegendKey: Control = LegendKeyPacked.instantiate()
		LegendBox.add_child(LegendKey)
		LegendKey.setInfo(MapNode)
#endregion

#region Deck
func _on_deck_button_pressed() -> void:
	add_child(DeckScreenPacked.instantiate())
#endregion

#region Toolbelt
var ToolbeltTool: ToolGD
func onUpdateToolbelt() -> void:
	var toolbelt_slots: Array = [ToolBeltSlotOne, ToolBeltSlotTwo]
	for i in range(Game.TOOLBELT_SIZE):
		var ToolbeltSlot = toolbelt_slots[i]
		var tool_exists: bool = save_file.tool_belt.size() > i
		
		ToolbeltSlot.visible = tool_exists
		if tool_exists:
			var Tool: ToolGD = save_file.tool_belt[i]
			ToolbeltSlot.setInfo(Tool, true)
			
func onToolbeltSlotPressed(Tool: ToolGD) -> void:
	if Tool == null: return
	var DeckScreen: Control = DeckScreenPacked.instantiate()
	add_child(DeckScreen)
	DeckScreen.selected.connect(onToolbeltCardSelected)
	DeckScreen.setInfo(true)
	
	ToolbeltTool = Tool
	DeckScreen.onDisableCards(onDisableCardsWithTool)
	
func onToolbeltCardSelected(Card: CardGD) -> void:
	save_file.onRemoveToolFromToolbelt(ToolbeltTool)
	if Card.Tool == null or Card.Tool.info.id != ToolbeltTool.info.id:
		Card.add_child(ToolbeltTool)
		Card.onAddTool(ToolbeltTool)
	else:
		Card.Tool.setAscended(true)
	
	ToolbeltTool = null
	onUpdateToolbelt()

func onDisableCardsWithTool(CardUI: Control) -> bool:
	var Tool: ToolGD = CardUI.Card.Tool
	return Tool != null and (Tool.info.id != ToolbeltTool.info.id or Tool.ascended)
#endregion

#region Deck
func onDeckButtonPressed() -> void:
	var DeckScreen: Control = DeckScreenPacked.instantiate()
	add_child(DeckScreen)
	DeckScreen.setInfo(false)
#endregion
