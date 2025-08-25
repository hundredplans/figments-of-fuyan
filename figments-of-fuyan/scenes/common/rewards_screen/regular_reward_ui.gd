extends Control

signal reward_taken
signal stash_screen_fade_in
signal stash_screen_fade_out

var StashScreen: Control

@export var ShillingsTexture: Texture2D
@export var BoonIconPacked: PackedScene
@export var ToolIconPacked: PackedScene

@onready var RewardTextManager: Control = %RewardTextManager
@onready var AniPlayer: AnimationPlayer = %AniPlayer
@onready var Main: Control = %Main
@onready var ClaimedLabel: Label = %ClaimedLabel
@onready var RewardDescription: FancyTextLabel = %RewardDescription
@onready var RewardTitle: FancyTextLabel = %RewardTitle
@onready var TextureControl: Control = %TextureControl

const TOOL_BOON_REWARD_TEXT_Y_OFFSET: int = 85
const CLAIMED_COLOR := Color(0.5, 0.5, 0.5, 1.0)
const TextureDisplaySize := Vector2(480, 480)
var reward: Reward

func setInfo(_reward: Reward) -> void:
	reward = _reward
	
	ClaimedLabel.modulate.a = 1.0 if reward.isTaken() else 0.0
	if reward.isTaken(): Main.modulate = CLAIMED_COLOR
		
	var item: FofGD = reward.getItem()
	var TextureDisplay: Control
	
	if item is ActionWrapper:
		var action: ChangeShillingsAction = item.getType(ChangeShillingsAction)[0]
		TextureDisplay = TextureRect.new()
		TextureDisplay.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		TextureDisplay.texture = ShillingsTexture
		TextureDisplay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var shillings: int = action.getDelta()
		RewardTitle.setText("%sx Shillings" % shillings)
		
	elif item is BoonGD:
		TextureDisplay = BoonIconPacked.instantiate()
		
	elif item is ToolGD:
		TextureDisplay = ToolIconPacked.instantiate()
		
	TextureControl.add_child(TextureDisplay)
	TextureControl.move_child(TextureDisplay, 0)
	
	if item is BoonGD:
		TextureDisplay.onDisplayCharges(false)
		TextureDisplay.setSizeScale(6)
	elif item is ToolGD:
		TextureDisplay.setSizeScale(12)
	
	AniPlayer.play("Idle")
	
	if item is BoonGD or item is ToolGD:
		RewardTextManager.position.y += TOOL_BOON_REWARD_TEXT_Y_OFFSET
		TextureDisplay.setInfo(item, true)
		TextureDisplay.onShowTierLabel()
		@warning_ignore("static_called_on_instance")
		var text: String = "[%s%s=%s]" % [item.tier, item.info.getFofName().to_lower(), item.info.id]
		RewardDescription.setText(item.getDescription())
		RewardTitle.setText(text)
		TextureDisplay.setMouseFilter(Control.MOUSE_FILTER_IGNORE)
	
	TextureDisplay.size = TextureDisplaySize
	
func setClaimButtonPressed(claim_button_pressed: Signal) -> void:
	claim_button_pressed.connect(onClaimButtonPressed)

func setClaimButtonDown(claim_button_down: Signal) -> void:
	claim_button_down.connect(onClaimButtonDown)

func onClaimButtonPressed() -> void:
	if reward.isTaken(): return
	var item: FofGD = reward.getItem()
	if item is ActionWrapper:
		var action: ChangeShillingsAction = item.getType(ChangeShillingsAction)[0]
		Game.getSaveFile().onPushAction(action)
		onRewardTaken()
	elif item is BoonGD:
		Game.getSaveFile().onPushAction(AddBoonAction.new(item.info.id, item.tier))
		onRewardTaken()
	
func onClaimButtonDown() -> void:
	if reward.isTaken() or StashScreen != null: return
	var item: FofGD = reward.getItem()
	if item is ToolGD:
		var ToolIcon: Control = ToolIconPacked.instantiate()
		add_child(ToolIcon)
		ToolIcon.setInfo(item, false)
		ToolIcon.setSizeScale(3)
		ToolIcon.setDisableTooltip(true)
		ToolIcon.global_position = get_viewport().get_mouse_position() - ToolIcon.pivot_offset
		
		StashScreen = Game.onCreateStashScreen(self, ToolIcon)
		stash_screen_fade_in.emit()
		StashScreen.active_tool_added.connect(onToolClaimed.bind(ToolIcon))
		StashScreen.exit_start.connect(onActiveToolStashExitStart.bind(ToolIcon))
	
func onRewardTaken() -> void:
	reward.setTaken(true)
	
	var label_tween := create_tween()
	label_tween.tween_property(ClaimedLabel, "modulate:a", 1.0, Game.FADE_TIME)
	
	var tween := create_tween()
	tween.tween_property(Main, "modulate", CLAIMED_COLOR, Game.FADE_TIME)
	reward_taken.emit(reward)
	
func onRemoveActiveToolIcon(ToolIcon: Variant) -> void:
	if ToolIcon != null: ToolIcon.queue_free()
	
func onActiveToolStashExitStart(ToolIcon: Variant) -> void:
	onRemoveActiveToolIcon(ToolIcon)
	stash_screen_fade_out.emit()

func onToolClaimed(_CardUI: Control, ToolIcon: Control) -> void:
	onRemoveActiveToolIcon(ToolIcon)
	onRewardTaken()
