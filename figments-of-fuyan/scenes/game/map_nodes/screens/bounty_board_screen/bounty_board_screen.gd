extends MapNodeScreen

const PRICE_INCREASE: int = 5
const BASE_PRICE: int = 10

var SelectedCard: CardGD
@export var TierLabelPacked: PackedScene
@export var kill_amounts: Array[int]

#@onready var TierToKills: Label = %TierToKills
@onready var AttackButton: Control = %AttackButton
@onready var HealthButton: Control = %HealthButton
@onready var MiniBox: Control = %MiniBox
@onready var PriceLabel: FancyTextLabel = %PriceLabel
@onready var TierLabels: Container = %TierLabels
@onready var WantedLabel: Label = %WantedLabel

func setInfo(_save_file: SaveFileGD, _area: AreaGD, _World: Node3D, _UI: Control, _map_node: MapNodeGD) -> void:
	super(_save_file, _area, _World, _UI, _map_node)
	SelectedCard = Game.onFindPublicIDObject(map_node.selected_card_public_id)
	map_node.change_shillings.connect(onShillingsChanged)
	
	setButtonsDisabled()
	setWantedLabel()
	MiniBox.setData(null)
	
	if SelectedCard != null:
		onCardSelected(SelectedCard)
		
	if map_node.price == 0: map_node.price = BASE_PRICE
	
	setPriceLabel()
	onCreateTierLabels()
	setTierLabels()

func onCreateTierLabels() -> void:
	for i: int in range(kill_amounts.size() - 1, -1, -1):
		var kill_amount: int = kill_amounts[i]
		var tier_label: FancyTextLabel = TierLabelPacked.instantiate()
		TierLabels.add_child(tier_label)
		
		tier_label.setText("Tier " + str(i + 1) + ": " + str(kill_amount))
		tier_label.setKillAmount(kill_amount)
		
func setTierLabels() -> void:
	if SelectedCard == null: return
	for TierLabel: FancyTextLabel in TierLabels.get_children().filter(func(x: Node): return x is FancyTextLabel):
		TierLabel.setTier(SelectedCard.bounty_kills.getKills(), SelectedCard.bounty_kills.getLastClaimedKills())

func setWantedLabel() -> void:
	var text: String = "Select a card below" if SelectedCard == null else "WANTED: [" + str(SelectedCard.bounty_kills.getKills()) +"] Confirmed Kills"
	WantedLabel.text = text 

func setPriceLabel() -> void:
	PriceLabel.setText("Price: " + str(map_node.price) + " SH [ +" + str(PRICE_INCREASE) + " SH ]\nDuels are worth [2] kills")

func onFadeBackground() -> bool:
	return true
	
func getFadeBackgroundColor() -> Color:
	return Color(0.7, 0.7, 0.7)

func _on_leave_button_pressed() -> void:
	finished.emit()
	queue_free()

func _on_mini_box_pressed() -> void:
	var DeckScreen: Control = Game.onCreateDeckScreen(self, true)
	DeckScreen.selected.connect(onCardSelected)
	
func onCardSelected(Card: CardGD) -> void:
	SelectedCard = Card
	map_node.selected_card_public_id = SelectedCard.public_id
	MiniBox.setData(Card.onSave())
	setWantedLabel()
	setTierLabels()
	setButtonsDisabled()

func _on_mini_box_mouse_in_ui(is_mouse_in_ui: bool) -> void:
	MiniBox.modulate = Color(0.2, 0.2, 0.2) if is_mouse_in_ui else Color(1, 1, 1)

func onShillingsChanged() -> void:
	setButtonsDisabled()
	
func setButtonsDisabled() -> void:
	var is_disabled: bool = Game.getSaveFile().getShillings() < map_node.price or getKillAmountDisabled()
	
	AttackButton.setDisabled(is_disabled)
	HealthButton.setDisabled(is_disabled)

func getKillAmountDisabled() -> bool:
	if SelectedCard != null:
		var kill_amount: int = SelectedCard.bounty_kills.getKills()
		var last_claimed_kills: int = SelectedCard.bounty_kills.getLastClaimedKills()
		for kills: int in kill_amounts:
			if last_claimed_kills < kills and kill_amount >= kills:
				return false
	return true

func onStatBought(_stat: String) -> void:
	var stat := Game.Stats.ATTACK if _stat == "Attack" else Game.Stats.MAX_HEALTH
	var actions: Array = [BaseStatAction.new(SelectedCard, stat, 1), ChangeShillingsAction.new(-map_node.price)]
	map_node.onPushAction(actions)
	map_node.price += PRICE_INCREASE
	
	var previous_last_claimed_kills: int = SelectedCard.bounty_kills.getLastClaimedKills()
	var next_last_claimed_kills: int = 1
	for i: int in range(kill_amounts.size()):
		if kill_amounts[i] > previous_last_claimed_kills:
			next_last_claimed_kills = kill_amounts[i]
			break
	
	SelectedCard.bounty_kills.setLastClaimedKills(next_last_claimed_kills)
	setPriceLabel()
	setTierLabels()
	setButtonsDisabled()
