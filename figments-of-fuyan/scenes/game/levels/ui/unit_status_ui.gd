extends HBoxContainer

@export var ACTIVE_COLOR: Color
@export var PASSED_TURN_STATE_COLOR := Color("#888888")
@export var UnitStatusUIStatsManagerSmallPacked: PackedScene
@export var UnitStatusUIStatsManagerBigPacked: PackedScene
@onready var ArtMiniBox: Control = %ArtMiniBox

var AttackLabel: Label
var HealthLabel: Label
var SpeedLabel: Label

var AttackTween: Tween
var HealthTween: Tween
var SpeedTween: Tween

@onready var VisibleTxRect: TextureRect = %VisibleTxRect

var Card: CardGD
var is_spectated: bool
var flip_tooltip: bool
var is_big_stats: bool
var in_vision_range: bool

var disabled: bool
var UnitStatusUIStatsManager: Control

const SCALE_IN_TIME: float = 0.2	
signal pressed
signal mouse_in_ui

func setInfo(_is_big_stats: bool = false, _flip_tooltip: bool = false, _alignment := BoxContainer.ALIGNMENT_END) -> void:
	is_big_stats = _is_big_stats
	flip_tooltip = _flip_tooltip
	UnitStatusUIStatsManager = (UnitStatusUIStatsManagerBigPacked\
		if is_big_stats else UnitStatusUIStatsManagerSmallPacked).instantiate()
	
	add_child(UnitStatusUIStatsManager)
	
	if flip_tooltip:
		move_child(UnitStatusUIStatsManager, 0)
	
	AttackLabel = UnitStatusUIStatsManager.getAttackLabel()
	HealthLabel = UnitStatusUIStatsManager.getHealthLabel()
	SpeedLabel = UnitStatusUIStatsManager.getSpeedLabel()
	
	alignment = _alignment
	setInVisionRange(false)
	
func setCard(_Card: CardGD) -> void:
	var OldCard: CardGD = Card
	Card = _Card
	
	if OldCard != null and OldCard.is_connected("update_turn_state", onUpdateTurnState):
		OldCard.disconnect("update_turn_state", onUpdateTurnState)
		OldCard.disconnect("update_stat", onUpdateStat)
		OldCard.disconnect("update_level_visible", onUpdateLevelVisible)
	Card.update_turn_state.connect(onUpdateTurnState)
	Card.update_stat.connect(onUpdateStat)
	Card.update_level_visible.connect(onUpdateLevelVisible)
		
	if is_big_stats:
		UnitStatusUIStatsManager.setCard(Card)
	
	onUpdateStat(Game.Stats.ATTACK, Card.getAttack(), false, true)
	onUpdateStat(Game.Stats.HEALTH, Card.getHealth(), false, true)
	onUpdateStat(Game.Stats.SPEED, Card.getSpeed(), false, true)
	onUpdateLevelVisible(Card.isLevelVisible())
	onUpdateTurnState(Card.getTurnState(), true)
	
	ArtMiniBox.setInfo(Card.onSave(), true)
	onUpdateBorderColor(true)
	
func onUpdateStat(type: Game.Stats, value: int, show_particles: bool = true, instant: bool = false) -> void:
	if type not in [Game.Stats.ATTACK, Game.Stats.HEALTH, Game.Stats.SPEED]: return
	
	var tween: Tween
	var label: Label
	var above_green_value: int
	var below_red_value: int
	var stat_datastore := Card.getStatsFromInfo()
	match type:
		Game.Stats.ATTACK:
			label = AttackLabel
			if !instant:
				if AttackTween: AttackTween.kill()
				AttackTween = create_tween()
			tween = AttackTween
			above_green_value = stat_datastore.attack
			below_red_value = stat_datastore.attack
		Game.Stats.HEALTH:
			label = HealthLabel
			if !instant:
				if HealthTween: HealthTween.kill()
				HealthTween = create_tween()
			tween = HealthTween
			above_green_value = stat_datastore.health
			below_red_value = Card.getMaxHealth()
		Game.Stats.SPEED:
			label = SpeedLabel
			if !instant:
				if SpeedTween: SpeedTween.kill()
				SpeedTween = create_tween()
			tween = SpeedTween
			above_green_value = stat_datastore.speed
			below_red_value = value
	
	label.pivot_offset = label.size / 2.0
	
	if !instant:
		tween.tween_property(label, "scale:x", 0.01, SCALE_IN_TIME)
		tween.tween_callback(onUpdateStatLabelText.bind(label, value, above_green_value, below_red_value))
		tween.tween_property(label, "scale:x", 1.0, SCALE_IN_TIME)
	else: label.text = str(value); onUpdateStatLabelText(label, value, above_green_value, below_red_value)
	
func onUpdateStatLabelText(label: Label, value: int, above_green_value: int, below_red_value: int) -> void:
	label.text = str(value)
	var label_color := Color.WHITE
	if value < below_red_value: label_color = Color.RED
	elif value > above_green_value: label_color = Color.GREEN
	label.modulate = label_color
	
func onUpdateLevelVisible(_is_level_visible: bool) -> void:
	onUpdateVisible()
	
func onUpdateVisible() -> void:
	visible = Card.isLevelVisible() and !is_spectated

func setSpectated(_is_spectated: bool) -> void:
	is_spectated = _is_spectated
	onUpdateVisible()

func getCard() -> CardGD: return Card

var TurnStateTween: Tween
func onUpdateTurnState(turn_state: Game.TurnStates, instant: bool = false) -> void:
	if turn_state == Game.TurnStates.NULL: return
	
	var turn_state_to_color: Color
	match turn_state:
		Game.TurnStates.PASSED: turn_state_to_color = PASSED_TURN_STATE_COLOR
		Game.TurnStates.INACTIVE: turn_state_to_color = Color.WHITE
		Game.TurnStates.ACTIVE: turn_state_to_color = Color.WHITE
	
	if TurnStateTween: TurnStateTween.kill()
	if modulate != turn_state_to_color:
		if !instant:
			TurnStateTween = create_tween()
			TurnStateTween.tween_property(self, "modulate", turn_state_to_color, Game.FADE_TIME)
		else: modulate = turn_state_to_color
	onUpdateBorderColor(true)
		
func setInVisionRange(state: bool) -> void:
	in_vision_range = state
	VisibleTxRect.visible = state
	
func getInVisionRange() -> bool: return in_vision_range

func onPressed() -> void:
	if disabled: return
	pressed.emit(Card)
	
func setDisabled(state: bool) -> void:
	disabled = state

func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
	Game.onMouseInUITooltip(state, Card, self, true, flip_tooltip)

func onUpdateTool(Tool: ToolGD) -> void:
	ArtMiniBox.setToolData(Tool.onSave() if Tool != null else null)

func onUpdateBorderColor(instant: bool) -> void:
	var team_color: Color = Game.getTeamColor(Card.getTeam())
	ArtMiniBox.setBorderColor(team_color if Card.getTurnState() != Game.TurnStates.ACTIVE else ACTIVE_COLOR, instant)
