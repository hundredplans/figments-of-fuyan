extends Purchasable

@onready var BoonIcon: Control = %BoonIcon
func setInfo(_item: FofGD, _price_datastore: PriceDatastore, save_file: SaveFileGD) -> void:
	super(_item, _price_datastore, save_file)
	BoonIcon.setInfo(item, true)
	BoonIcon.onDisplayCharges(false)
	BoonIcon.pressed.connect(func(_x: BoonGD): onPressed())
	DisplayedUI = BoonIcon

func setDisabled(state: bool = true) -> void:
	super(state)
	BoonIcon.setDisabled(state)

func onPressed() -> void:
	super()
	ShillingsLabel.queue_free()
