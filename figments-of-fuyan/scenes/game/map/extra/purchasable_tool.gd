extends Purchasable
@onready var ToolIcon: Control = %ToolIcon
@onready var NameLabel: Label = %NameLabel
@export var ToolPickedUpUIPacked: PackedScene

func setInfo(_item: FofGD, _price_datastore: PriceDatastore, _save_file: SaveFileGD) -> void:
	super(_item, _price_datastore, _save_file)
	ToolIcon.setInfo(item, true)
	ToolIcon.pressed.connect(onToolSelected)
	DisplayedUI = ToolIcon
	NameLabel.text = item.info.name
	NameLabel.modulate = Game.getRarityColor(item.info.rarity)
	
func onToolSelected(Tool: ToolGD) -> void:
	var ToolPickedUpUI: Control = ToolPickedUpUIPacked.instantiate()
	create_screen.emit(ToolPickedUpUI)
	ToolPickedUpUI.setInfo(Tool, save_file, true)
	ToolPickedUpUI.taken.connect(func(_x: ToolGD): onPressed())
	
func setDisabled(state: bool) -> void:
	super(state)
	ToolIcon.setDisabled(state)

func onPressed(load_bought: bool = false) -> void:
	super()
	ShillingsLabel.queue_free()
	NameLabel.queue_free()
	
	if load_bought: ToolIcon.queue_free()
