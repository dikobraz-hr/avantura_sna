extends IslandBase
## Island6 - "Vrt na rubu jave" (STUB / PREDLOŽAK)
##
## Finalni otok. Sadrži elemente svih prethodnih svjetova i vodi do
## kraja igre. VAŽNO: auto_complete_on_all_puzzles_solved treba postaviti
## na FALSE u editoru za ovaj otok, jer kraj igre nije "prijelaz na
## sljedeći otok" nego posebna sekvenca (buđenje).
##
## TODO - tri "zagonetke"/sekvence za implementirati:
##
## 1) "Kolaž života"
##    - CompletionTrigger stila, ali required_symbols je NAMJERNO velika
##      lista SVIH simbola prikupljenih kroz cijelu igru:
##      ["smola_vrbe", "pepeo_ognjista", "voda_bunara", "salica_kave",
##       "maska_partnerica", "maska_oprastanje", "maska_dobro_sam",
##       "obiteljski_album", ...]. Baš zato SymbolInventory.has_all()
##      postoji kao generička provjera - ovo joj je "stress test" upotreba.
##    - Nema potrebe za novom klasom - postojeći CompletionTrigger
##      pokriva ovo u potpunosti.
##
## 2) "Suočavanje na litici"
##    - Dijalog s izborima (strah / tuga / nada) - ovo je JEDINO mjesto u
##      igri koje treba grananje. Predlažem malu nadogradnju: umjesto
##      DialogueManager.say(), poseban "ChoiceDialogueBox" UI prizor s tri
##      gumba koji pozivaju GameManager.mark_puzzle_solved() s različitim
##      puzzle_id sufiksom (npr. "island6_suocavanje_strah" itd.) samo
##      radi bilježenja igračevog izbora - sam tok priče se NE mijenja
##      (po sinopsisu: "smjer ostaje isti"), samo ton naracije koji slijedi.
##
## 3) "Korak u buđenje"
##    - Bez mehanika - čista scripted sekvenca: Tween koji pomiče Lenu
##      (novi lik, prvi put vidljiv/kontroliran izvan Liske) prema
##      svjetlosnom portalu, dok se Liska (modulate alpha -> 0) postupno
##      rastapa. Na kraju Tweena: get_tree().change_scene_to_file() na
##      "Kraj igre" scenu ili jednostavan fade-to-white + credits.
##
## Napomena o auto_complete_on_all_puzzles_solved:
## Override _on_all_puzzles_solved() ovdje umjesto korištenja zadane
## IslandBase implementacije, jer ne postoji "next_island" nakon ovog otoka.

func _ready() -> void:
	island_id = GameEnums.Island.VRT_NA_RUBU_JAVE
	auto_complete_on_all_puzzles_solved = false
	super._ready()

	var liska: Liska = get_tree().get_first_node_in_group("liska")
	if liska:
		liska.set_visual_form(Liska.VizualnaForma.PROZIRNA_UTVARA)


## Override zadane IslandBase logike - nema sljedećeg otoka, umjesto toga
## pokreće se finalna sekvenca buđenja.
func _on_all_puzzles_solved() -> void:
	GameManager.complete_island(island_id)
	_play_ending_sequence()


## TODO: implementirati stvarnu scriptanu sekvencu (vidi točku 3 gore).
## Placeholder trenutno samo ispisuje poruku u konzolu.
func _play_ending_sequence() -> void:
	DialogueManager.say([
		"Ruka pronalazi ruku.",
		"Svjetlost portala postaje sve jača.",
		"Vrijeme je da otvori oči.",
	])
	print("[Island6] TODO: implementirati finalnu sekvencu buđenja (fade-to-white, credits).")
