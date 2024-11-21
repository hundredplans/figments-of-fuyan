extends Purchasable

@onready var ToolIcon: Control = %ToolIcon

func setInfo(_item: FofGD, _price_datastore: PriceDatastore, save_file: SaveFileGD) -> void:
	super(_item, _price_datastore, save_file)
	ToolIcon.setInfo(item, true)
	ToolIcon.pressed.connect(func(_x: ToolGD): onPressed())
	DisplayedUI = ToolIcon
	
func setDisabled(state: bool) -> void:
	super(state)
	ToolIcon.setDisabled(state)

func onPressed() -> void:
	super()
	ToolIcon.queue_free()
	ShillingsLabel.queue_free()
