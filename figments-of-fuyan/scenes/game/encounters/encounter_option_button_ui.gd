extends Control

signal pressed

@onready var DescriptionLabel: FancyTextLabel = %DescriptionLabel
@onready var OptionNameLabel: Label = %OptionNameLabel
@onready var RequirementLabel: FancyTextLabel = %RequirementLabel
@onready var MainContainer: Container = %MainContainer

var option: EncounterOptionDatastore
var is_requirement_met: bool

func setInfo(_option: EncounterOptionDatastore, _is_requirement_met: bool) -> void:
	option = _option
	OptionNameLabel.text = option.name
	DescriptionLabel.setText(option.description)
	is_requirement_met = _is_requirement_met
	
	if !is_requirement_met:
		RequirementLabel.setText("Requirement: " + option.requirement)
		setModulate(Color(0.2, 0.2, 0.2))
		return

var is_mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	is_mouse_in_ui = state
	if is_requirement_met and !disabled:
		setModulate(Color(0.5, 0.5, 0.5) if state else Color(1, 1, 1))
		
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("MainInput") and is_mouse_in_ui and is_requirement_met and !disabled:
		pressed.emit(option)

func setModulate(color: Color) -> void:
	for node in [OptionNameLabel, DescriptionLabel, MainContainer]:
		node.self_modulate = color
		
var disabled: bool
func setDisabled(_disabled: bool) -> void:
	disabled = _disabled
	DescriptionLabel.setHover(disabled)
	if is_requirement_met:
		setModulate(Color(0.2, 0.2, 0.2) if disabled else Color(1, 1, 1))
	else:
		RequirementLabel.setHover(!disabled)
