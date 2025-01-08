extends MapNodeGD
#How many nodes you've been to that are holy vs unholy
#8 nodes to visit per world (ignores miniboss, boss)
#Can cash out at each to either holy or unholy
#Can't reclaim the same rewards
#
#Pray to Holy - 
#1 -
#5 - 
#10 - 
#20 - 
#
#Pray to Unholy -
#1 -
#5 -
#10 - 
#20 -
	
func onEntered() -> void:
	super()
	onCreateScreen()
	
