extends Purchasable

@onready var BoonIcon: Control = %BoonIcon

func setInfo(_price_datastore: PriceDatastore) -> void:
	var data: SavedDataBoon = _price_datastore.getData()
	data.public_id = 0
	
	var Boon: BoonGD = SavedData.onLoadModel(data, Game.getArea().getEnteredMapNode()) 
	
	BoonIcon.setInfo(Boon, true, false, true)
	BoonIcon.setSizeScale(2)
	BoonIcon.onShowNameLabel(-1)
	BoonIcon.onShowTierLabel(-1)
	BoonIcon.onDisplayCharges(false)
	BoonIcon.pressed.connect(func(_x: TbcUI): onPressed())
	DisplayedUI = BoonIcon
	super(_price_datastore)

func setDisabled(state: bool = true) -> void:
	super(state)
	BoonIcon.setDisabled(state)

	
