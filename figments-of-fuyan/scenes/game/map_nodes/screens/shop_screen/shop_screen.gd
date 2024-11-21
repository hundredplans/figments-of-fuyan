extends Control

signal finished

var save_file: SaveFileGD
var UI: Control

const BUY_ANIMATION_SPEED: float = 1
const BUY_ITEM_DISSAPEAR_SPEED: float = 1.2

@onready var Cards: Control = %Cards
@onready var RemoveCardPosition: Control = %RemoveCardPosition

@onready var Boons: Control = %Boons
@onready var Tools: Control = %Tools
@onready var TransformPosition: Control = %TransformPosition

@export var PurchasableCardPacked: PackedScene
@export var PurchasableRemovePacked: PackedScene
@export var PurchasableBoonPacked: PackedScene
@export var PurchasableToolPacked: PackedScene
@export var PurchasableTransformPacked: PackedScene

func setInfo(_save_file: SaveFileGD, _area: AreaGD, World: Node3D, _UI: Control, map_node: MapNodeGD) -> void:
	UI = _UI
	save_file = _save_file
	var items: Array = map_node.items

	for price_datastore in items:
		var item: SavedData = price_datastore.data
		var fof: FofGD = SavedData.onLoadModel(price_datastore.data, World.ActiveWorld)
		var purchasable_packed: PackedScene
		var parent: Control
		
		match fof.info.getFofName():
			"Card":
				purchasable_packed = PurchasableCardPacked
				parent = Cards
			"MapEffect":
				if fof.info.id == 3:
					purchasable_packed = PurchasableRemovePacked
					parent = RemoveCardPosition
				else:
					purchasable_packed = PurchasableTransformPacked
					parent = TransformPosition
			"Boon":
				purchasable_packed = PurchasableBoonPacked
				parent = Boons
			"Tool":
				purchasable_packed = PurchasableToolPacked
				parent = Tools
		
		var purchasable: Control = purchasable_packed.instantiate()
		parent.add_child(purchasable)
		purchasable.setInfo(fof, price_datastore, save_file)
		purchasable.pressed.connect(onItemPressed)
		
func onItemPressed(item: FofGD, price_datastore: PriceDatastore, DisplayedUI: Control) -> void:
	price_datastore.bought = true
	save_file.onUpdateShillings(-price_datastore.price)
	
	if item is CardGD:
		Game.onAddToDeck(item)
		onBuyAnimation(DisplayedUI)
		
	# Add buying item here

func _on_exit_button_pressed() -> void:
	finished.emit()
	
func onDimBackground() -> bool:
	return false
	
func onBuyAnimation(CardUI: Control) -> void:
	var panel: Control = UI.DeckPanel
	
	var tween := create_tween()
	tween.tween_property(CardUI, "global_position", panel.global_position, BUY_ANIMATION_SPEED)
	
	var scale_tween := create_tween()
	scale_tween.tween_property(CardUI, "scale", Vector2(0.01, 0.01), BUY_ANIMATION_SPEED)
	
	var rotate_tween := create_tween()
	rotate_tween.tween_property(CardUI, "rotation_degrees", 360, BUY_ANIMATION_SPEED)
	
	await get_tree().create_timer(BUY_ITEM_DISSAPEAR_SPEED).timeout
	CardUI.queue_free()
	
	
