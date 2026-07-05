# Arhitektura sna

Interaktivna narativna igra o unutarnjem egzilu, gubitku i pomirenju sa sobom.
Godot projekt (GDScript), ciljna platforma: **Windows 11** (desktop export,
bez posebnih platformskih ovisnosti).

Ovaj repozitorij sadrži **funkcionalnu arhitekturu igre** i **potpuno
implementiran Otok I** ("Šuma utočišta i zaboravljenih stvari") kao
referentni primjer. Otoci II–VI su pripremljeni kao dobro dokumentirani
predlošci (`scripts/islands/stubs/`) koji koriste iste generičke sustave,
pa se implementiraju bez potrebe za novom arhitekturom.

Grafika i zvuk **nisu** dio ovog paketa (po dogovoru) - svi vizuali su
jednostavni `ColorRect` placeholderi jasno označeni `TODO(art)` komentarima
na mjestima gdje ih treba zamijeniti finalnom grafikom/animacijama.

## Zahtjevi

- **Godot Engine 4.6** (stable), .NET nije potreban - projekt
  koristi čisti GDScript.
- Windows 11 za razvoj i testiranje (projekt je platformski neutralan,
  export postavke za Windows treba dodati u Project > Export kad se
  bude pripremao build).

## Pokretanje projekta

1. Otvori Godot Engine.
2. "Import" -> odaberi `project.godot` iz ovog foldera.
3. Pokreni scenu `scenes/Main.tscn` (F5 ili gumb Play).
4. Upravljanje:
   - `W A S D` ili strelice - kretanje Liske
   - `E` ili `Space` - interakcija / nastavak dijaloga

## Struktura projekta

```
ArhitekturaSna/
├── project.godot                  # Konfiguracija, autoload-ovi, input mapa
├── scenes/                        # .tscn scene (vizualni sastav igre)
│   ├── Main.tscn                  # Ulazna scena (Otok I + UI)
│   ├── Liska.tscn                 # Igrivi lik
│   ├── DialogueBox.tscn           # UI dijalog
│   ├── HUD.tscn                   # Privremeni debug HUD
│   └── Island1.tscn               # Kompletan Otok I
├── scripts/
│   ├── autoload/                  # Globalni singletoni + GameEnums.gd (vidi dolje)
│   ├── entities/                  # Liska + generički interaktivni objekti
│   ├── world/                     # PuzzleBase, IslandBase (bazne klase)
│   ├── islands/island1/           # Konkretna implementacija Otoka I
│   ├── islands/stubs/             # Predlošci za Otoke II-VI
│   └── ui/                        # DialogueBox, HUD skripte
└── docs/
	└── DESIGN_DOCUMENT.md         # Detaljna arhitektura i mapiranje priče na kod
```

## Autoload (globalni) sustavi

| Autoload           | Odgovornost                                                        |
|---------------------|---------------------------------------------------------------------|
| `GameManager`       | Trenutni otok, riješene zagonetke, dovršeni otoci, signali napretka |
| `SymbolInventory`   | Prikupljeni narativni simboli/predmeti (za zagonetke i finalni Vrt) |
| `DialogueManager`   | Red čekanja linija teksta i njihov prikaz kroz `DialogueBox`        |

> `GameEnums.gd` (u istom folderu) **nije** autoload - to je `class_name`
> klasa koja samo drži zajedničke enume (npr. `GameEnums.Island`). Namjerno
> je izdvojena iz `GameManager`-a kako bi tip enuma bio pouzdano
> razrješiv kao `@export` tip u drugim skriptama, bez oslanjanja na
> ime autoload singletona (poznat izvor "parse error" grešaka).

## Placeholder grafika (uključena)

Kako bi projekt izgledao kao **kompletan koncept**, a ne samo obojeni
pravokutnici, dodane su jednostavne generirane PNG sličice u
`assets/placeholder/`:

| Datoteka                | Koristi se za                                              |
|--------------------------|--------------------------------------------------------------|
| `liska_fox.png`          | Liska (trenutno jedan statičan prikaz, prednji pogled)       |
| `tile_grass_iso.png`     | Izometrijska pločica terena (128×64, generira ih `TerrainGenerator.gd` u kodu) |
| `marker_collect.png`     | Svi predmeti koje igrač prikuplja (`CollectSymbol`)          |
| `marker_trigger.png`     | Sva mjesta gdje se zagonetka rješava (`CompletionTrigger`)   |
| `ljuljacka_seat.png`     | Ljuljačka na Otoku I                                          |

Sve su generirane programatski (Python/Pillow) kao vizualno dosljedan,
ali namjerno jednostavan privremeni set - **zamijeni ih svojom grafikom
kad bude spremna**, prateći upute u `docs/DESIGN_DOCUMENT.md` (poglavlje
8.1 "Specifikacija grafike za izometriju"). Nazivi čvorova (`Visual`,
`VisualPlaceholder`) su ostali isti kako bi zamjena teksture u Godot
editoru bila trivijalna (samo odaberi novi `Texture2D` na istom čvoru).

## Napomene o Godot 4.6

Projekt je testiran/pisan za **Godot 4.6**. Teren se ne generira ručnim
crtanjem u `.tscn` datoteci (rizik od grešaka pri parsiranju kompleksnog
`TileSet` formata), već **programatski u kodu** (`TerrainGenerator.gd`)
- `TileSet` i `TileSetAtlasSource` se konstruiraju u `_ready()` i polje
pločica se popuni pozivima `set_cell()`. Kad budeš imao gotov, ručno
oslikan teren u editoru, jednostavno ukloni `TerrainGenerator.gd` skriptu
s `TileMapLayer` čvora i dodijeli svoj `TileSet` resurs.



- ✅ Temeljna arhitektura (autoload sustavi, `PuzzleBase`, `IslandBase`,
  `Interactable`, `CollectSymbol`, `CompletionTrigger`)
- ✅ Liska - kretanje, interakcija, vizualne forme (topla / origami / utvara)
- ✅ UI - dijalog box, privremeni HUD
- ✅ **Otok I - potpuno implementiran** (3 zagonetke, scena, dijalozi)
- 🔲 Otoci II-VI - arhitektura pripremljena (`scripts/islands/stubs/`),
  detaljne TODO napomene po zagonetki, potrebno je doraditi scene i
  po potrebi par specifičnih mehanika (npr. reflektor na Otoku III,
  sekvenca "sobe koja se steže" na Otoku IV, izbori na Otoku VI)
- 🔲 Grafika, animacije, zvuk (namjerno izvan opsega ovog paketa)
- 🔲 Sustav spremanja/učitavanja igre (GameManager već drži stanje u
  memoriji strukturirano tako da se lako serijalizira u JSON/Resource
  kad se odluči na format spremanja)

Detaljnije objašnjenje arhitekture, obrazaca i uputa za nastavak rada
nalazi se u [`docs/DESIGN_DOCUMENT.md`](docs/DESIGN_DOCUMENT.md).
