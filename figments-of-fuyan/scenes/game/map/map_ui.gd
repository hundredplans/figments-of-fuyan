extends Control

#region Globals
signal screen_created

var World: Node3D
var save_file: SaveFileGD
var area: AreaGD
@onready var AreaNameLabel: Label = %AreaNameLabel
@onready var AniPlayer: AnimationPlayer = %UIAnimationPlayer
@onready var ShillingsLabel: FancyTextLabel = %ShillingsLabel
@onready var BackgroundDarkener: Control = %BackgroundDarkener
@onready var LegendBox: VBoxContainer = %LegendBox
@onready var BoonBox: GridContainer = %BoonBox
@onready var TimeLabel: Label = %TimeLabel

@onready var ToolBeltSlotOne: Control = %ToolBeltSlotOne
@onready var ToolBeltSlotTwo: Control = %ToolBeltSlotTwo

@onready var DeckPanel: PanelContainer = %DeckPanel
@onready var DeckCardAmountLabel: Label = %DeckCardAmountLabel
@onready var Console: Control = %Console
#endregion

#region Exports
@export var LegendKeyPacked: PackedScene
@export var DeckScreenPacked: PackedScene
#endregion

#region Helper
func getDeckPanel() -> Control:
	return DeckPanel
#endregion

#region Base Functions
func _ready() -> void:
	BackgroundDarkener.visible = false
	ToolBeltSlotOne.visible = false
	ToolBeltSlotTwo.visible = false
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Back"):
		Game.getSaveFile().onLoadMainMenu()

func setInfo(_save_file: SaveFileGD) -> void:
	save_file = _save_file
	onUpdateShillings()
	
	area = save_file.area
	area.process_action.connect(onProcessAction)
	area.init_load.connect(onInitLoad)
	
	TimeLabel.setInfo(save_file)
	BoonBox.onUpdate()
	setLegendBox()
	onUpdateToolbelt()
	
	for map_node in get_tree().get_nodes_in_group("MapNodesGD"):
		map_node.create_screen.connect(onCreateScreen)
		map_node.finished.connect(onMapNodeFinished)
		map_node.hovered.connect(onMapNodeHovered)
	
	onUpdateDeckCardAmountLabel()
	
func onInitLoad() -> void: # Basically the area fof init
	onMapStartAnimation()

func onProcessAction(action: Action) -> void:
	if is_queued_for_deletion(): return
	if action.post:
		if action is AddToDeckAction:
			onUpdateDeckCardAmountLabel()
		elif action is RemoveFromDeckAction:
			onUpdateDeckCardAmountLabel()
		elif action is AddBoonAction:
			BoonBox.onUpdate()
		elif action is RemoveBoonAction:
			BoonBox.onUpdate()
		elif action is AddToToolbeltAction:
			onUpdateToolbelt()
		elif action is RemoveFromToolbeltAction:
			onUpdateToolbelt()
		elif action is ChangeShillingsAction:
			onUpdateShillings()
#endregion

#region Map Start
func onMapStartAnimation() -> void:
	if !Helper.admin_datastore.skip_map_start_animation:
		AreaNameLabel.text = area.info.name
		AniPlayer.play("MapStart")
#endregion

#region Shillings
func onUpdateShillings() -> void:
	ShillingsLabel.setText("SH: " + str(Game.getSaveFile().getShillings()))
#endregion

#region Map Node
func onCreateScreen(map_node: MapNodeGD, ActiveScreen: Control) -> void:
	add_child(ActiveScreen)
	ActiveScreen.setInfo(save_file, area, World, self, map_node)
	BackgroundDarkener.visible = ActiveScreen.onDimBackground()
	LegendBox.visible = false
	screen_created.emit()
	
func onMapNodeFinished(_map_node: MapNodeGD) -> void:
	BackgroundDarkener.visible = false
	LegendBox.visible = true

func onMapNodeHovered(map_node: MapNodeGD, state: bool, HoverUI: Variant = null) -> void:
	if HoverUI != null: Game.onEmptyTooltip(state, HoverUI, self)
	if state and HoverUI != null:
		HoverUI.setInfo(map_node.onSave())
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
	
func onToolbeltCardSelected(Card: CardGD) -> void:
	Game.getArea().onPushAction([RemoveFromToolbeltAction.new(ToolbeltTool), AddToolAction.new(Card, ToolbeltTool)])
	ToolbeltTool = null

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

#region Deck Card Amount
func onUpdateDeckCardAmountLabel() -> void:
	DeckCardAmountLabel.text = str(get_tree().get_node_count_in_group("DeckCardsGD"))
#endregion

#region Mouse In UI
func onMouseInUI(state: bool) -> void:
	Game.onMouseInUI(state)
#endregion
