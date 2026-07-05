extends Node
## SymbolInventory
##
## Autoload koji prati "simbole" - narativno značajne predmete koje igrač
## prikuplja kroz igru (smola vrbe, pepeo, voda iz bunara, šalica kave,
## kazališne maske, obiteljski album, itd.).
##
## Ovi simboli se u pravilu koriste za:
## 1) otključavanje/rješavanje pojedinih zagonetki (npr. "Destilacija odjeka"
##    treba 3 specifična elementa), i
## 2) finalni "Kolaž života" na Otoku VI, gdje igrač polaže SVE simbole
##    prikupljene tijekom cijele igre.
##
## Podaci o simbolima se drže kao jednostavni string ID-ovi (npr. "smola_vrbe")
## radi jednostavnosti; UI kasnije može mapirati ID -> ikonu/naziv/opis.

signal symbol_collected(symbol_id: String)
signal inventory_changed

## Skup prikupljenih simbola (Dictionary kao set).
var _collected: Dictionary = {}

## Opcionalni human-readable nazivi simbola za UI (popunjava se po potrebi).
## Mapiranje je odvojeno od logike da bi lokalizacija/tekst bio lako zamjenjiv.
const SYMBOL_NAMES: Dictionary = {
	"smola_vrbe": "Smola s vrbe",
	"pepeo_ognjista": "Pepeo iz ognjišta",
	"voda_bunara": "Voda iz bunara",
	"djecja_cipela": "Dječja cipela",
	"stara_fotografija": "Stara fotografija",
	"neposlano_pismo": "Neposlano pismo",
	"pismo_samoj_sebi": "Pismo samoj sebi",
	"salica_kave": "Šalica kave",
	"kazalisne_maske": "Kazališne maske (3)",
	"obiteljski_album": "Obiteljski album",
}


## Dodaje simbol u inventar. Idempotentno - dodavanje istog simbola dvaput
## nema dodatnog efekta, ali će emitirati signal samo prvi put.
func collect(symbol_id: String) -> void:
	if _collected.has(symbol_id):
		return

	_collected[symbol_id] = true
	print("[SymbolInventory] Prikupljen simbol: %s" % _display_name(symbol_id))
	symbol_collected.emit(symbol_id)
	inventory_changed.emit()


## Provjerava posjeduje li igrač određeni simbol.
func has_symbol(symbol_id: String) -> bool:
	return _collected.has(symbol_id)


## Provjerava posjeduje li igrač SVE simbole iz predane liste.
## Korisno za zagonetke koje traže više elemenata istovremeno
## (npr. Destilacija odjeka treba sve od: smola_vrbe, pepeo_ognjista, voda_bunara).
func has_all(symbol_ids: Array) -> bool:
	for id in symbol_ids:
		if not _collected.has(id):
			return false
	return true


## Vraća kopiju liste svih prikupljenih simbola (za UI prikaz ili spremanje).
func get_all_collected() -> Array:
	return _collected.keys()


func _display_name(symbol_id: String) -> String:
	return SYMBOL_NAMES.get(symbol_id, symbol_id)


## Resetira inventar (novi početak igre).
func reset() -> void:
	_collected.clear()
	inventory_changed.emit()
