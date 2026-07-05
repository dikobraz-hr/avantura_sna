extends IslandBase
## Island2 - "Ured koji tone" (STUB / PREDLOŽAK)
##
## Materijalizacija Lenina burnouta: izometrijski open-space ured koji
## polako tone u tamnu vodu. Liska ovdje ima ORIGAMI_LOMLJIVA vizualnu formu
## (vidi Liska.VizualnaForma) jer otok predstavlja krizu/nesigurnost.
##
## OVO JE PREDLOŽAK - koristi ISTI obrazac kao Island1.gd/Island1.tscn:
## PuzzleBase podklase + CollectSymbol/CompletionTrigger generički čvorovi.
## Ne treba pisati puno nove logike, uglavnom se slaže scena.
##
## TODO - tri zagonetke za implementirati (vidi sinopsis, Otok II):
##
## 1) "Iluzija hitnosti"
##    - CollectSymbol objekti: "telefon_1", "telefon_2", "fascikl_1"... za
##      svaki "utopljeni zahtjev" koji igrač izvlači ronjenjem.
##    - Poseban mehanizam: razina vode (npr. globalna varijabla ili
##      AnimationPlayer koji podiže y-poziciju "WaterLevel" ColorRect-a)
##      raste sa SVAKIM riješenim zahtjevom - implementirati kao slušanje
##      na SymbolInventory.symbol_collected signal unutar ove puzzle skripte.
##    - Stvarno rješenje: CompletionTrigger na "Monitor" objektu koji NE
##      traži simbole, već naprosto završava zagonetku (mark_solved) čim
##      ga igrač interaktira - poanta je "prestani igrati tuđu igru",
##      dakle svjesan odustanak, ne akumulacija predmeta.
##
## 2) "Buka očekivanja"
##    - Igrač sjeda na "RadnaStolica" (Interactable) - pokreće kaotičnu
##      sekvencu (Tween/AnimationPlayer koji ubrzava zvuk/vizual - trenutno
##      placeholder treperenje boje).
##    - Rješenje: igrač mora PONOVNO interaktirati sa stolicom da "ustane"
##      usred kaosa (ne pobjeđuje brzinom). Implementirati kao poseban
##      PuzzleBase s internim bool "is_sitting" i timerom koji nakon npr.
##      3 sekunde otvara "prozor rješenja" - interakcija u tom prozoru
##      rješava zagonetku, prerano ili nikad ne rješava.
##
## 3) "Pauza na prozoru"
##    - CollectSymbol "salica_kave" (hladna šalica kave, jedini trag
##      humanosti).
##    - CompletionTrigger "Prozor" traži salica_kave -> mark_solved,
##      povlači vodu (vizualni placeholder: Tween koji smanjuje
##      "WaterLevel" ColorRect visinu), otvara "vrata za idući nivo".
##
## Napomena: kad su implementirane sve tri PuzzleBase podklase i njihova
## scena (Island2.tscn po uzoru na Island1.tscn), ova skripta postaje
## identična po strukturi Island1.gd - samo postavlja island_id/next_island
## i (opcionalno) posebnu logiku porasta/pada vode koja je specifična
## za ovaj otok.

func _ready() -> void:
	island_id = GameEnums.Island.URED_KOJI_TONE
	next_island = GameEnums.Island.KAZALISTE
	super._ready()

	var liska: Liska = get_tree().get_first_node_in_group("liska")
	if liska:
		liska.set_visual_form(Liska.VizualnaForma.ORIGAMI_LOMLJIVA)
