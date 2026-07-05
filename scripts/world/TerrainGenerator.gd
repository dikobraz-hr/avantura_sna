extends TileMapLayer
## TerrainGenerator
##
## Programatski generira izometrijski TileSet (u kodu, ne kao ručno pisan
## .tres resurs - time izbjegavamo fragilan binarni/tekstualni format i
## moguće greške pri parsiranju) i popunjava pravokutno polje pločicama
## kao PRIVREMENI placeholder teren.
##
## Kad stigne stvarni tileset (više varijanti pločica, staze, rubovi...),
## ova skripta se može:
## a) proširiti da doda više `create_tile()` varijanti u isti TileSet, ili
## b) potpuno zamijeniti ručno oslikanim TileMapLayer-om u editoru
##    (uobičajen radni tok: dodijeliš gotov .tres TileSet i "naslikaš"
##    teren mišem u Godot editoru).
##
## Placeholder pločica: assets/placeholder/tile_grass_iso.png (128x64,
## dijamant, "jesenji" zeleno-smeđi ton za Otok I).

@export var tile_texture: Texture2D = preload("res://assets/placeholder/grass 1.png")
@export var tile_pixel_size: Vector2i = Vector2i(1024, 1024)
@export var grid_width: int = 20
@export var grid_height: int = 20


func _ready() -> void:
	tile_set = _build_placeholder_tile_set()
	_fill_grid()


func _build_placeholder_tile_set() -> TileSet:
	var ts := TileSet.new()
	ts.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	ts.tile_layout = TileSet.TILE_LAYOUT_DIAMOND_DOWN
	ts.tile_size = tile_pixel_size

	var source := TileSetAtlasSource.new()
	source.texture = tile_texture
	source.texture_region_size = tile_pixel_size
	source.create_tile(Vector2i(0, 0))

	ts.add_source(source, 0)
	return ts


## Popunjava pravokutno polje (grid_width x grid_height) istom pločicom.
## TODO: kad postoji više varijanti pločica, ovdje dodati nasumičan odabir
## atlas koordinata ili ručno oslikan raspored umjesto jednolikog polja.
func _fill_grid() -> void:
	for x in range(grid_width):
		for y in range(grid_height):
			set_cell(Vector2i(x, y), 0, Vector2i(0, 0), 0)
