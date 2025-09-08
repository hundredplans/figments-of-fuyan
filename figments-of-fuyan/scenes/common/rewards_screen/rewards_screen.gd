extends Control

signal screen_finished
signal stash_screen_fade_in
signal stash_screen_fade_out

const FADE_IN_TIME: float = 0.25

signal claim_button_pressed
signal claim_button_down

@export var RegularRewardUIPacked: PackedScene
@export var ChooseCardRewardUIPacked: PackedScene
@export var EpicRewardUIPacked: PackedScene

@onready var ExitButton: Control = %ExitButton
@onready var ClaimInfoLabel: Label = %ClaimInfoLabel
@onready var FadeCreamBackground: Control = %FadeCreamBackground
@onready var MinimapControl: Control = %MinimapControl
@onready var RewardsLabel: Label = %RewardsLabel
@onready var Main: Control = %Main

@onready var ViewStashButton: Control = %ViewStashButton

@onready var LeftArrowButton: Control = %LeftArrowButton
@onready var RightArrowButton: Control = %RightArrowButton

var is_page_reward_taken: bool
var rewards_ui: Control
var rewards: Rewards
var page: int

func setInfo(_rewards: Rewards, _level_type: Game.FightTypes) -> void:
	rewards = _rewards
	
	var main_color: Color = Game.getArea().getInfo().getAreaColor()
	var secondary_color: Color = Game.getArea().getInfo().getSecondAreaColor()
	var tertiary_color: Color = Game.getArea().getInfo().getThirdAreaColor()
	
	FadeCreamBackground.FADE_COLOR = main_color
	FadeCreamBackground.color = main_color
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_viewport().update_mouse_cursor_state()
	
	onFadeInMain()
	setExitButtonText()
	setRewardsLabelText()
	setRewardUI()
	
	LeftArrowButton.BASE_COLOR = main_color
	LeftArrowButton.HOVER_COLOR = secondary_color
	LeftArrowButton.DISABLED_COLOR = tertiary_color
	LeftArrowButton.setModulate()
	
	RightArrowButton.BASE_COLOR = main_color
	RightArrowButton.HOVER_COLOR = secondary_color
	RightArrowButton.DISABLED_COLOR = tertiary_color
	RightArrowButton.setModulate()
	
	ViewStashButton.BASE_COLOR = main_color
	ViewStashButton.HOVER_COLOR = secondary_color
	ViewStashButton.DISABLED_COLOR = tertiary_color
	ViewStashButton.setModulate()
	
	ExitButton.BASE_COLOR = main_color
	ExitButton.HOVER_COLOR = secondary_color
	ExitButton.DISABLED_COLOR = tertiary_color
	ExitButton.setModulate()
	
func setRewardUI() -> void:
	if rewards_ui != null: rewards_ui.queue_free()
	var reward: Reward = getRewardByPage()
	var item: FofGD = reward.getItem()
	var rewards_ui_packed: PackedScene
	is_page_reward_taken = reward.isTaken()
	
	if is_instance_of(item, ActionWrapper):
		if item.hasType(ChooseRewardAction):
			var action: ChooseRewardAction = item.getType(ChooseRewardAction)[0]
			if action.reward_type == ChooseRewardAction.RewardType.CARDS:
				rewards_ui_packed = ChooseCardRewardUIPacked
				setClaimInfoLabel(ChooseCardRewardUIPacked, reward)
			elif action.reward_type in [ChooseRewardAction.RewardType.MINIBOSS, ChooseRewardAction.RewardType.BOSS]:
				rewards_ui_packed = EpicRewardUIPacked
				setClaimInfoLabel(EpicRewardUIPacked, reward)
		elif item.hasType(ChangeShillingsAction):
			rewards_ui_packed = RegularRewardUIPacked
			setClaimInfoLabel(RegularRewardUIPacked, reward)
	elif is_instance_of(item, ToolGD) or is_instance_of(item, BoonGD):
		rewards_ui_packed = RegularRewardUIPacked
		setClaimInfoLabel(RegularRewardUIPacked, reward)
	
	rewards_ui = rewards_ui_packed.instantiate()
	Main.add_child(rewards_ui)
	rewards_ui.setInfo(reward)
	rewards_ui.reward_taken.connect(onRewardTaken)
	
	if rewards_ui_packed == RegularRewardUIPacked:
		rewards_ui.setClaimButtonPressed(claim_button_pressed)
		rewards_ui.setClaimButtonDown(claim_button_down)
		
	if rewards_ui_packed in [RegularRewardUIPacked, EpicRewardUIPacked]:
		rewards_ui.stash_screen_fade_in.connect(onStashScreenFadeIn)
		rewards_ui.stash_screen_fade_out.connect(onStashScreenFadeOut)
	
