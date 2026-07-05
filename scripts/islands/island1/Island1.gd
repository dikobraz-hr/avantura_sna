extends IslandBase
## Island1 - "Šuma utočišta i zaboravljenih stvari"
##
## Prvi sloj Lenine podsvijesti: toplo, idilično utočište zamrznuto u
## vremenu. Sadrži tri zagonetke (vidi scripts/islands/island1/):
##   1. DestilacijaOdjeka   - sastavljanje napitka -> flashback
##   2. ZaustavljanjePetlje - puštanje predmeta niz rijeku -> smiruje ljuljačku
##   3. PismoSebi           - pismo samoj sebi -> urušava otok, otvara Otok II
##
## Ova skripta ne treba dodatnu logiku preko IslandBase-a osim postavljanja
## Liskine vizualne forme kad igrač uđe na otok (topla/organska forma,
## u skladu s idiličnim, ali trošnim ugođajem šume).

func _ready() -> void:
	island_id = GameEnums.Island.SUMA_UTOCISTA
	next_island = GameEnums.Island.URED_KOJI_TONE
	super._ready()

	var liska: Liska = get_tree().get_first_node_in_group("liska")
	if liska:
		liska.set_visual_form(Liska.VizualnaForma.TOPLA_ORGANSKA)
