extends Purchasable

@onready var MainContainer: Container = %MainContainer

func setInfo(_item: FofGD, _price_datastore: PriceDatastore, save_file: SaveFileGD) -> void:
	DisplayedUI = _item.onCreateCardUI(MainContainer, true)
	super(_item, _price_datastore, save_file)
	
	DisplayedUI.pressed.connect(func(x: Control): onPressed())
	MainContainer.move_child(DisplayedUI, 0)
	
func setDisabled(state: bool = true) -> void:
	super(state)
	DisplayedUI.setDisabled(state)

func onPressed(load_bought: bool = false) -> void:
	super()
	ShillingsLabel.queue_free()
	
	if load_bought: DisplayedUI.queue_free()
	
	