func getRewardByPage() -> Reward:
	return rewards.getReward(page)
	
func setExitButtonText() -> void:
	ExitButton.text = "Skip" if !rewards.isAllRewardsTaken() else "Continue"
	
func setRewardsLabelText() -> void:
	RewardsLabel.text = "Rewards [%s/%s]" % [page + 1, rewards.items.size()]
	
func onExitButtonPressed() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.BLACK, Game.FADE_TIME)
	
	Game.getSaveFile().onPushAction(StartLoadingScreenAction.new(
		Game.LoadingType.MAP,
		Game.getArea().getInfo().id
	))
	await get_tree().process_frame
	screen_finished.emit()
	
func onFadeInMain() -> void:
	FadeCreamBackground.onFade(true)
	Main.modulate.a = 0
	var tween := create_tween()
	tween.tween_property(Main, "modulate:a", 1.0, FADE_IN_TIME)

func onViewStashButtonPressed() -> void:
	var StashScreen: Control = Game.onCreateStashScreen(Main)
	if StashScreen == null: return
	onStashScreenFadeIn()
	StashScreen.exit_start.connect(onStashScreenFadeOut)

func onStashScreenFadeIn() -> void:
	stash_screen_fade_in.emit()
	for label: Label in [RewardsLabel, ClaimInfoLabel]:
		var tween := create_tween()
		tween.tween_property(label, "modulate:a", 0.0, Game.FADE_TIME)

func onStashScreenFadeOut() -> void:
	stash_screen_fade_out.emit()
	for label: Label in [RewardsLabel, ClaimInfoLabel]:
		var tween := create_tween()
		tween.tween_property(label, "modulate:a", 1.0, Game.FADE_TIME)

func onArrowButtonPressed(direction: int) -> void:
	var max_page: int = rewards.items.size() - 1
	page += direction
	
	if page < 0: page = max_page
	elif page > max_page: page = 0
	
	setRewardsLabelText()
	setRewardUI()

func onClaimButtonPressed() -> void:
	if !is_page_reward_taken:
		claim_button_pressed.emit()
	else:
		onArrowButtonPressed(1)
	
func setClaimInfoLabel(reward_ui_packed: PackedScene, reward: Reward) -> void:
	var text: String
	match reward_ui_packed:
		RegularRewardUIPacked: text = "(Click anywhere to claim!)"
		EpicRewardUIPacked: text = "(Choose an Epic Reward!)"
		ChooseCardRewardUIPacked: text = "(Choose a Card!)"
	ClaimInfoLabel.text = text
	setClaimInfoLabelModulate(reward)

func onClaimButtonDown() -> void:
	claim_button_down.emit()
	
func onRewardTaken(reward: Reward) -> void:
	setExitButtonText()
	setClaimInfoLabelModulate(reward)
	is_page_reward_taken = true
	
func setClaimInfoLabelModulate(reward: Reward) -> void:
	ClaimInfoLabel.modulate = Color(0.5, 0.5, 0.5, 1.0) if reward.isTaken() else Color.WHITE
