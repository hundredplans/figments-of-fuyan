extends VBoxContainer

signal active_effect_pressed
signal mouse_in_ui
signal pressed

@export_group("Nodes")
@export var SpectatedUnitStatusUI: Control
@export var AbilityBoxes: Control
@export_group("")

@export_group("Packed Scenes")
@export var UnitStatusUIPacked: PackedScene
@export var AbilityBoxUIPacked: PackedScene
@export_group("")

var CardAbilityBox: Control
var ToolAbilityBox: Control
var IObjectAbilityBox: Control

const DEPENDANT_ID: int = 12

func _ready() -> void:
	if SpectatedUnitStatusUI != null: SpectatedUnitStatusUI.setInfo(true, true)
	if AbilityBoxes != null: onCreateAbilityBoxes()
		
func onCreateUnitStatusUI(Card: CardGD) -> void:
	var UnitStatusUI: Control = UnitStatusUIPacked.instantiate()
	add_child(UnitStatusUI)
	
	var alignnment = HBoxContainer.ALIGNMENT_END if isAllyUnitStatusManager() else HBoxContainer.ALIGNMENT_BEGIN
	UnitStatusUI.setInfo(false, isAllyUnitStatusManager(), alignnment)
	UnitStatusUI.setCard(Card)
	UnitStatusUI.pressed.connect(onUnitStatusUIPressed)
	UnitStatusUI.mouse_in_ui.connect(onMouseInUI)
	
func onRemoveUnitStatusUI(Card: CardGD) -> void:
	var UnitStatusUI: Control = getUnitStatusUI(Card)
	if UnitStatusUI == null: return
	UnitStatusUI.queue_free()
	
func onUpdateSpectatedUnitStatusUI(SpectateObject: GameObjectGD) -> void:
	var PreviousCard: CardGD = SpectatedUnitStatusUI.getCard()
	if PreviousCard != null:
		var PreviousUnitStatusUI: Control = getUnitStatusUI(PreviousCard)
		if PreviousUnitStatusUI != null:
			PreviousUnitStatusUI.setSpectated(false)
	
	if SpectateObject == null or SpectateObject is ObjectGD:
		SpectatedUnitStatusUI.visible = false
		AbilityBoxes.visible = false
		return
		
	AbilityBoxes.visible = true
	SpectatedUnitStatusUI.visible = true
	SpectatedUnitStatusUI.setCard(SpectateObject)
	
	var CurrentUnitStatusUI: Control = getUnitStatusUI(SpectateObject)
	if CurrentUnitStatusUI != null:
		CurrentUnitStatusUI.setSpectated(true)
	
	onUpdateAbilityBoxes(SpectateObject)
	
func onUpdateAbilityBoxes(Card: CardGD) -> void:
	if isDependant(): return
	
	onUpdateCardAbilityBox(Card)
	onUpdateToolAbilityBox(Card.getTool() if Card != null else null)
	onUpdateIObjectAbilityBox(Card)
	
func onUpdateAbilityBox(item: FofGD, SpectateObject: CardGD) -> void:
	if isDependant() or item == null or SpectateObject == null: return
	
	if item is CardGD and item == SpectateObject: onUpdateCardAbilityBox(item)
	elif item is ToolGD and item.getCard() == SpectateObject: onUpdateToolAbilityBox(item)
	else: onUpdateIObjectAbilityBox(SpectateObject)
	
func onUpdateCardAbilityBox(Card: CardGD) -> void:
	if isDependant(): return
	var show_card_ability: bool = Card.isValidActiveEffect() if Card != null else false
	CardAbilityBox.visible = show_card_ability
	if show_card_ability: CardAbilityBox.setItem(Card)
		
func onUpdateToolAbilityBox(Tool: ToolGD) -> void:
	if isDependant(): return
	var show_tool_ability: bool = Tool != null and Tool.isValidActiveEffect()
	ToolAbilityBox.visible = show_tool_ability
		
	if show_tool_ability:
		ToolAbilityBox.setItem(Tool)
	
func onUpdateIObjectAbilityBox(Card: CardGD) -> void:
	if isDependant(): return
	
	if Card != null:
		var iobjects: Array = get_tree().get_nodes_in_group("LevelIObjectsGD")
		var valid_iobjects: Array = iobjects.filter(func(x: IObjectGD): return !x.is_queued_for_deletion() and x.isValidActiveEffect(Card))
		var enabled_iobjects: Array = valid_iobjects.filter(func(x: IObjectGD): return !x.isActiveEffectDisabled(Card))
		IObjectAbilityBox.visible = !valid_iobjects.is_empty()
		if !valid_iobjects.is_empty():
			var active_iobjects := ActiveIObjects.new(enabled_iobjects, Card)
			IObjectAbilityBox.setItem(active_iobjects)
	else: IObjectAbilityBox.visible = false

func getUnitStatusUI(Card: CardGD) -> Control:
	for UnitStatusUI: Control in get_children():
		if UnitStatusUI.getCard() == Card: return UnitStatusUI
	return null

func onCreateAbilityBoxes() -> void:
	IObjectAbilityBox = AbilityBoxUIPacked.instantiate()
	AbilityBoxes.add_child(IObjectAbilityBox)
	IObjectAbilityBox.setBorderColor(Color.BLACK)
	
	ToolAbilityBox = AbilityBoxUIPacked.instantiate()
	AbilityBoxes.add_child(ToolAbilityBox)
	
	CardAbilityBox = AbilityBoxUIPacked.instantiate()
	AbilityBoxes.add_child(CardAbilityBox)
	
	var area_color := Game.getArea().getAreaColor()
	for child: Control in AbilityBoxes.get_children():
		child.mouse_in_ui.connect(onMouseInUI)
		child.ability_box_pressed.connect(onActiveEffectPressed)
		child.setBackgroundColor(area_color)
		child.visible = false

func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
	
func onActiveEffectPressed(item: Variant) -> void:
	active_effect_pressed.emit(item)
	
func isAllyUnitStatusManager() -> bool: return AbilityBoxes != null

func isDependant() -> bool: return Game.isBoonInGame(DEPENDANT_ID)

func setActionLock(is_action_lock: bool) -> void:
	for AbilityBoxUI: Control in AbilityBoxes.get_children():
		AbilityBoxUI.setActionLock(is_action_lock)

func onUpdateInVisionRange(SpectateObject: GameObjectGD) -> void:
	var visible_cards: Array = SpectateObject.getVisibleFieldCards() if SpectateObject is CardGD else []
	for UnitStatusUI: Control in get_children():
		var _Card: CardGD = UnitStatusUI.getCard()
		UnitStatusUI.setInVisionRange(_Card in visible_cards)
		
	var unit_status_uis: Array = get_children()
	unit_status_uis.sort_custom(func(x: Control, y: Control): return x.getInVisionRange() and !y.getInVisionRange())
	
	for i in range(unit_status_uis.size()):
		move_child(unit_status_uis[i], i)

func onUnitStatusUIPressed(Card: CardGD) -> void:
	pressed.emit(Card)

func setDisabled(state: bool) -> void:
	for UnitStatusUI: Control in get_children(): UnitStatusUI.setDisabled(state)

func onUpdateTool(Card: CardGD) -> void:
	var UnitStatusUI: Control = getUnitStatusUI(Card)
	if UnitStatusUI == null: return
	UnitStatusUI.onUpdateTool(Card.getTool())
