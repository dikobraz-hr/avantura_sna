extends PuzzleBase
class_name ZaustavljanjePetlje
## Otok I - "Zaustavljanje petlje"
##
## Ljuljačka se njiše sama od sebe - vizualni simbol emocionalne stagnacije.
## Igrač mora pronaći tri izblijedjela predmeta (dječja cipela, stara
## fotografija, neposlano pismo) i pustiti ih niz rijeku. Ova skripta
## drži referencu na samu ljuljačku (u sceni) da bi zaustavila njeno
## njihanje čim se zagonetka riješi.

## Putanja do čvora ljuljačke u sceni (postavlja se u editoru).
## Ljuljačka treba imati vlastitu malu skriptu (ili AnimationPlayer)
## s metodom stop_swinging() - vidi Ljuljacka.gd.
@export var swing_node_path: NodePath

@onready var _swing_node: Node = get_node_or_null(swing_node_path)


func _ready() -> void:
	puzzle_id = "island1_zaustavljanje_petlje"
	super._ready()


func _on_solved() -> void:
	DialogueManager.say([
		"Predmeti nestaju u struji, jedan po jedan.",
		"Ljuljačka se, konačno, smiruje.",
	])

	if _swing_node and _swing_node.has_method("stop_swinging"):
		_swing_node.stop_swinging()


func _on_already_solved() -> void:
	if _swing_node and _swing_node.has_method("stop_swinging"):
		_swing_node.stop_swinging()
