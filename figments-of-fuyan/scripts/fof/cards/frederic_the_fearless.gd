extends CardGD

#region Constants
const extra_elite_odds: float = 0.03
const ANIMATION_DELAY: float = 2.0
#endregion

# -> +1 hp on upgrade

# 3% higher chance for elites
# Higher chance of getting fights from random encounters
# Every 4th fight add an extra charge to your boon 

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidRampage(action):
		onPushAction(RampageAction.new(self, action))

func onRampage(_action: DeathAction) -> void:
	var stat_infos: Array = [StatInfo.new(self, [Game.Stats.MAX_HEALTH, Game.Stats.HEALTH], [1, 1])]
	if Game.getChampionLevel() >= 2:
		stat_infos.append(StatInfo.new(self, Game.Stats.HEALTH, 1))

	var camera_change_action := CameraChangeAction.new(self)
	var animation_action := AnimationAction.new(self, "Ability")
	animation_action.setActionDelay(ANIMATION_DELAY)
	
	onPushAction([camera_change_action, animation_action, StatAction.new(stat_infos)])
