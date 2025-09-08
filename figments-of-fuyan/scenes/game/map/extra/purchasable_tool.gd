extends Purchasable

@onready var ToolIcon: Control = %ToolIcon

func setInfo(_price_datastore: PriceDatastore) -> void:
	var data: SavedDataTool = _price_datastore.getData()
	data.public_id = 0
	
	var Tool: ToolGD = SavedData.onLoadModel(data, Game.getArea().getEnteredMapNode()) 
	ToolIcon.setInfo(Tool, true, false, true)
	ToolIcon.setSizeScale(4)
	ToolIcon.onShowNameLabel(-1)
	ToolIcon.onShowTierLabel(-1)
	ToolIcon.pressed.connect(onToolSelected)
	DisplayedUI = ToolIcon
	super(_price_datastore)
	
func onToolSelected(_ToolIcon: Control) -> void:
	await get_tree().process_frame # Wait so that pressed doesn't trigger twice
	var StashScreen: Control = Game.onCreateStashScreen(get_parent().get_parent(), ToolIcon)
	if StashScreen == null: return
	StashScreen.global_position = Vector2.ZERO
	StashScreen.active_tool_added.connect(func(_CardUI: Control): onPressed())
	
func setDisabled(state: bool) -> void:
	super(state)
	ToolIcon.setDisabled(state)
	
	
