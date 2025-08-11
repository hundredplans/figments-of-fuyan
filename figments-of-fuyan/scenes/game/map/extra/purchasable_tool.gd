extends Purchasable

@onready var ToolIcon: Control = %ToolIcon

func setInfo(_price_datastore: PriceDatastore) -> void:
	var data: SavedDataTool = _price_datastore.getData()
	data.public_id = 0
	
	var Tool: ToolGD = SavedData.onLoadModel(data, Game.getArea().getEnteredMapNode()) 
	ToolIcon.setInfo(Tool, true)
	ToolIcon.pressed.connect(onToolSelected)
	DisplayedUI = ToolIcon
	super(_price_datastore)
	
func onToolSelected(_Tool: ToolGD) -> void:
	ToolIcon.top_level = true
	ToolIcon.setDisableTooltip(true)
	Game.onEmptyTooltip(false)
	
	var StashScreen: Control = Game.onCreateStashScreen(self, ToolIcon)
	StashScreen.exit_start.connect(onStashScreenExit)
	StashScreen.global_position = Vector2.ZERO
	StashScreen.active_tool_added.connect(func(_CardUI: Control): onPressed())
	
func onStashScreenExit() -> void:
	if ToolIcon == null: return
	ToolIcon.position = Vector2.ZERO
	ToolIcon.top_level = false
	ToolIcon.setDisableTooltip(false)
	
func setDisabled(state: bool) -> void:
	super(state)
	ToolIcon.setDisabled(state)
	
	
