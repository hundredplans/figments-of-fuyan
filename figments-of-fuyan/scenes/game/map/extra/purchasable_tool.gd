extends Purchasable

@onready var ToolIcon: Control = %ToolIcon
@onready var NameLabel: FancyTextLabel = %NameLabel

func setInfo(_item: FofGD, _price_datastore: PriceDatastore, _save_file: SaveFileGD) -> void:
	super(_item, _price_datastore, _save_file)
	ToolIcon.setInfo(item, true)
	ToolIcon.pressed.connect(onToolSelected)
	DisplayedUI = ToolIcon
	
	var text: String = "[" + ("a" if item.ascended else "") + "tool=" + str(item.info.id) + "]"
	NameLabel.setText(text)
	
func onToolSelected(Tool: ToolGD) -> void:
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

func onPressed(load_bought: bool = false) -> void:
	super()
	ShillingsLabel.queue_free()
	NameLabel.queue_free()
	
	if load_bought: ToolIcon.queue_free()
