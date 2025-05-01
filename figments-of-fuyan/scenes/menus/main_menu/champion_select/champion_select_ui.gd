extends Control

signal start_game
signal back
signal arrow_pressed
signal view_champion
signal unview_champion

const VIEW_CHAMPION_TIME: float = 0.25
const ARROW_PRESSED_TIME: float = 1.0

@export var FancyTextLabelPacked: PackedScene

@onready var AuraTextureRect: TextureRect = %AuraTextureRect
@onready var BoonDescriptionLabel: FancyTextLabel = %BoonDescriptionLabel
@onready var BoonNameLabel: Label = %BoonNameLabel
@onready var CardDescriptionLabel: FancyTextLabel = %CardDescriptionLabel
@onready var ChampionDescription: Control = %ChampionDescription
@onready var GeneralDescriptionContainer: VBoxContainer = %GeneralDescriptionContainer
@onready var ChampionNameLabel: Label = %ChampionNameLabel
@onready var AniPlayer: AnimationPlayer = %AniPlayer

var champion_cards: Array = []
var active_champion_index: int

func _ready() -> void:
	AniPlayer.play("SlideUIElements")

func _on_back_button_pressed() -> void:
	AniPlayer.play_backwards("SlideUIElements")
	back.emit()
	onDisableSceneButtons(0.25)
	
func onArrowButtonPressed(direction: int) -> void:
	arrow_pressed.emit(direction, ARROW_PRESSED_TIME)
	active_champion_index = (active_champion_index - direction) % champion_cards.size()
	onDisableSceneButtons(ARROW_PRESSED_TIME)
	
func onViewButtonPressed() -> void:
	AniPlayer.play("ViewChampion")
	view_champion.emit(active_champion_index, VIEW_CHAMPION_TIME)
	onUpdateChampionDescription()
	onDisableSceneButtons(VIEW_CHAMPION_TIME)
	
func onUpdateChampionDescription() -> void:
	var ChampionCard: CardGD = champion_cards[active_champion_index]
	var info: ChampionCardInfo = ChampionCard.info
	
	for child: Control in GeneralDescriptionContainer.get_children(): child.queue_free()
	for text: String in info.champion_description:
		var fancy_label: FancyTextLabel = FancyTextLabelPacked.instantiate()
		fancy_label.center = false
		fancy_label.setText("- " + text)
		GeneralDescriptionContainer.add_child(fancy_label)
	
	ChampionNameLabel.text = info.name
	CardDescriptionLabel.setText(ChampionCard.getDescription())
	
	var boon_info: BoonInfo = info.boon_info
	BoonNameLabel.text = "[" + boon_info.name + "]"
	BoonDescriptionLabel.setText(boon_info.description)
	AuraTextureRect.texture = boon_info.getIcon()
	
func onCancelButtonPressed() -> void:
	AniPlayer.play_backwards("ViewChampion")
	unview_champion.emit(active_champion_index, VIEW_CHAMPION_TIME)
	onDisableSceneButtons(VIEW_CHAMPION_TIME)
	
func setChampionCards(_champion_cards: Array) -> void:
	champion_cards = _champion_cards
	
func onStartButtonPressed() -> void:
	AniPlayer.play_backwards("SlideUIElements")
	start_game.emit(champion_cards[active_champion_index].info)
	onDisableSceneButtons(1.0)
	
func onDisableSceneButtons(time: float) -> void:
	for SceneButton: Label in get_tree().get_nodes_in_group("SceneButtons"):
		SceneButton.setPressable(false)
	
	await get_tree().create_timer(time).timeout
	
	for SceneButton: Label in get_tree().get_nodes_in_group("SceneButtons"):
		SceneButton.setPressable(true)
		
