class_name ActiveIObjects extends Resource

var iobjects: Array
var Card: CardGD

func _init(_iobjects: Array = [], _Card: CardGD = null) -> void:
	iobjects = _iobjects
	Card = _Card

func getCard() -> CardGD:
	return Card
	
func setCard(_Card: CardGD) -> void:
	Card = _Card

func getIObjects() -> Array:
	return iobjects
	
func setIObjects(_iobjects: Array) -> void:
	iobjects = _iobjects
	
func isActiveEffectDisabled() -> bool:
	return iobjects.all(func(x: IObjectGD): return x.isActiveEffectDisabled(Card))
	
func getActiveEffectTiles() -> ActiveEffectTiles:
	var in_range_tiles: Array = []
	var pickable_tiles: Array = []
	
	for IObject: IObjectGD in iobjects:
		var _active_effect_tiles := IObject.getActiveEffectTiles(Card)
		in_range_tiles += _active_effect_tiles.in_range_tiles
		pickable_tiles += _active_effect_tiles.pickable_tiles
	
	var active_effect_tiles := ActiveEffectTiles.new(in_range_tiles, pickable_tiles)
	return active_effect_tiles

func getIObjectFromTile(Tile: TileGD) -> IObjectGD:
	for IObject: IObjectGD in iobjects:
		if Tile in IObject.getActiveEffectTiles(Card).pickable_tiles:
			return IObject
	return null
	
func getActiveEffectTilesFromTile(Tile: TileGD) -> ActiveEffectTiles:
	for IObject: IObjectGD in iobjects:
		var active_effect_tiles: ActiveEffectTiles = IObject.getActiveEffectTiles(Card)
		if Tile in active_effect_tiles.pickable_tiles:
			return active_effect_tiles
	return null
