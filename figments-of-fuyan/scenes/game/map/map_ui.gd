extends Control

#region Globals
signal screen_created
signal screen_finished

var World: Node3D
var save_file: SaveFileGD
var area: AreaGD

var PauseMenu: Control
var ChampionUpgradeUI: Control

@onready var FadeBackground: ColorRect = %FadeBackground
@onready var AreaNameLabel: Label = %AreaNameLabel
@onready var AniPlayer: AnimationPlayer = %UIAnimationPlayer
@onready var ShillingsLabel: FancyTextLabel = %ShillingsLabel
@onready var LegendBox: VBoxContainer = %LegendBox
@onready var BoonBox: GridContainer = %BoonBox
@onready var TimeLabel: Label = %TimeLabel

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
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Back") and PauseMenu == null:
		PauseMenu = Game.onCreatePauseMenu(self)
		PauseMenu.mouse_in_ui.connect(onMouseInUI)
		PauseMenu.tree_exited.connect(func(): screen_finished.emit())
		screen_created.emit()

func setInfo(_save_file: SaveFileGD) -> void:
	Game.update_stash_screen.connect(onUpdateStashScreen)
	save_file = _save_file
	onUpdateShillings()
	
	area = save_file.area
	area.process_action.connect(onProcessAction)
	area.init_load.connect(onInitLoad)
	
	BoonBox.onUpdate()
	setLegendBox()
	
	for map_node in get_tree().get_nodes_in_group("MapNodesGD"):
		map_node.create_screen.connect(onCreateScreen)
		map_node.hovered.connect(onMapNodeHovered)
	
	onUpdateDeckCardAmountLabel()
	if get_parent().get_node_or_null("RunFinishUI") != null:
		visible = false
	
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
		elif action is ChangeBoonChargesAction:
			BoonBox.onUpdateBoonChargesAndDisabled(action.Boon)
		elif action is ChangeShillingsAction:
			onUpdateShillings()
		elif action is PlayerDeckUpgradeAction:
			onUpdateDeckCardAmountLabel()
		elif action is ChampionUpgradeAction:
			ChampionUpgradeUI = Game.onCreateChampionUpgradeUI(self, action.old_deck_limit, action.old_energy_limit, action.old_max_energy)
			ChampionUpgradeUI.mouse_in_ui.connect(onMouseInUI)
			ChampionUpgradeUI.edit_deck.connect(onCreateStashScreen)
		elif action is MapNodeFinishedAction:
			onMapNodeFinished(action.map_node)
#endregion

#region Map Start
var is_init_load: bool
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
	ActiveScreen.minimap_mode.connect(onMinimapMode)
	
	if ActiveScreen.onFadeBackground():
		FadeBackground.color = Color(1, 1, 1, 0)
		FadeBackground.FADE_COLOR = ActiveScreen.getFadeBackgroundColor()
		FadeBackground.onFade(true)
	LegendBox.visible = false
	screen_created.emit()
	
func onMapNodeFinished(_map_node: MapNodeGD) -> void:
	FadeBackground.onFade(false)
	LegendBox.visible = true

func onMapNodeHovered(map_node: MapNodeGD, state: bool, HoverUI: Variant = null) -> void:
	if HoverUI != null: Game.onEmptyTooltip(state, HoverUI, self)
	if state and HoverUI != null:
		HoverUI.setInfo(map_node)
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

#region Deck
const FADE_BOON_BOX_TIME: float = 0.25
var StashScreen: Control
func onDeckButtonPressed() -> void:
	onCreateStashScreen()
	
func onCreateStashScreen() -> void:
	StashScreen = Game.onCreateStashScreen(self)
	StashScreen.mouse_in_ui.connect(onMouseInUI)
	StashScreen.deck_slot_changed.connect(onUpdateDeckCardAmountLabel)
	
	var EnteredMapNode: MapNodeGD = Game.getArea().getEnteredMapNode()
	if !EnteredMapNode.is_finished and EnteredMapNode.info.is_shop:
		StashScreen.onStashIsSellable()
	
func onUpdateStashScreen(created: bool) -> void:
	var end_value: float = 0.0 if created else 1.0
	if created: screen_created.emit()
	else: screen_finished.emit()
		
	for node: Control in [BoonBox, LegendBox, DeckPanel]:
		var tween := create_tween()
		tween.tween_property(node, "modulate:a", end_value, Game.FADE_TIME)
#endregion

#region Deck Card Amount
func onUpdateDeckCardAmountLabel() -> void:
	var deck_amount: String = str(Game.getSaveFile().getUsedDeckSlotCount())
	var deck_limit: String = str(Game.getSaveFile().getDeckLimit())
	DeckCardAmountLabel.text = deck_amount + "/" + deck_limit
#endregion

#region Mouse In UI
func onMouseInUI(state: bool) -> void:
	Game.onMouseInUI(state)
#endregion

func onMinimapMode(is_start: bool) -> void:
	if !is_start: FadeBackground.visible = true
		
	FadeBackground.onFade(!is_start)
	World.onDisableCameraByUI(!is_start)
	
	await get_tree().create_timer(Game.FADE_TIME).timeout
	if is_start: FadeBackground.visible = false
