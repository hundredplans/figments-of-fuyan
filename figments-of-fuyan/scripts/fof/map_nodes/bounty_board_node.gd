extends MapNodeGD

#Changes to Bounty Board
#Start at 8 SH (+4 SH per uses in the arena) (Duels count as 2 kills) (energy rules for the kills)
#You can choose between +1 ATT or +1 HP
#
#1 KILL
#5 KILL
#10 KILL
#20 KILL
#50 KILL
#100 KILL
	
	
func onEntered() -> void:
	super()
	onCreateScreen()
