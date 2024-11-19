class_name StartNodeGD extends MapNodeGD

func onFofInit() -> void:
	super()
	is_entered = true
	is_finished = true
	onAfterLoadSetupFinishedEntered()
