extends Control

@export var reward_info: FofInfo
@export var travel_amount: int

@onready var ClaimButton: Control = %ClaimButton
@onready var FofUIBox: Control = %FofUIBox

signal pressed
var taken: bool

func setInfo(_taken: bool) -> void:
	taken = _taken
	ClaimButton.setText("Claim (" + str(travel_amount) + ")")
	setDisabled()
	
	if reward_info == null: return
	
	var data: SavedData = reward_info.saved_data.new(reward_info.id, true)
	if reward_info is CardInfo:
		Game.setCardDataFromInfo(data, reward_info)
	
	FofUIBox.setInfo(data, false)
	
func onPressed() -> void:
	pressed.emit(self, reward_info)

func setDisabled() -> void:
	ClaimButton.setDisabled(taken or Game.getHolyTravelledAmount() < travel_amount)
	if taken:
		FofUIBox.modulate = Color(0.2, 0.2, 0.2)

func onRewardClaimed() -> void:
	taken = true
	setDisabled()
