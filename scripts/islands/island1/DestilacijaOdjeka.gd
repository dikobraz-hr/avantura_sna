extends PuzzleBase
class_name DestilacijaOdjeka
## Otok I - "Destilacija odjeka"
##
## Igrač mora prikupiti tri elementa (smola s vrbe, pepeo iz ognjišta,
## voda iz bunara) i "ispiti napitak" na za to određenom mjestu u kuhinji.
## Stvarna logika prikupljanja/provjere je u CollectSymbol / CompletionTrigger
## čvorovima u sceni - ova skripta samo predstavlja "identitet" zagonetke
## i pokreće flashback dijalog/posljedicu kad je riješena.

func _ready() -> void:
	puzzle_id = "island1_destilacija_odjeka"
	super._ready()


func _on_solved() -> void:
	# Otključavanje prvog, bolnog flashbacka - suočavanje s dijelom sebe
	# ostavljenim na dnu bunara. Konkretan tekst je lako izmjenjiv ovdje,
	# bez diranja generičke CompletionTrigger logike.
	DialogueManager.say([
		"Voda u čaši je hladna, gotovo gorka.",
		"Sjećanje udara poput vala: glas majke, prekinuta rečenica.",
		"Dio mene je ostao ovdje, na dnu bunara.",
	])
