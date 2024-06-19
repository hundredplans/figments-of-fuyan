class_name MoveActionGD
extends ActionGD

const type: int = ActionManagerGD.MOVE_UNIT
var fneighbour: FneighbourGD
var movement_path: MovementPathGD

const REENTER_VISION_DELAY: float = 0.8

func _init(_Unit: UnitGD = null, _fneighbour: FneighbourGD = null, _movement_path: MovementPathGD = null, _is_visible: bool = true, _delay: DelayGD = null) -> void:
	Unit = _Unit
	fneighbour = _fneighbour
	movement_path = _movement_path
	is_visible = _is_visible
	delay = _delay
	
	if delay == null: onCreateDelay()
	super()
	
func onCreateDelay() -> void:
	if is_visible:
		var regular_delay: float = 1.0
		if fneighbour.movement_type == FneighbourGD.FALL or fneighbour.movement_type == FneighbourGD.JUMP:
			regular_delay = 1 + (fneighbour.hdiff * 0.1) + 0.4	
		delay = DelayGD.new(regular_delay)
	else: delay = DelayGD.new()
	
func onTrigger() -> void:
	if Unit.team == 0: return onAllyTrigger()
	
	var vis_info: VisInfoGD = movement_path.onVisInfoByFneighbour(fneighbour)
	Unit.vision_info_array.append(vis_info)
	
	if vis_info.total_vision != VisInfoGD.INVISIBLE:
		if vis_info.total_vision == VisInfoGD.EXIT: SpectateCamera.onStopTrack()
		else: SpectateCamera.onSpectate(Unit)
		Unit.Model.onMoveToTile(fneighbour, movement_path, vis_info.total_vision)
		return
	if movement_path.onReentersVision(vis_info): delay.end_delay += REENTER_VISION_DELAY
	else: SpectateCamera.onStopTrack()
	
	Unit.global_position = Unit.Model.onCalculateEndPosition(fneighbour.Tile)
	Unit.Model._look_at(fneighbour.Tile)
	
func onAllyTrigger(total_vision: int = VisInfoGD.REGULAR) -> void:
	SpectateCamera.onSpectate(Unit)
	Unit.Model.onMoveToTile(fneighbour, movement_path, total_vision)
	
func onAfterTrigger() -> void:
	Unit.stats("active_speed", -1, AppliedByGD.new("MovementFinished"))
	var PreviousTile: TileGD = Unit.Tile
	Unit.occupy_tile(fneighbour.Tile)
	Tiles.onTileEffects(Unit, PreviousTile)
	
	if Unit.team == 0:
		Unit.onAddToPastPath(fneighbour.Tile)
		if Unit.speed > 0: PlayerManager._on_unit_selected(Unit)
