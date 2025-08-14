class_name ShopScreen extends MapNodeScreen

const TRANSFORM_WAIT_PRESSED_TIME: float = 1.5
const CARD_FLIP_TIME: float = 0.25

@export var ROWS: int = 6
@export var COLUMNS: int = 6
@export var H_SEPERATION: int = 100
@export var V_SEPERATION: int = 100

@onready var BackgroundIconContainer: Container = %BackgroundIconContainer
@onready var AniPlayer: AnimationPlayer = %AniPlayer
@onready var ShopMerchantUI: Control = %ShopMerchantUI
@onready var MapPanel: Control = %MapPanel
@onready var ExitButton: Control = %ExitButton
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

func setInfo(_save_file: SaveFileGD, _area: AreaGD, _World: Node3D, _UI: Control, shop: MapNodeGD) -> void:
	super(_save_file, _area, _World, _UI, shop)
	Game.update_stash_screen.connect(onUpdateStashScreen)
	for price_datastore: PriceDatastore in shop.getItems():
		var data: SavedData = price_datastore.getData()
		var PurchasableScene: Control = getPurchasableFromType(data.getInfoType()).instantiate()
		PurchasableManager.add_child(PurchasableScene)
		PurchasableScene.setInfo(price_datastore)
		PurchasableScene.pressed.connect(onItemPressed)
	
	FrameMerchantBase.texture = shop.getShopDatastore().getMerchantIconBase()
	onFrameSprite()
	onCreateBackgroundIcons()
		
func onItemPressed(price_datastore: PriceDatastore) -> void:
	map_node.onItemBought(price_datastore)
	is_buy = true
	onFrameSprite(1, map_node.getShopDatastore().getBuyFrame())
	

func _on_exit_button_pressed() -> void:
	finished.emit()
	
func onFadeBackground() -> bool:
	return true
	
func getFadeBackgroundColor() -> Color:
	return map_node.getShopDatastore().getBackgroundMainColor()
	
func onCreateScreen(screen: Control) -> void:
	add_child(screen)
	
var is_minimap_visible: bool
func _on_minimap_button_pressed() -> void:
	is_minimap_visible = !is_minimap_visible
	var nodes: Array = [ShopMerchantUI, PurchasableManager, BackgroundIconContainer]
	if !is_minimap_visible:
		for node: Control in nodes:
			node.visible = true

	var desired: float = int(!is_minimap_visible)
	var val: float = desired - ShopMerchantUI.modulate.a
	for node: Control in nodes:
		var tween := create_tween()
		tween.tween_property(node, "modulate:a", val, Game.FADE_TIME).as_relative()
	minimap_mode.emit(is_minimap_visible)
	
	await get_tree().create_timer(Game.FADE_TIME).timeout
	if is_minimap_visible:
		for node: Control in nodes:
			node.visible = false

var is_buy: bool
const SWAP_FRAME_TIME: float = 1.0
func onFrameSprite(start: int = 1, tx: Texture = map_node.getShopDatastore().getMerchantFrames()[start - 1]) -> void:
	FrameMerchantSprite.texture = tx
	await get_tree().create_timer(SWAP_FRAME_TIME).timeout
	if is_buy:
		is_buy = false
		return
	onFrameSprite(1 if start == 2 else 2)
	
func onUpdateStashScreen(created: bool) -> void:
	var end_value: float = 0.0 if created else 1.0
	for node: Control in [ExitButton, MapPanel, PurchasableManager, ShopMerchantUI]:
		var tween := create_tween()
		tween.tween_property(node, "modulate:a", end_value, Game.FADE_TIME)
		
func onCreateBackgroundIcons() -> void:
	AniPlayer.play("LoopBackgroundIcons")
	BackgroundIconContainer.columns = COLUMNS
	BackgroundIconContainer.add_theme_constant_override("h_separation", H_SEPERATION)
	BackgroundIconContainer.add_theme_constant_override("v_separation", V_SEPERATION)
	var icon: Texture2D = map_node.getShopDatastore().getBackgroundIcon()
	for __: int in range(COLUMNS * ROWS):
		var TxRect := TextureRect.new()
		TxRect.texture = icon
		BackgroundIconContainer.add_child(TxRect)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("AddToGroup1"):
		onCreateBackgroundIcons()
