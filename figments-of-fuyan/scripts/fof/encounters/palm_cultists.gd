extends EncounterGD

const PRAY_OPTION_SHILLINGS: int = 15
const BOON_AMOUNT: int = 2 # At least 1 more boon with champ
const DECK_AMOUNT: int = 3
const GAZER_BOON_ID: int = 17
const LEAVE_CHANGE_ENERGY_AMOUNT: int = 2
const ENERGY_INCREASE_AMOUNT: int = 1

func canShowUp() -> bool:
	return anyRequirementMet()
	
func isRequirementMet(option: EncounterOptionDatastore) -> bool:
	match option.name:
		"Pray": return Game.getSaveFile().getBoons().size() >= BOON_AMOUNT
		"Leave": return Game.getDeckSize() >= DECK_AMOUNT
	return true
	
func onOptionPressed(option: EncounterOptionDatastore, _screen: Control) -> void:
	match option.name:
		"Pray":
			var boons: Array = Game.getSaveFile().getBoons().filter(func(x: BoonGD): return x.info.rarity != Game.Rarities.CHAMPION)
			var actions: Array = [ChangeShillingsAction.new(PRAY_OPTION_SHILLINGS), RemoveBoonAction.new(boons.pick_random().info.id)]
			onPushAction(actions)
		"Gaze":
			onPushAction(AddBoonAction.new(GAZER_BOON_ID, false))
		"Leave":
			var cards: Array = Game.getDeckCardsNoChampion()
			cards.shuffle()
			cards.resize(LEAVE_CHANGE_ENERGY_AMOUNT)
			
			onPushAction(cards.map(func(x: CardGD): return BaseStatAction.new(x, Game.Stats.ENERGY, ENERGY_INCREASE_AMOUNT)))
	onContinueToNextPage(option)
	
