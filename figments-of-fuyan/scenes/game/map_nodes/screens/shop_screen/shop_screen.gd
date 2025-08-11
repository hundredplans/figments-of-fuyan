class_name ShopScreen extends MapNodeScreen

const TRANSFORM_WAIT_PRESSED_TIME: float = 1.5
const CARD_FLIP_TIME: float = 0.25

@onready var PurchasableManager: Control = %PurchasableManager
@onready var FrameMerchantBase: Sprite2D = %FrameMerchantBase
@onready var FrameMerchantSprite: Sprite2D = %FrameMerchantSprite
@onready var FadeBackground: Control = %FadeBackground

@export var PurchasableCardPacked: PackedScene
@export var PurchasableBoonPacked: PackedScene
@export var PurchasableToolPacked: PackedScene

func getPurchasableFromType(type: GDScript) -> PackedScene:
	if type == BoonInfo: return PurchasableBoonPacked
	elif type == CardInfo: return PurchasableCardPacked
	elif type == ToolInfo: return PurchasableToolPacked
	return null

func onFirstEntered() -> void:
	pass

func setInfo(_save_file: SaveFileGD, _area: AreaGD, _World: Node3D, _UI: Control, shop: MapNodeGD) -> void:
	super(_save_file, _area, _World, _UI, shop)
	for price_datastore: PriceDatastore in shop.getItems():
		var data: SavedData = price_datastore.getData()
		var PurchasableScene: Control = getPurchasableFromType(data.getInfoType()).instantiate()
		PurchasableManager.add_child(PurchasableScene)
		PurchasableScene.setInfo(price_datastore)
	onFrameSprite()
	
	#for price_datastore: PriceDatastore in items:
		#var item: SavedData = price_datastore.data
		#var purchasable_packed: PackedScene
		#var parent: Control
		#
		#match item.getInfoType().getFofName():
			#"Card":
				#purchasable_packed = PurchasableCardPacked
				#parent = Cards
			#"ActionWrapper":
				#if item.hasType(RemoveFromDeckAction):
					#purchasable_packed = PurchasableRemovePacked
					#parent = RemoveCardPosition
				#elif item.hasType(TransformCardAction):
					#purchasable_packed = PurchasableTransformPacked
					#parent = TransformPosition
			#"Boon":
				#boon_ids.append(item.id)
					#
				#if item != null:
					#purchasable_packed = PurchasableBoonPacked
					#parent = Boons
			#"Tool":
				#purchasable_packed = PurchasableToolPacked
				#parent = Tools
		
		#var fof: FofGD = SavedData.onLoadModel(price_datastore.data, World.ActiveWorld)
		#if purchasable_packed == null: continue
		
		#var purchasable: Control = purchasable_packed.instantiate()
		#parent.add_child(purchasable)
		#purchasable.setInfo(fof, price_datastore, save_file)
		#
		#purchasable.create_screen.connect(onCreateScreen)
		#purchasable.pressed.connect(onItemPressed.bind(shop))
		
func onItemPressed(item: FofGD, price_datastore: PriceDatastore, DisplayedUI: Control, shop: MapNodeGD) -> void:
	price_datastore.bought = true
	shop.onPushAction(ChangeShillingsAction.new(-price_datastore.price))
	
	if item is CardGD:
		shop.onPushAction(AddToDeckAction.new(item))
		Game.onFlyToUI(DisplayedUI, UI.getDeckPanel())
		
	elif item is ToolGD:
		DisplayedUI.queue_free()
		
	elif item is BoonGD:
		shop.onForceAction(AddBoonAction.new(item.info.id, item.tier))
		Game.onFlyToUI(DisplayedUI, UI.BoonBox.onFindBoonIcon(item.info.id))
		
	World.ActiveWorld.onBuy()
	if item is ActionWrapper and !item.hasType(RemoveFromDeckAction): # Not remove card
		var NewCard: CardGD
		NewCard = item.getType(TransformCardAction)[0].NewCard
		DisplayedUI = await onFlipCardAnimation(DisplayedUI, NewCard)
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
	
func onFadeBackground() -> bool:
	return true
	
func getFadeBackgroundColor() -> Color:
	return map_node.getShopDatastore().getBackgroundMainColor()
	
func onCreateScreen(screen: Control) -> void:
	add_child(screen)
	
func _on_minimap_button_pressed() -> void:
	pass

const timer_time: float = 1.0
func onFrameSprite(start: int = 1) -> void:
	FrameMerchantSprite.texture = map_node.getShopDatastore().getMerchantFrames()[start - 1]
	await get_tree().create_timer(timer_time).timeout
	onFrameSprite(1 if start == 2 else 2)
	
