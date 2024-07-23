extends ToolGD

var speed_duration: int = 2
var turn_count: int = 0
func onTrigger(_Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if trigger == TriggerGD.EQUIP_TOOL and args.Tool == self:
		if Unit.Tile not in Vision.getTeamVision(TeamRelationGD.new(Unit.team, "Enemy")):
			Units.changeStats(StatInfoGD.new(Unit, AppliedByGD.new(AppliedByGD.TOOL, self), StatsGD.BOTH_SPEED, 1, speed_duration))
		else: Tools.onBreak(self)
	elif trigger == TriggerGD.START_TURN_GLOBAL and args.team_relation.onTeam() == Unit.team:
		turn_count += 1
		if turn_count == speed_duration: Tools.onBreak(self)
			
