extends Purchasable

@onready var BoonIcon: Control = %BoonIcon
@onready var NameLabel: FancyTextLabel = %NameLabel

func setInfo(_item: FofGD, _price_datastore: PriceDatastore, _save_file: SaveFileGD) -> void:
	super(_item, _price_datastore, _save_file)
	BoonIcon.setInfo(item, true)
	BoonIcon.onDisplayCharges(false)
	BoonIcon.pressed.connect(func(_x: BoonGD): onPressed())
	DisplayedUI = BoonIcon
	
	var text: String = "[" + str(item.tier) + "boon=" + str(item.info.id) + "]"
	NameLabel.setText(text)

func setDisabled(state: bool = true) -> void:
	super(state)
	BoonIcon.setDisabled(state)

func onPressed(load_bought: bool = false) -> void:
	super()
	ShillingsLabel.queue_free()
	NameLabel.queue_free()
	
	if load_bought: BoonIcon.queue_free()
