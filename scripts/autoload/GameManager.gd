extends Node
## GameManager
##
## Centralni autoload (singleton) koji drži globalno stanje igre:
## - koji je otok podsvijesti trenutno aktivan
## - koji su otoci/zagonetke već riješeni
## - emitira signale kad se stanje promijeni, kako bi UI i svijet reagirali
##
## Svi ostali sustavi (UI, otoci, Liska) čitaju stanje odavde umjesto
## da ga duplicaju lokalno - jedan izvor istine (single source of truth).
##
## Napomena: enum otoka (`Island`) živi u `GameEnums.gd` (zasebna class_name
## klasa), a NE ovdje kao ugniježđen enum - vidi opširno objašnjenje zašto
## u komentaru na vrhu `GameEnums.gd`.

## Emitira se kada se promijeni aktivni otok (npr. nakon prijelaza kroz portal).
signal island_changed(new_island: GameEnums.Island)

## Emitira se kada je neka zagonetka (puzzle_id) riješena.
## puzzle_id je jedinstveni string identifikator, npr. "island1_destilacija_odjeka".
signal puzzle_solved(puzzle_id: String)

## Emitira se kada je cijeli otok dovršen (sve njegove zagonetke riješene).
signal island_completed(island: GameEnums.Island)

## Trenutni aktivni otok. Početna vrijednost je prvi otok priče.
var current_island: GameEnums.Island = GameEnums.Island.SUMA_UTOCISTA

## Skup (Dictionary korišten kao set) riješenih zagonetki, po jedinstvenom ID-u.
## Koristimo Dictionary jer Godot nema nativni Set tip; vrijednost (true) je nebitna.
var _solved_puzzles: Dictionary = {}

## Skup potpuno dovršenih otoka.
var _completed_islands: Dictionary = {}


func _ready() -> void:
	# Autoload se učitava jednom za cijelo trajanje igre - ne uništava se
	# prilikom promjene scena, pa je siguran za čuvanje napretka igrača.
	print("[GameManager] Inicijaliziran. Početni otok: %s" % GameEnums.Island.keys()[current_island])


## Poziva se kad igrač riješi pojedinačnu zagonetku unutar otoka.
## puzzle_id: jedinstveni string identifikator zagonetke.
func mark_puzzle_solved(puzzle_id: String) -> void:
	if _solved_puzzles.has(puzzle_id):
		return # već riješeno, izbjegavamo duplo emitiranje signala

	_solved_puzzles[puzzle_id] = true
	print("[GameManager] Zagonetka riješena: %s" % puzzle_id)
	puzzle_solved.emit(puzzle_id)


## Provjerava je li određena zagonetka već riješena.
func is_puzzle_solved(puzzle_id: String) -> bool:
	return _solved_puzzles.has(puzzle_id)


## Poziva se kad je otok u potpunosti dovršen (npr. iz IslandBase kad su
## sve njegove zagonetke gotove). Prebacuje igru na sljedeći otok.
func complete_island(island: GameEnums.Island) -> void:
	if _completed_islands.has(island):
		return

	_completed_islands[island] = true
	print("[GameManager] Otok dovršen: %s" % GameEnums.Island.keys()[island])
	island_completed.emit(island)


## Postavlja novi aktivni otok i emitira signal za promjenu scene/svijeta.
func set_current_island(island: GameEnums.Island) -> void:
	current_island = island
	print("[GameManager] Prelazak na otok: %s" % GameEnums.Island.keys()[island])
	island_changed.emit(island)


## Vraća je li otok već dovršen - korisno za UI (npr. mapa napretka).
func is_island_completed(island: GameEnums.Island) -> bool:
	return _completed_islands.has(island)


## Resetira cjelokupno stanje igre (novi početak igre).
func reset_progress() -> void:
	_solved_puzzles.clear()
	_completed_islands.clear()
	current_island = GameEnums.Island.SUMA_UTOCISTA
	print("[GameManager] Napredak resetiran.")
