extends Control

signal finished

var save_file: SaveFileGD
var UI: Control

const TRANSFORM_WAIT_PRESSED_TIME: float = 1.5
const CARD_FLIP_TIME: float = 0.25

@onready var Cards: Control = %Cards
@onready var RemoveCardPosition: Control = %RemoveCardPosition

@onready var Boons: Control = %Boons
@onready var Tools: Control = %Tools
@onready var TransformPosition: Control = %TransformPosition
@onready var RemoveCardControl: Control = %RemoveCardControl
@onready var TransformControl: Control = %TransformControl

@onready var CardsFiller: Control = %CardsFiller

@export var PurchasableCardPacked: PackedScene
@export var PurchasableRemovePacked: PackedScene
@export var PurchasableBoonPacked: PackedScene
@export var PurchasableToolPacked: PackedScene
@export var PurchasableTransformPacked: PackedScene

var World: Node3D
func setInfo(_save_file: SaveFileGD, _area: AreaGD, _World: Node3D, _UI: Control, map_node: MapNodeGD) -> void:
	World = _World
	UI = _UI
	save_file = _save_file
	var items: Array = map_node.items
	var boon_ids: Array = []
	
	for price_datastore in items:
		var item: SavedData = price_datastore.data
		var purchasable_packed: PackedScene
		var parent: Control
		
		match item.getInfoType().getFofName():
			"Card":
				purchasable_packed = PurchasableCardPacked
				parent = Cards
			"MapEffect":
				if item.id == 3:
					purchasable_packed = PurchasableRemovePacked
					parent = RemoveCardPosition
				else:
					purchasable_packed = PurchasableTransformPacked
					parent = TransformPosition
			"Boon":
				boon_ids.append(item.id)
				if Game.isBoonAvailable(item.id, boon_ids):
					item = map_node.onRerollBoon()
					
				if item != null:
					purchasable_packed = PurchasableBoonPacked
					parent = Boons
			"Tool":
				purchasable_packed = PurchasableToolPacked
				parent = Tools
		
		var fof: FofGD = SavedData.onLoadModel(price_datastore.data, World.ActiveWorld)
		if purchasable_packed == null: continue
		
		var purchasable: Control = purchasable_packed.instantiate()
		parent.add_child(purchasable)
		purchasable.setInfo(fof, price_datastore, save_file)
		purchasable.create_screen.connect(onCreateScreen)
		purchasable.pressed.connect(onItemPressed)
	Cards.move_child(CardsFiller, 2)
		
	if map_node.isFirstShop():
		RemoveCardControl.custom_minimum_size.x = 0
		TransformControl.custom_minimum_size.x = 0
		
func onItemPressed(item: FofGD, price_datastore: PriceDatastore, DisplayedUI: Control) -> void:
	price_datastore.bought = true
	save_file.onUpdateShillings(-price_datastore.price)
	
	if item is CardGD:
		Game.onAddToDeck(item)
		Game.onFlyToUI(DisplayedUI, UI.getDeckPanel())
		
	elif item is ToolGD:
		var tool_belt_index: int = save_file.tool_belt.find(item)
		var To: Control = UI.DeckPanel
		
		if tool_belt_index == 0:
			To = UI.ToolBeltSlotOne
		elif tool_belt_index == 1:
			To = UI.ToolBeltSlotTwo
		
		Game.onFlyToUI(DisplayedUI, To)
	elif item is BoonGD:
		save_file.onAddBoon(item)
		Game.onFlyToUI(DisplayedUI, UI.BoonBox.onFindBoonIcon(item))
		
	World.ActiveWorld.onBuy()
	if item is MapEffectGD and item.info.id != 3: # Not remove card
		if item.info.id == 4: # Ascend card
			DisplayedUI.onCardAscended(false)
		DisplayedUI = await onFlipCardAnimation(DisplayedUI, item.NewCard)
		await get_tree().create_timer(TRANSFORM_WAIT_PRESSED_TIME).timeout
		Game.onFlyToUI(DisplayedUI, UI.DeckPanel)
		
func onFlipCardAnimation(CardUI: Control, NewCard: CardGD) -> Control:
	var NewCardUI: Control = NewCard.onCreateCardUI(self, false)
	
	NewCardUI.global_position = CardUI.global_position
	NewCardUI.scale.x = 0
	
	var flip_tween := create_tween()
	flip_tween.tween_property(CardUI, "scale:x", 0, CARD_FLIP_TIME)
	await flip_tween.finished
	
	CardUI.queue_free()
	flip_tween = create_tween()
	flip_tween.tween_property(NewCardUI, "scale:x", 1, CARD_FLIP_TIME)
	await flip_tween.finished
	return NewCardUI

func _on_exit_button_pressed() -> void:
	finished.emit()
	
func onDimBackground() -> bool:
	return false
	
func onCreateScreen(screen: Control) -> void:
	add_child(screen)
	
