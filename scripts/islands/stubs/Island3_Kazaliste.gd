extends IslandBase
## Island3 - "Kazalište praznih sjedala" (STUB / PREDLOŽAK)
##
## Metafora propalih međuljudskih odnosa i usamljenosti. Liska ostaje u
## ORIGAMI_LOMLJIVA formi (kriza se nastavlja/pojačava).
##
## TODO - tri zagonetke za implementirati:
##
## 1) "Monolog u dvoje"
##    - Ovo NIJE standardni CollectSymbol/CompletionTrigger obrazac -
##      treba prošireni DialogueManager tok gdje igrač "odglumi" scenu:
##      niz DialogueManager.say() poziva gdje igrač tipkom interact
##      BIRA hoće li nastaviti eskalaciju. Predlažem posebnu PuzzleBase
##      podklasu "MonologUDvoje.gd" s internim koracima (int _step) koja
##      na svaki interact() pomiče _step i na zadnjem koraku zove
##      mark_solved(). Repliciranje "glasa s druge strane koji nestaje"
##      implementirati kao dijaloške linije koje NAMJERNO izostavljaju
##      odgovor (prazan red ili "...").
##
## 2) "Osvjetljavanje praznine"
##    - Reflektor kojim igrač cilja (Node2D koji prati miš ili
##      strelice/WASD - poseban input, ne standardno kretanje).
##    - Niz "PraznoSjedalo1..N" (Interactable) - svaka pogodena
##      pokreće kratki dijalog ("Nismo te više mogli dosegnuti.").
##    - Zadnje, "SjenaLene" sjedalo u središtu - njegov CompletionTrigger
##      (bez required_symbols, samo redoslijed: mora biti POSLJEDNJE
##      pogođeno) rješava zagonetku.
##
## 3) "Skidanje maski"
##    - Tri CollectSymbol objekta u "Garderobi": "maska_partnerica",
##      "maska_oprastanje", "maska_dobro_sam" - simbolički predstavljaju
##      lažne identitete koje igrač MORA "odložiti" (dodati u inventar =
##      metaforички "skinuti sa sebe").
##    - CompletionTrigger "Zastor" traži sve tri maske -> mark_solved,
##      podiže zastor (Tween na "Zastor" ColorRect position/scale).
##
## Napomena: kazališni reflektor (zagonetka 2) je jedina mehanika u
## cijeloj igri koja treba pravi "aiming" input - ostatak igre koristi
## isključivo kretanje + interact, po dizajnu jednostavnosti kontrola.

func _ready() -> void:
	island_id = GameEnums.Island.KAZALISTE
	next_island = GameEnums.Island.LABIRINT_ZRCALA
	super._ready()

	var liska: Liska = get_tree().get_first_node_in_group("liska")
	if liska:
		liska.set_visual_form(Liska.VizualnaForma.ORIGAMI_LOMLJIVA)
