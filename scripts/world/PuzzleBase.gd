extends Node
class_name PuzzleBase
## PuzzleBase
##
## Zajednička baza za sve zagonetke u igri. Svaka konkretna zagonetka
## (npr. DestilacijaOdjeka, ZaustavljanjePetlje...) naslijedi ovu klasu
## kao čvor u sceni otoka i implementira svoju specifičnu logiku, ali
## se prema IslandBase-u i GameManageru ponaša na jednoobrazan način.
##
## Zašto ovakva arhitektura:
## - IslandBase treba znati kada su SVE zagonetke otoka riješene, bez da
##   pozna detalje svake pojedinačne zagonetke -> zato zajednički signal
##   `solved`.
## - GameManager treba jedinstveni string ID zagonetke radi spremanja
##   napretka (save/load) -> zato `puzzle_id`.

## Jedinstveni identifikator zagonetke, npr. "island1_destilacija_odjeka".
## MORA biti postavljen u _ready() svake podklase prije korištenja.
@export var puzzle_id: String = ""

## Emitira se kad je zagonetka riješena (jednom, nema "un-solve" mehanike).
signal solved(puzzle_id: String)

var _is_solved: bool = false


func _ready() -> void:
	if puzzle_id == "":
		push_warning("PuzzleBase čvor '%s' nema postavljen puzzle_id!" % name)

	# Ako je zagonetka već ranije riješena (npr. učitana igra), odmah
	# se postavi u riješeno stanje bez ponovnog pokretanja logike.
	if GameManager.is_puzzle_solved(puzzle_id):
		_is_solved = true
		_on_already_solved()


## Podklase pozivaju ovo kad igrač uspješno ispuni uvjete zagonetke.
## Idempotentno - drugi pozivi se ignoriraju.
func mark_solved() -> void:
	if _is_solved:
		return

	_is_solved = true
	GameManager.mark_puzzle_solved(puzzle_id)
	solved.emit(puzzle_id)
	_on_solved()


func is_solved() -> bool:
	return _is_solved


## VIRTUALNO: podklasa override-a ako treba nešto posebno napraviti
## čim se zagonetka riješi (npr. pokrenuti animaciju urušavanja otoka).
func _on_solved() -> void:
	pass


## VIRTUALNO: podklasa override-a za slučaj učitavanja već riješene
## zagonetke (npr. odmah prikazati "otvoreno" stanje vrata bez animacije).
func _on_already_solved() -> void:
	pass
