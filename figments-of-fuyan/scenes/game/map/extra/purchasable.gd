class_name Purchasable extends Control

signal pressed
@warning_ignore("unused_signal")
signal create_screen

var item: FofGD
var save_file: SaveFileGD
var DisplayedUI: Control
var price_datastore: PriceDatastore

@onready var ShillingsLabel: FancyTextLabel = %ShillingsLabel

func setInfo(_item: FofGD, _price_datastore: PriceDatastore, _save_file: SaveFileGD) -> void:
	item = _item
	price_datastore = _price_datastore
	save_file = _save_file
	
	ShillingsLabel.setText("SH: " + str(price_datastore.price))
	Game.getSaveFile().update_shillings.connect(onUpdateShillings)
	onUpdateShillings()
	
	if price_datastore.bought: onPressed(true)

func onUpdateShillings() -> void:
	if !price_datastore.bought:
		setDisabled(price_datastore.price > Game.getSaveFile().getShillings())

func setDisabled(state: bool) -> void:
	ShillingsLabel.modulate = Color(1, 1, 1) if !state else Color(0.5, 0.5, 0.5)

func onPressed(load_bought: bool = false) -> void:
	if load_bought: return
	pressed.emit(item, price_datastore, DisplayedUI)
	setDisabled(true)
