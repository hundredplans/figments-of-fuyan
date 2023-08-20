extends Control
@onready var screen_change_signals: Array = [\
[$Buttons/AreaEditor/AreaEditor.pressed, "res://scenes/screens/area_editor/area_editor.tscn"]
]

@onready var click_sfx: AudioStreamWAV = preload("res://assets/sounds/UI/menu_buttons/click.wav")

func on_menu_button_pressed(): AudioMaster.play_sfx(click_sfx)
