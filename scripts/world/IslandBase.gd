extends Node2D
class_name IslandBase
## IslandBase
##
## Bazna klasa za svaki od 6 otoka podsvijesti (Šuma utočišta, Ured koji
## tone, Kazalište, Labirint zrcala, Prazna soba, Vrt na rubu jave).
##
## Odgovornosti:
## - Pri _ready() pronalazi sve PuzzleBase djecu u sceni (bilo gdje u
##   hijerarhiji) i sluša njihov `solved` signal
## - Kad su SVE zagonetke otoka riješene, javlja GameManageru da je
##   otok dovršen (island_completed) i po potrebi pokreće prijelaz
##   na sljedeći otok
##
## Konkretni otoci (Island1.gd, Island2.gd, ...) nasljeđuju ovu klasu
## i postavljaju `island_id` i `next_island` u editoru ili u _ready().

## Koji GameEnums.Island enum ovaj otok predstavlja.
@export var island_id: GameEnums.Island = GameEnums.Island.SUMA_UTOCISTA

## Sljedeći otok na koji se prelazi kad je ovaj dovršen.
## Za zadnji otok (Vrt na rubu jave) ovo se ne koristi - kraj igre se
## rješava posebno u Island6 skripti.
@export var next_island: GameEnums.Island = GameEnums.Island.URED_KOJI_TONE

## Treba li automatski pozvati complete_island kad su sve zagonetke gotove.
## Postavi na false za otoke koji imaju posebnu finalnu logiku (npr. Otok VI).
@export var auto_complete_on_all_puzzles_solved: bool = true

var _puzzles: Array[PuzzleBase] = []
var _solved_count: int = 0


func _ready() -> void:
	_puzzles = _find_all_puzzles(self)

	if _puzzles.is_empty():
		push_warning("Otok '%s' nema PuzzleBase djece - provjeri scenu." % name)

	for p in _puzzles:
		if p.is_solved():
			_solved_count += 1
		else:
			p.solved.connect(_on_puzzle_solved)

	_check_completion()


## Rekurzivno pronalazi sve čvorove koji su instance PuzzleBase,
## bez obzira na dubinu ugniježđenja u sceni otoka.
func _find_all_puzzles(root: Node) -> Array[PuzzleBase]:
	var result: Array[PuzzleBase] = []
	for child in root.get_children():
		if child is PuzzleBase:
			result.append(child)
		# Nastavi tražiti i unutar djece (npr. grupirane u Node2D "Sobe" itd.)
		result.append_array(_find_all_puzzles(child))
	return result


func _on_puzzle_solved(_puzzle_id: String) -> void:
	_solved_count += 1
	_check_completion()


func _check_completion() -> void:
	if _puzzles.is_empty():
		return

	if _solved_count >= _puzzles.size():
		_on_all_puzzles_solved()


## VIRTUALNO: podklase mogu override-ati za posebne finalne sekvence.
## Zadana implementacija samo javlja GameManageru i prelazi na sljedeći otok.
func _on_all_puzzles_solved() -> void:
	if auto_complete_on_all_puzzles_solved:
		GameManager.complete_island(island_id)
		GameManager.set_current_island(next_island)
