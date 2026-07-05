extends Interactable
class_name CompletionTrigger
## CompletionTrigger
##
## Generički, ponovno iskoristiv interaktivni objekt koji predstavlja
## "mjesto rješenja" zagonetke: bunar/kuhinja gdje se sastavlja napitak,
## rijeka u koju se puštaju predmeti, stol s perom za pismo, itd.
##
## Kad igrač interagira s ovim objektom:
## - Ako SymbolInventory sadrži SVE potrebne simbole (required_symbols),
##   poziva se mark_solved() na povezanoj zagonetki (target_puzzle),
##   prikazuje se success_dialogue, i (opcionalno) simboli se "potroše"
##   te se dodaje reward_symbol_id (npr. gotovo "pismo_samoj_sebi").
## - Ako uvjeti nisu ispunjeni, prikazuje se hint_dialogue (npr. "Nešto
##   još nedostaje...") kako igrač ne bi bio zbunjen bez povratne informacije.
##
## Postavljanje u editoru:
## - target_puzzle: NodePath do PuzzleBase čvora kojeg ova interakcija rješava
## - required_symbols: lista symbol_id stringova potrebnih za rješenje
## - consume_symbols: hoće li se predmeti "potrošiti" iz inventara (obično
##   false, jer simboli iz Otoka I trebaju "preživjeti" do finalnog Vrta
##   na Otoku VI gdje se ponovno koriste u "Kolažu života")

@export var target_puzzle_path: NodePath
@export var required_symbols: Array[String] = []
@export var consume_symbols: bool = false
@export var reward_symbol_id: String = "" # simbol koji se dodaje NAKON rješenja (npr. dovršeno pismo)
@export var success_dialogue: Array[String] = []
@export var hint_dialogue: Array[String] = []

@onready var _target_puzzle: PuzzleBase = get_node_or_null(target_puzzle_path)


func _on_interact(_source: Node) -> void:
	if not _target_puzzle:
		push_warning("CompletionTrigger '%s' nema valjan target_puzzle_path!" % name)
		return

	if _target_puzzle.is_solved():
		# Zagonetka je već riješena - samo ponovi success dijalog radi atmosfere.
		if not success_dialogue.is_empty():
			DialogueManager.say(success_dialogue)
		return

	if SymbolInventory.has_all(required_symbols):
		if consume_symbols:
			# Trenutno SymbolInventory ne podržava brisanje - namjerno,
			# jer sinopsis traži da se simboli čuvaju do finalnog Vrta (Otok VI).
			# Zadržano kao TODO ako se ipak odluči drugačije.
			pass

		if reward_symbol_id != "":
			SymbolInventory.collect(reward_symbol_id)

		if not success_dialogue.is_empty():
			DialogueManager.say(success_dialogue)

		_target_puzzle.mark_solved()
	else:
		if not hint_dialogue.is_empty():
			DialogueManager.say(hint_dialogue)
