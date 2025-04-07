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

var reward: Reward
func setInfo(_reward: Reward) -> void:
	reward = _reward
	if reward.item is ActionWrapper and reward.item.hasType(ChangeShillingsAction):
		MainContainer.theme_type_variation = "WhitePanelContainer"
		IconRect.texture = shilling_icon
		ItemLabel.setText("Shillings")
		AmountLabel.text = str(reward.item.getType(ChangeShillingsAction)[0].getDelta())
		
	elif reward.item is ActionWrapper and reward.item.hasType(ChooseRewardAction):
		var action: ChooseRewardAction = reward.item.getType(ChooseRewardAction)[0]
		var icon_texture: Texture2D
		var text: String = ""
		var theme_variation: String = ""
		match action.reward_type:
			ChooseRewardAction.RewardType.CARDS:
				icon_texture = card_icon
				text = "Cards"
				theme_variation = "WhitePanelContainer"
			ChooseRewardAction.RewardType.MINIBOSS:
				icon_texture = miniboss_icon
				text = "Miniboss"
				theme_variation = "PurplePanelContainer"
			ChooseRewardAction.RewardType.BOSS:
				icon_texture = boss_icon
				text = "Boss"
				theme_variation = "RedPanelContainer"
			
		MainContainer.theme_type_variation = theme_variation
		IconRect.texture = icon_texture
		ItemLabel.setText(text)
		
	elif reward.item is BoonGD or reward.item is ToolGD or reward.item is CardGD:
		MainContainer.theme_type_variation = Game.getRarityThemeVariation(reward.item.info.rarity, reward.item.getAscended())
		
		var text: String = ItemLabel.onReplaceCardName(reward.item.info.getFofName(), reward.item.ascended, reward.item.info.rarity)
		ItemLabel.setText(text)
		IconRect.texture = reward.item.getIcon()
		
	setTaken(reward.taken)

var mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	modulate = (Color(0.5, 0.5, 0.5) if (state) else Color(1, 1, 1)) if !reward.taken else TAKEN_COLOR
	mouse_in_ui = state
	mouse_signal.emit(mouse_in_ui)
	
	if !reward.taken and (reward.item is BoonGD or reward.item is ToolGD):
		Game.onMouseInUITooltip(mouse_in_ui, reward.item, self, true)
		
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("MainInput") and mouse_in_ui and !reward.taken:
		pressed.emit(reward)
		
func setTaken(state: bool) -> void:
	if state:
		IconRect.texture = null
		modulate = Color(TAKEN_COLOR)
		Game.onMouseInUITooltip(false)
		AmountLabel.text = ""
	
