extends Control

signal mouse_in_ui
signal edit_deck

const WAIT_TIME: float = 4
const FADEOUT_TIME: float = 1.5

@onready var ChampionLevelUpgradeLabel: Label = %ChampionLevelUpgradeLabel

@onready var AttackUpgradeContainer: Container = %AttackUpgradeContainer
@onready var HealthUpgradeContainer: Container = %HealthUpgradeContainer
@onready var SpeedUpgradeContainer: Container = %SpeedUpgradeContainer
@onready var EnergyUpgradeContainer: Container = %EnergyUpgradeContainer

@onready var AttackUpgradeLabel: Label = %AttackUpgradeLabel
@onready var HealthUpgradeLabel: Label = %HealthUpgradeLabel
@onready var SpeedUpgradeLabel: Label = %SpeedUpgradeLabel
@onready var EnergyUpgradeLabel: Label = %EnergyUpgradeLabel

@onready var MaxEnergyUpgradeLabel: Label = %MaxEnergyUpgradeLabel
@onready var DeckLimitUpgradeLabel: Label = %DeckLimitUpgradeLabel
@onready var EnergyLimitUpgradeLabel: Label = %EnergyLimitUpgradeLabel

@onready var ChampionAbilityUpgradeContainer: Container = %ChampionAbilityUpgradeContainer
@onready var ChampionAbilityUpgradeArtMini: TextureRect = %ChampionAbilityUpgradeArtMini
@onready var AbilityUpgradeLabel: FancyTextLabel = %AbilityUpgradeLabel

@onready var AniPlayer: AnimationPlayer = %AniPlayer

var stat_to_container: Dictionary[Game.Stats, String] = {
	Game.Stats.ATTACK: "AttackUpgradeContainer",
	Game.Stats.HEALTH: "HealthUpgradeContainer",
	Game.Stats.SPEED: "SpeedUpgradeContainer",
	Game.Stats.ENERGY: "EnergyUpgradeContainer"
}

var stat_to_label: Dictionary[Game.Stats, String] = {
	Game.Stats.ATTACK: "AttackUpgradeLabel",
	Game.Stats.HEALTH: "HealthUpgradeLabel",
	Game.Stats.SPEED: "SpeedUpgradeLabel",
	Game.Stats.ENERGY: "EnergyUpgradeLabel"
}

func setInfo(old_deck_limit: int, old_energy_limit: int, old_max_energy: int) -> void:
	var upgrade_level: int = Game.getSaveFile().getChampionLevel()
	ChampionLevelUpgradeLabel.text = str(upgrade_level - 1) + "  ->  " + str(upgrade_level)
	
	var energy_limit: int = Game.getSaveFile().getEnergyLimit()
	var deck_limit: int = Game.getSaveFile().getDeckLimit()
	var max_energy: int = Game.getSaveFile().getMaxEnergy()
	
	EnergyLimitUpgradeLabel.text = str(old_energy_limit) + "  ->  " + str(energy_limit)
	DeckLimitUpgradeLabel.text = str(old_deck_limit) + "  ->  " + str(deck_limit)
	MaxEnergyUpgradeLabel.text = str(old_max_energy) + "  ->  " + str(max_energy)
	
	var ChampionCard: CardGD = Game.getSaveFile().getChampionCard()
	var champion_upgrade: ChampionUpgrade = ChampionCard.getChampionUpgrade(upgrade_level)
	
	for stat: Game.Stats in [Game.Stats.ATTACK, Game.Stats.HEALTH, Game.Stats.SPEED, Game.Stats.ENERGY]:
		var value: int = champion_upgrade["plus_" + Game.getStatString(stat).to_lower()]
		var container: Container = get(stat_to_container[stat])
		container.visible = value != 0
		
		if value == 0: continue
		
		var label: Label = get(stat_to_label[stat])
		var current_value: int = ChampionCard.getStatValue(stat)
		label.text = str(current_value) + "  ->  " + str(current_value + value)

	ChampionAbilityUpgradeArtMini.texture = ChampionCard.info.getArtMini()
	var ability_upgrade_text: String = ChampionCard.getDescriptionUpgradeLevel(upgrade_level - 1)
	AbilityUpgradeLabel.setText(ability_upgrade_text + " -> " + ChampionCard.getDescription())
	AniPlayer.play("SlideUIElements")

func onEditDeckButtonPressed() -> void:
	await onExitButtonPressed()
	edit_deck.emit()

func onExitButtonPressed() -> void:
	AniPlayer.play_backwards("SlideUIElements")
	
	for SceneButton: Label in get_tree().get_nodes_in_group("SceneButtons"):
		SceneButton.setPressable(false)
		
	await AniPlayer.animation_finished
	await get_tree().process_frame
	
	queue_free()
	
func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
