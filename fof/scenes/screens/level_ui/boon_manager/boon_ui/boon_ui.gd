extends Control

signal mouse_in_ui

var mouse_state: bool = false
const TOOLTIP_DELAY: float = 0.4
var tooltip: Control

@export var BoonBox: Sprite2D
@export var button: TextureButton
@export var TrackChargesLabel: Label
@export var Outline: Sprite2D

var boon: BoonGD
func setInfo(_boon: BoonGD) -> void:
	boon = _boon
	button.texture = boon.boon_info.icon
	
	if boon.boon_info.rarity != boon.boon_info.RARITIES.MINI:
		if !boon.is_ascended: BoonBox.texture = preload("res://assets/base_game/boons/base_boon/boon_box_regular.png")
		else: BoonBox.texture = preload("res://assets/base_game/boons/base_boon/boon_box_ascended.png")
	else: BoonBox.texture = preload("res://assets/base_game/boons/base_boon/boon_box_mini.png")
	
	TrackChargesLabel.visible = boon.boon_info.track_charges
	Outline.modulate = Helper.rarity_boon_tool_colors[boon.boon_info.rarity]
	if boon.boon_info.track_charges: onTrackCharges(boon.charges)
	
func onAscendBoon() -> void:
	BoonBox.texture = preload("res://assets/base_game/boons/base_boon/boon_box_ascended.png")

func setDisabled(x: bool) -> void:
	button.setDisabled(x)
	BoonBox.modulate = button.DISABLED_COLOR if x else Color(1,1,1,1)

func _on_button_mouse_in_ui(x: bool):
	mouse_state = x
	mouse_in_ui.emit(x)
	if x: onCreateTooltip()
	else: onRemoveTooltip()
	
func onCreateTooltip() -> void:
	await get_tree().create_timer(TOOLTIP_DELAY).timeout
	if mouse_state and tooltip == null:
		tooltip = preload("res://scenes/screens/level_ui/base_tooltip/base_tooltip.tscn").instantiate()
		var text: String = boon.boon_info.name + ": " + boon.getDescription()
		tooltip.setInfo(text)
		add_child(tooltip)
		tooltip.setPosition()
		
func onRemoveTooltip() -> void:
	if tooltip != null: tooltip.queue_free()

func _process(_delta: float) -> void:
	if tooltip != null: tooltip.setPosition()

func onTrackCharges(charges: int) -> void:
	TrackChargesLabel.text = str(charges)
