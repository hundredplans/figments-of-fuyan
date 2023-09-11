extends Control

@onready var click_sfx: AudioStreamWAV = preload("res://assets/sounds/UI/menu_buttons/click.wav")
func on_menu_button_pressed(): AudioMaster.play_sfx(click_sfx)
