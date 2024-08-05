class_name TraitGD
extends Resource

var info: TraitInfoGD
var GameFX: GameFXGD
	
func setInfo(_info: TraitInfoGD, _game_fx: GameFXGD) -> void:
	info = _info
	GameFX = _game_fx
	
func onReady(_init: TraitInitGD) -> void: pass
