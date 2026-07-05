extends IslandBase
## Island4 - "Labirint iskrivljenih zrcala" (STUB / PREDLOŽAK)
##
## Jezgra traume - krivnja zbog smrti majke. Liska prelazi u
## PROZIRNA_UTVARA formu (dno depresije počinje).
##
## TODO - tri zagonetke za implementirati:
##
## 1) "Pravilo napuklog stakla"
##    - Više "VelikoOgledalo_N" (Interactable) koja pri interakciji SAMO
##      prikazuju dijalog s optužbom (negativan feedback, NE rješavaju
##      zagonetku - namjerno "krivi put" po sinopsisu).
##    - Jedno skriveno "NapuklоOgledalo" (Interactable, vizualno manje
##      istaknuto/skriveno u kutu scene) čiji CompletionTrigger (bez
##      required_symbols) odmah rješava zagonetku uz tekst "Nisi mogla
##      znati."
##
## 2) "Zapisnik propuštenog"
##    - Standardni obrazac: CollectSymbol "uspomena_kasetofon",
##      "uspomena_glazbena_kutija", (treći izvor po potrebi) ->
##      CompletionTrigger "PisacaMasina" traži sve -> mark_solved,
##      reward_symbol_id = "nedovrseno_pismo_majci".
##
## 3) "Soba koja se steže"
##    - Posebna mehanika: zidovi (ColorRect "ZidLijevi/Desni/Gornji/Donji")
##      se kontinuirano približavaju (Tween u _process ili poseban
##      "ShrinkingRoom.gd" skript). Zaustavlja se OTVARANJEM "ObiteljskiAlbum"
##      Interactable-a i listanjem N stranica (niz DialogueManager.say()
##      poziva, svaki poziv usporava/vraća zid - implementirati kroz
##      signal DialogueManager.line_shown povezan na smanjenje brzine
##      stezanja). Na zadnjoj stranici (majčina fotografija) zove se
##      mark_solved() i zidovi se Tween-om vraćaju na početnu poziciju.
##
## Napomena: ovo je najkompleksniji otok - "Soba koja se steže" je jedina
## zagonetka u igri s aktivnim "pritiskom vremena/prostora", pa joj
## treba posebna pažnja pri testiranju da ne bude frustrirajuća.

func _ready() -> void:
	island_id = GameEnums.Island.LABIRINT_ZRCALA
	next_island = GameEnums.Island.PRAZNA_SOBA
	super._ready()

	var liska: Liska = get_tree().get_first_node_in_group("liska")
	if liska:
		liska.set_visual_form(Liska.VizualnaForma.PROZIRNA_UTVARA)
