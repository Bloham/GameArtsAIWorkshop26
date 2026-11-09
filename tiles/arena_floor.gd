extends TileMapLayer

const TILES_WIDE := 8
const TILES_HIGH := 4


func _ready() -> void:
	for y in range(TILES_HIGH):
		for x in range(TILES_WIDE):
			set_cell(Vector2i(x, y), 0, Vector2i.ZERO)
