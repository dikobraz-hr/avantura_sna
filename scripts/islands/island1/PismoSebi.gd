extends PuzzleBase
class_name PismoSebi
## Otok I - "Pismo samoj sebi"
##
## Zadnja i najvažnija zagonetka Otoka I. Igrač istražuje tri sobe kućice
## (spavaća soba, kuhinja, tavan) i sastavlja fragmente iskrene poruke.
## Kad se pismo napiše i spusti u bunar, CIJELI OTOK se počinje urušavati
## i otvara se prolaz na Otok II - ovo je zagonetka koja tipično poklapa
## s "auto_complete_on_all_puzzles_solved" logikom u IslandBase, jer je
## po sinopsisu ovo posljednja od tri zagonetke otoka.

func _ready() -> void:
	puzzle_id = "island1_pismo_sebi"
	super._ready()


func _on_solved() -> void:
	SymbolInventory.collect("pismo_samoj_sebi")

	DialogueManager.say([
		"Riječi, konačno, ne bježe s papira.",
		"Pismo tone u bunar, a tlo pod nogama počinje podrhtavati.",
		"Šuma se urušava - iza nje čeka nešto novo.",
	])

	# Napomena: IslandBase._on_all_puzzles_solved() se automatski poziva
	# nakon ovog signala (jer je ovo posljednja zagonetka otoka), pa se
	# prijelaz na Otok II odvija bez dodatnog koda ovdje.
