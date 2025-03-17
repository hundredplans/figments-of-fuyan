extends Control

@export var card_icon: Texture2D
@export var miniboss_icon: Texture2D
@export var boss_icon: Texture2D

@export var shilling_icon: Texture2D
@onready var IconRect: TextureRect = %IconRect
@onready var ItemLabel: FancyTextLabel = %ItemLabel
@onready var MainContainer: PanelContainer = %MainContainer
@onready var AmountLabel: Label = %AmountLabel

signal mouse_signal
signal pressed

const TAKEN_COLOR := Color(0.2, 0.2, 0.2)

var taken: bool
var item: Variant
func setInfo(_item: Variant, is_taken: bool = false) -> void:
	item = _item
	if item is ActionWrapper and item.hasType(ChangeShillingsAction):
		MainContainer.theme_type_variation = "WhitePanelContainer"
		IconRect.texture = shilling_icon
		ItemLabel.setText("Shillings")
		AmountLabel.text = str(item.getType(ChangeShillingsAction)[0].getDelta())
		
	elif item is ActionWrapper and item.hasType(ChooseRewardAction):
		var action: ChooseRewardAction = item.getType(ChooseRewardAction)[0]
		var icon_texture: Texture2D
		var text: String = ""
		var theme_variation: String = ""
		if action.items.all(func(x: FofGD): return x.info.rarity == Game.Rarities.MINIBOSS):
			icon_texture = miniboss_icon
			text = "Miniboss"
			theme_variation = "PurplePanelContainer"
		elif action.items.all(func(x: FofGD): return x.info.rarity == Game.Rarities.BOSS):
			icon_texture = boss_icon
			text = "Boss"
			theme_variation = "RedPanelContainer"
		else:
			icon_texture = card_icon
			text = "Cards"
			theme_variation = "WhitePanelContainer"
			
		MainContainer.theme_type_variation = theme_variation
		IconRect.texture = icon_texture
		ItemLabel.setText(text)
		
	elif item is BoonGD or item is ToolGD or item is CardGD:
		MainContainer.theme_type_variation = Game.getRarityThemeVariation(item.info.rarity, item.getAscended())
		
		var text: String = ItemLabel.onReplaceCardName(item.info.getFofName(), item.ascended, item.info.rarity)
		ItemLabel.setText(text)
		IconRect.texture = item.getIcon()
		
	setTaken(is_taken)

var mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	modulate = (Color(0.5, 0.5, 0.5) if (state) else Color(1, 1, 1)) if !taken else TAKEN_COLOR
	mouse_in_ui = state
	mouse_signal.emit(mouse_in_ui)
	
	if !taken and (item is BoonGD or item is ToolGD):
		Game.onMouseInUITooltip(mouse_in_ui, item, self, true)
		
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("MainInput") and mouse_in_ui and !taken:
		pressed.emit(item)
		
func setTaken(state: bool) -> void:
	taken = state
	if taken:
		IconRect.texture = null
		modulate = Color(TAKEN_COLOR)
		Game.onMouseInUITooltip(false)
		AmountLabel.text = ""
	
