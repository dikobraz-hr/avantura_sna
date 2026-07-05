extends Area2D
class_name Interactable
## Interactable
##
## Bazna klasa za SVE objekte u svijetu s kojima Liska može interagirati
## (bunar, stol s perom, ljuljačka, radio, ogledalo, itd.).
##
## Očekivani setup u editoru/sceni:
## - Ovaj čvor je Area2D s CollisionShape2D (definira "radijus interakcije")
## - collision_layer/mask postavljeni tako da ga detektira Liskin
##   "InteractionArea" (vidi Liska.gd)
## - Placeholder vizual (ColorRect/Polygon2D) kao dijete, dok ne stignu
##   finalne grafike
##
## Konkretni objekti (npr. Bunar, StolSPerom) trebaju NASLIJEDITI ovu
## klasu i override-ati _on_interact(), a ne mijenjati ovu bazu direktno.

## Kratki naziv koji se može prikazati kao "prompt" iznad objekta
## (npr. "Bunar" - "Pritisni E za interakciju").
@export var display_name: String = "Objekt"

## Može li se objekt trenutno koristiti. Korisno da se privremeno
## deaktivira interakcija dok je npr. zagonetka već riješena.
@export var interactable: bool = true

## Emitira se kad igrač uspješno interagira s objektom.
signal interacted(source: Node)


func _ready() -> void:
	# Sigurnosna provjera u dev fazi: upozori ako netko zaboravi collision shape.
	if get_child_count() == 0:
		push_warning("Interactable '%s' nema dijete-vizual/collision - provjeri scenu." % display_name)


## Poziva se iz Liska.gd kada igrač pritisne "interact" tipku,
## a ovaj objekt je najbliži interaktivni objekt u dosegu.
func try_interact(source: Node) -> void:
	if not interactable:
		return
	interacted.emit(source)
	_on_interact(source)


## VIRTUALNA metoda - podklase je override-aju sa svojom specifičnom logikom
## (npr. otvaranje dijaloga, pokretanje zagonetke, dodavanje simbola u inventar).
func _on_interact(_source: Node) -> void:
	pass
