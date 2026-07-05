extends IslandBase
## Island5 - "Prazna soba pod kišom" (STUB / PREDLOŽAK)
##
## Dno depresije - potpuna izolacija. Liska ostaje u PROZIRNA_UTVARA formi.
## Ovo je otok "apsolutnog minimalizma" - namjerno najmanje objekata u
## sceni od svih otoka (u skladu s ogoljenom, sivom estetikom iz sinopsisa).
##
## TODO - tri zagonetke za implementirati:
##
## 1) "Prihvaćanje tame"
##    - Suprotno od uobičajenog "riješi akcijom" obrasca: zagonetka se
##      rješava NEDJELOVANJEM. Implementirati kao poseban PuzzleBase
##      "PrihvacanjeTame.gd" koji u _process broji vrijeme MIROVANJA
##      (Liska.velocity == Vector2.ZERO i nema pritisnutih tipki) unutar
##      određenog radijusa od svjetiljke, npr. 3 sekunde -> mark_solved.
##      Svaki pokušaj interakcije sa svjetiljkom (popravljanje) treba
##      RESETIRATI timer i prikazati dijalog "Mrak se samo povećava."
##
## 2) "Frekvencija tišine"
##    - CompletionTrigger-like, ali s REDOSLIJEDOM: "Radio" Interactable
##      ciklički prolazi kroz niz zapisa glasova (svaki interact() pomiče
##      na sljedeću frekvenciju/dijalog). Zagonetka zahtijeva da igrač
##      odsluša SVAKU liniju do kraja (ne prekida DialogueManager.advance()
##      prerano) - implementirati brojač _voices_heard koji se povećava
##      samo kad DialogueManager.sequence_finished dođe do kraja tog glasa.
##      Nakon svih glasova -> mark_solved (frekvencija čiste tišine).
##
## 3) "Vrata bez kvake"
##    - CompletionTrigger na "Vrata" koji NE traži klasične required_symbols
##      predmete, već provjerava has_symbol("uvela_biljka") ILI
##      has_symbol("stara_fotografija") (biljka iz ove sobe ili fotografija
##      s prethodnog otoka - "ILI" logika koju CompletionTrigger trenutno
##      ne podržava nativno, pa ovdje treba lagano proširiti generičku
##      klasu ili napisati specifičnu provjeru unutar override-ane
##      _on_interact() metode u posebnoj podklasi).
##
## Napomena: Otok V bi trebao vizualno biti najtiši i najsporiji - izbjegavaj
## dodavanje glazbe/zvukova "napetosti" kad se audio naknadno doda; sinopsis
## eksplicitno traži tišinu i minimalizam kao emocionalni alat.

func _ready() -> void:
	island_id = GameEnums.Island.PRAZNA_SOBA
	next_island = GameEnums.Island.VRT_NA_RUBU_JAVE
	super._ready()

	var liska: Liska = get_tree().get_first_node_in_group("liska")
	if liska:
		liska.set_visual_form(Liska.VizualnaForma.PROZIRNA_UTVARA)
