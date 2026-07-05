extends Interactable
class_name CollectSymbol
## CollectSymbol
##
## Generički, ponovno iskoristiv interaktivni objekt koji, kad ga Liska
## aktivira, dodaje simbol u SymbolInventory (i po želji prikazuje kratku
## narativnu liniju teksta preko DialogueManagera).
##
## Koristi se za SVE "sakupljive" predmete iz sinopsisa: smola s vrbe,
## pepeo iz ognjišta, voda iz bunara, dječja cipela, stara fotografija,
## neposlano pismo, fragmenti sjećanja, itd.
##
## Postavljanje u editoru:
## - symbol_id: string ID predmeta (mora se poklapati s ID-om koji
##   CompletionTrigger očekuje za tu zagonetku)
## - dialogue_lines: tekst koji se prikaže pri pokupljanju (opcionalno)
## - one_shot: ako true, objekt se nakon pokupljanja deaktivira
##   (npr. sakriva se ili gubi mogućnost ponovne interakcije)

@export var symbol_id: String = ""
@export var dialogue_lines: Array[String] = []
@export var one_shot: bool = true


func _on_interact(_source: Node) -> void:
	if symbol_id == "":
		push_warning("CollectSymbol '%s' nema postavljen symbol_id!" % name)
		return

	# Ako je već pokupljeno, samo ponovi dijalog (ugodno za igrača da može
	# opet "pročitati" isti fragment), ali ne dupliciramo logiku sakupljanja.
	var already_had: bool = SymbolInventory.has_symbol(symbol_id)

	if not already_had:
		SymbolInventory.collect(symbol_id)

	if not dialogue_lines.is_empty():
		DialogueManager.say(dialogue_lines)

	if one_shot and not already_had:
		# Placeholder vizual feedback: zatamni objekt da signalizira "iskorišteno".
		# TODO(art): zamijeniti suptilnijom animacijom/česticama kad stigne grafika.
		modulate = Color(0.5, 0.5, 0.5, 0.6)
		interactable = false
