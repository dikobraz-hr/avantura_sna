extends Node
## DialogueManager
##
## Autoload koji posreduje između igre (zagonetki, interaktivnih objekata)
## i UI sloja (DialogueBox scene) za prikaz narativnog teksta.
##
## Namjerno je jednostavan: nema grananja dijaloga (dialogue trees) jer
## priča po sinopsisu koristi linearne fragmente teksta / flashbackove,
## a ne razgovore s izborima (izuzev finalne scene na Otoku VI, koja se
## rješava posebnom, malo kompleksnijom logikom u Island6 skripti).
##
## Kako se koristi (iz bilo koje skripte u igri):
##   DialogueManager.say(["Prva rečenica.", "Druga rečenica."])
##   DialogueManager.line_finished.connect(_on_dialogue_done)

## Emitira se svaki put kad se prikaže nova linija teksta.
signal line_shown(text: String)

## Emitira se kad je cijeli niz linija (queue) odglumljen do kraja.
signal sequence_finished

## Interni red čekanja linija teksta koje treba prikazati jedna za drugom.
var _queue: Array[String] = []

## Je li dijalog trenutno aktivan (koristi UI da zna treba li prikazati DialogueBox).
var is_active: bool = false


## Pokreće prikaz niza linija teksta. Ako je dijalog već u tijeku,
## novi niz se dodaje na kraj postojećeg reda (ne prekida se trenutni).
func say(lines: Array) -> void:
	for l in lines:
		_queue.append(String(l))

	if not is_active:
		is_active = true
		_advance()


## Pomiče dijalog na sljedeću liniju. UI (DialogueBox) ovo poziva
## kad igrač pritisne "interact" ili klikne za nastavak.
func advance() -> void:
	if not is_active:
		return
	_advance()


func _advance() -> void:
	if _queue.is_empty():
		is_active = false
		sequence_finished.emit()
		return

	var next_line: String = _queue.pop_front()
	line_shown.emit(next_line)


## Prekida trenutni dijalog (npr. ako je scena naglo prekinuta).
func clear() -> void:
	_queue.clear()
	is_active = false
