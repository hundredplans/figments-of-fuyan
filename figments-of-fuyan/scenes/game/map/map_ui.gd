extends Control

#region Globals
signal stash_screen_start
signal stash_screen_exit_start
signal screen_created
signal screen_finished
signal active_tool_added

var World: Node3D
var save_file: SaveFileGD
var area: AreaGD

var PauseMenu: Control
var ChampionUpgradeUI: Control

@onready var CommonGameUI: Control = %CommonGameUI
@onready var MainManager: Control = %MainManager
@onready var FadeBackground: ColorRect = %FadeBackground
@onready var AreaNameLabel: Label = %AreaNameLabel
@onready var AniPlayer: AnimationPlayer = %UIAnimationPlayer
@onready var Console: Control = %Console

var BoonBox: Control
#endregion

#region Exports
@export var DeckScreenPacked: PackedScene
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
	
	BoonBox = CommonGameUI.getBoonBox()
	
	area = save_file.area
	area.process_action.connect(onProcessAction)
	area.init_load.connect(onInitLoad)
	
	BoonBox.onUpdate()
	
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
			BoonBox.onUpdate(action.Boon)
		elif action is RemoveBoonAction:
			BoonBox.onUpdate(action.Boon, true)
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
	elif !action.post:
		if action is StartLoadingScreenAction:
			onHideMapUI()
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
	CommonGameUI.onUpdateShillings()
#endregion

#region Map Node
func onCreateScreen(map_node: MapNodeGD, ActiveScreen: Control) -> void:
	add_child(ActiveScreen)
	ActiveScreen.setInfo(save_file, area, World, self, map_node)
	ActiveScreen.minimap_mode.connect(onMinimapMode)
	ActiveScreen.create_stash_screen.connect(onCreateStashScreen)
	
	stash_screen_start.connect(ActiveScreen.onStashScreenStart)
	stash_screen_exit_start.connect(ActiveScreen.onStashScreenExitStart)
	active_tool_added.connect(ActiveScreen.onActiveToolAdded)
	
	screen_created.emit()
	if ActiveScreen.onFadeBackground():
		FadeBackground.color = Color(1, 1, 1, 0)
		FadeBackground.FADE_COLOR = ActiveScreen.getFadeBackgroundColor()
		await FadeBackground.onFade(true)
		ActiveScreen.fade_loaded.emit()
	
func onMapNodeFinished(_map_node: MapNodeGD) -> void:
	FadeBackground.onFade(false)

func onMapNodeHovered(map_node: MapNodeGD, state: bool, HoverUI: Variant = null) -> void:
	if HoverUI != null: Game.onEmptyTooltip(state, HoverUI, self)
	if state and HoverUI != null:
		HoverUI.setInfo(map_node)
#endregion

#region Deck
func _on_deck_button_pressed() -> void:
	add_child(DeckScreenPacked.instantiate())
#endregion

#region Deck
const FADE_BOON_BOX_TIME: float = 0.25
var StashScreen: Control
	
func onCreateStashScreen(ToolIcon: TbcUI = null) -> void:
	StashScreen = Game.onCreateStashScreen(self, ToolIcon)
	if StashScreen == null: return
	StashScreen.mouse_in_ui.connect(onMouseInUI)
	StashScreen.deck_slot_changed.connect(onUpdateDeckCardAmountLabel)
	StashScreen.exit_start.connect(func(): stash_screen_exit_start.emit())
	StashScreen.active_tool_added.connect(func(x: TbcUI): active_tool_added.emit(x))
	stash_screen_start.emit()
	
	var EnteredMapNode: MapNodeGD = Game.getArea().getEnteredMapNode()
	if !EnteredMapNode.is_finished and EnteredMapNode.info.is_encounter:
		if EnteredMapNode.isDragZone():
			StashScreen.onActivateDragZone(EnteredMapNode)
		StashScreen.setBackgroundColor(EnteredMapNode.getEncounterDatastore().getBackgroundMainColor())
	
func onUpdateStashScreen(created: bool) -> void:
	var end_value: float = 0.0 if created else 1.0
	if created: screen_created.emit()
	else: screen_finished.emit()
		
	for node: Control in [CommonGameUI]:
		var tween := create_tween()
		tween.tween_property(node, "modulate:a", end_value, Game.FADE_TIME)
#endregion

#region Deck Card Amount
func onUpdateDeckCardAmountLabel() -> void:
	CommonGameUI.onUpdateStashAmountLabel()
#endregion

#region Mouse In UI
func onMouseInUI(state: bool) -> void:
	Game.onMouseInUI(state)
#endregion

func onMinimapMode(is_start: bool, nodes: Array = []) -> void:
	nodes += [FadeBackground, CommonGameUI]
	if !is_start:
		for map_node: MapNodeGD in get_tree().get_nodes_in_group("MapNodesGD"):
			map_node.setRayPickable(false)
			map_node.is_minimap = false
		
		for node: Control in nodes:
			node.visible = true
			
	var desired: float = int(!is_start)
	for node: Control in nodes:
		var tween := create_tween()
		tween.tween_property(node, "modulate:a", desired, Game.FADE_TIME)
		
	FadeBackground.onFade(!is_start)
	World.onDisableCameraByUI(!is_start)
	
	await get_tree().create_timer(Game.FADE_TIME).timeout
	if is_start:
		for map_node: MapNodeGD in get_tree().get_nodes_in_group("MapNodesGD"):
			map_node.setRayPickable(is_start)
			map_node.is_minimap = true
			
		for node: Control in nodes:
			node.visible = false

func onHideMapUI() -> void:
	MainManager.visible = false
