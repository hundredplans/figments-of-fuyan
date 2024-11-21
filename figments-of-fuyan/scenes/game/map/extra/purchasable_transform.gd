extends Purchasable
@onready var PanelButton: Control = %PanelButton
@onready var SoldLabel: Label = %SoldLabel

func setInfo(_item: FofGD, _price_datastore: PriceDatastore, save_file: SaveFileGD) -> void:
	super(_item, _price_datastore, save_file)
	var text: String = item.info.name
	PanelButton.setText(text)
	PanelButton.pressed.connect(onPressed)

func setDisabled(state: bool = true) -> void:
	super(state)
	PanelButton.setDisabled(state)
	
func onPressed() -> void:
	super()
	SoldLabel.visible = true
	PanelButton.setText("")
	setDisabled(true)
