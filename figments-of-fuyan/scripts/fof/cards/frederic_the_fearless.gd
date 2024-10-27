extends CardGD

#region Constants
const extra_elite_chief_odds: float = 0.03
#endregion

# -> +1 hp on upgrade

# 3% higher chance for elites / chiefs
# Higher chance of getting fights from random encounters
# Every 4th fight add an extra charge to your boon 

func onProcessAction(action: Action) -> void:
	if isValidRampage(action):
		onPushAction(RampageAction.new(self, action))

func onRampage(action: DeathAction) -> void:
	onPushAction(StatAction.new(StatInfo.new(self, Game.Stats.MAX_HEALTH, 1)))
