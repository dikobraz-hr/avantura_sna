class_name GameEnums
extends RefCounted
## GameEnums
##
## Zajednički enumi koje koristi više skripti u igri (GameManager,
## IslandBase, HUD, sve Island*.gd skripte...).
##
## NAMJERNO izdvojeno u posebnu `class_name` klasu, umjesto da enum bude
## ugniježđen unutar autoload skripte (npr. GameManager.gd) i referenciran
## preko imena singletona (npr. `GameManager.Island`). Taj obrazac
## (nested enum + @export tipiziranje preko imena autoload-a) je poznato
## nepouzdan izvor "parse error" grešaka u GDScriptu - naime, autoload
## identifikator referira INSTANCU čvora, a `@export var x: NekiTip`
## treba moći razriješiti `NekiTip` kao KLASU u vrijeme parsiranja.
## `class_name` klasa (poput ove) je jednoznačno i pouzdano razrješiva
## kao tip u SVIM situacijama (export varijable, parametri funkcija,
## povratne vrijednosti), bez obzira na redoslijed učitavanja autoload-ova.
##
## Ova klasa se nikad ne instancira - služi samo kao "imenski prostor"
## za enume, po uzoru na uobičajen GDScript obrazac.

## Enum svih otoka podsvijesti, redoslijedom kojim se prolaze u priči.
enum Island {
	SUMA_UTOCISTA,      # Otok I
	URED_KOJI_TONE,     # Otok II
	KAZALISTE,          # Otok III
	LABIRINT_ZRCALA,    # Otok IV
	PRAZNA_SOBA,        # Otok V
	VRT_NA_RUBU_JAVE    # Otok VI (finale)
}
