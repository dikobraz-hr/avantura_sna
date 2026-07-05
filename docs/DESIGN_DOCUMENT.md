# Arhitektura sna — Tehnički dokument

## 1. Filozofija arhitekture

Sinopsis opisuje 6 otoka podsvijesti, svaki s 3 zagonetke, i sve zagonetke
imaju istu dubinsku strukturu, iako se površinski razlikuju:

1. Igrač **prikupi** jedan ili više narativnih predmeta/uvjeta u prostoru.
2. Igrač te uvjete **primijeni** na određenom mjestu ("okidaču").
3. Ako su uvjeti ispunjeni, zagonetka se rješava: emitira se signal,
   otključava se dijalog/flashback, i svijet se vizualno promijeni.

Zbog toga je arhitektura izgrađena oko **tri generičke, ponovno iskoristive
klase** umjesto pisanja posebnog kôda za svaku od ~18 zagonetki:

- `Interactable` — bazna klasa za sve objekte s kojima se može interagirati.
- `CollectSymbol` (nasljeđuje `Interactable`) — "pokupi predmet X".
- `CompletionTrigger` (nasljeđuje `Interactable`) — "provjeri uvjete, ako
  su ispunjeni, riješi zagonetku Y".
- `PuzzleBase` — logička jedinica koju `IslandBase` prati da bi znao kada je
  cijeli otok dovršen.

Ovaj obrazac pokriva **većinu** zagonetki iz sinopsisa direktno (npr.
Destilacija odjeka, Zaustavljanje petlje, Pismo samoj sebi, Pauza na
prozoru, Zapisnik propuštenog, Kolaž života...). Manji broj zagonetki ima
jedinstvenu mehaniku (npr. "Soba koja se steže", kazališni reflektor,
"Prihvaćanje tame" kroz nedjelovanje) i za njih su ostavljene detaljne
TODO napomene u `scripts/islands/stubs/` koje objašnjavaju preporučeni
pristup bez narušavanja postojeće arhitekture.

## 2. Dijagram ovisnosti sustava

```
					 ┌───────────────┐
					 │  GameManager  │  (autoload, globalno stanje)
					 └───────┬───────┘
							 │ signali: island_changed, puzzle_solved,
							 │           island_completed
			  ┌──────────────┼──────────────┐
			  │              │              │
	┌─────────▼───────┐  ┌───▼────┐   ┌─────▼──────┐
	│  IslandBase      │  │  UI    │   │ SymbolInventory│ (autoload)
	│  (po otoku)      │  │ (HUD)  │   └─────┬──────┘
	└────────┬─────────┘  └────────┘         │
			 │ prati djecu                    │ has_symbol/has_all
	┌────────▼─────────┐                      │
	│   PuzzleBase      │◄─────────────────────┘
	│  (po zagonetki)   │   CompletionTrigger provjerava inventar
	└────────┬──────────┘   i poziva mark_solved() na cilju
			 │ mark_solved()
	┌────────▼──────────────────┐
	│ CollectSymbol / Completion-│  (Interactable u svijetu, Area2D)
	│ Trigger (u sceni otoka)    │
	└────────┬───────────────────┘
			 │ try_interact()
	   ┌─────▼─────┐
	   │   Liska    │  (igrivi lik, detektira Interactable u dosegu)
	   └────────────┘
```

`DialogueManager` je ortogonalan na ovo - svaka skripta (puzzle,
interactable) može mu u bilo kojem trenutku poslati `say(["..."])` bez
brige o UI detaljima.

## 3. Mapiranje: sinopsis → kod

| Element sinopsisa                       | Implementacija u kodu                                   |
|-------------------------------------------|-----------------------------------------------------------|
| Otok podsvijesti                          | `IslandBase` podklasa + odgovarajuća `.tscn` scena        |
| Zagonetka unutar otoka                    | `PuzzleBase` podklasa (jedan čvor u sceni, bez vizuala)   |
| Predmet koji igrač prikuplja               | `CollectSymbol` čvor + unos u `SymbolInventory`           |
| Mjesto gdje se "sastavlja" rješenje        | `CompletionTrigger` čvor s `required_symbols`             |
| Flashback / narativni tekst                | `DialogueManager.say([...])`, pozvano iz `_on_solved()`   |
| Liskine vizualne promjene kroz priču       | `Liska.VizualnaForma` enum + `set_visual_form()`          |
| Urušavanje otoka / prijelaz na sljedeći    | `IslandBase._on_all_puzzles_solved()` → `GameManager.set_current_island()` |
| "Kolaž života" na Otoku VI                 | `CompletionTrigger` s required_symbols = SVI simboli igre |

## 4. Kako dodati novu zagonetku (opći recept)

1. U `scripts/islands/islandN/` napravi skriptu koja nasljeđuje
   `PuzzleBase`, postavi `puzzle_id` u `_ready()` (jedinstven string,
   konvencija: `"islandN_kratki_naziv"`).
2. U sceni otoka dodaj čvor s tom skriptom pod `Puzzles`.
3. U `World` dodaj potrebne `CollectSymbol` čvorove (jedan po predmetu)
   s jedinstvenim `symbol_id`.
4. Dodaj jedan `CompletionTrigger` čvor koji referencira te `symbol_id`-ove
   kroz `required_symbols`, te `target_puzzle_path` postavljen na putanju
   do čvora iz koraka 2 (NodePath je relativan na sam trigger čvor).
5. Po potrebi override-aj `_on_solved()` u skripti iz koraka 1 za
   specifičan narativni tekst ili vizualnu posljedicu (npr. zaustavljanje
   animacije, urušavanje otoka).

Za zagonetke koje ne prate ovaj obrazac (jedinstvena mehanika), naslijedi
`PuzzleBase` i implementiraj vlastitu logiku u `_process()`/signalima, ali
i dalje pozovi `mark_solved()` kad su uvjeti ispunjeni - to je jedini
"ugovor" koji `IslandBase` očekuje.

## 5. Sustav collision layera (Godot fizika)

Korištena su dva sloja radi jednostavne detekcije interakcije:

- **Layer 1** (zadano): Liska (`CharacterBody2D`) i statična kolizija svijeta.
- **Layer 2**: svi `Interactable` čvorovi (`collision_layer = 2`).

Liskina `InteractionArea` (dijete `Liska.tscn`) ima `collision_mask = 2`,
čime detektira SVE `Interactable` objekte u svom radijusu bez obzira na
to gdje se nalaze u sceni. Kad je više objekata u dosegu istovremeno,
`Liska.gd` bira geometrijski najbliži.

## 6. Sustav spremanja igre (nije implementiran, ali arhitektura je spremna)

`GameManager._solved_puzzles` i `_completed_islands` su `Dictionary`
strukture s string/enum ključevima - trivijalno ih je serijalizirati u
JSON (`JSON.stringify()`) ili Godot `Resource` (`.tres`) format. Isto
vrijedi za `SymbolInventory._collected`. Preporuka: dodati
`GameManager.save_to_file(path)` / `load_from_file(path)` metode koje
serijaliziraju sva tri autoload-a u jedan JSON objekt, bez potrebe za
izmjenom postojeće logike zagonetki.

## 8. Izometrijska postavka (odluka: TileMap + slobodno kretanje, 8 smjerova)

Projekt je izometrijski uz sljedeće arhitekturne odluke:

- **Teren**: `TileMapLayer` s `TileSet` gdje je `tile_shape = TILE_SHAPE_ISOMETRIC`.
  Dodaje se kad stigne tileset slika (vidi specifikaciju grafike ispod).
- **Kretanje**: SLOBODNO u pikselima, NE grid-locked. WASD/strelice pomiču
  Lisku direktno po ekranskim osima - Godotov izometrijski TileMap je već
  ekranski poravnat s dijamant-mrežom, tako da nije potrebna rotacija
  input vektora.
- **Smjer okrenutosti**: `Liska.gd` sadrži `Smjer` enum (8 vrijednosti) i
  `_update_direction()` koja iz vektora kretanja izračuna kut i mapira ga
  na jedan od 8 isječaka od 45°. `current_direction` se pamti i kad Liska
  stoji (ne resetira na SJEVER). Emitira se `direction_changed` signal -
  buduća `AnimatedSprite2D` logika treba slušati taj signal umjesto da
  svaki frame provjerava smjer.
- **Y-sort**: `World` čvor u `Island1.tscn` ima `y_sort_enabled = true`, a
  Liska je NAMJERNO smještena KAO DIJETE `World` čvora (ne kao sibling) da
  bi se sortirala zajedno s ostalim objektima po dubini. Isti obrazac
  (Liska unutar `World`, `y_sort_enabled = true`) treba ponoviti u scenama
  Otoka II-VI kad se izrađuju.
- **Pozadina**: `Background` `ColorRect` ima `z_index = -10` čime ostaje
  uvijek iza svega, bez obzira na y-sort (z_index ima prioritet nad
  y-sortom unutar istog čvora).

### 8.1 Specifikacija grafike za izometriju

| Element                     | Format | Napomena                                                                 |
|------------------------------|--------|---------------------------------------------------------------------------|
| Tileset (teren)              | PNG, alpha | Dijamant pločice, preporučena veličina npr. 128×64 ili 256×128 px (širina : visina = 2:1 je standard za izometriju). Reci točnu veličinu pločice - upisuje se u `TileSet.tile_size`. |
| Liska - sprite sheet         | PNG, alpha | 8 redaka (jedan po `Smjer` enumu, redoslijed: sjever, sjeveroistok, istok, jugoistok, jug, jugozapad, zapad, sjeverozapad), N stupaca (frameovi animacije hodanja/idle po redu). Anchor/pivot na **stopalima** (dno sprite-a), ne na centru, jer se u izometriji objekt "stoji" na tlu. |
| Liska - 3 vizualne forme     | -      | Ako svaka forma (topla/origami/utvara) ima svoj potpuni set od 8 smjerova, to je 3 odvojena sprite sheeta (ili jedan veliki organiziran po formama). Reci koji pristup ti je lakši za izradu. |
| Interaktivni objekti (statični) | PNG, alpha | Nacrtani iz izometrijske perspektive (isti kut kamere kao tileset), anchor na dnu objekta (gdje "dodiruje" tlo). |

Kad se ovi asseti dostave, potrebno je:
1. Import tileset slike u Godot, kreirati `TileSet` resurs, postaviti
   `tile_shape`, `tile_size`, dodati atlas source.
2. Zamijeniti `Background` `ColorRect` s `TileMapLayer` čvorom i "naslikati"
   teren pločicama u editoru.
3. Zamijeniti `VisualPlaceholder` `ColorRect` u `Liska.tscn` s
   `AnimatedSprite2D`, uvesti `SpriteFrames` iz sprite sheeta, spojiti
   `direction_changed` i `set_visual_form()` na odabir animacije.
4. Zamijeniti `Visual` `ColorRect` čvorove kod svakog `Interactable` objekta
   sa `Sprite2D` s odgovarajućom teksturom.

## 9. Poznata ograničenja / napomene za nastavak rada

- `CompletionTrigger.consume_symbols` je pripremljen kao export varijabla,
  ali `SymbolInventory` trenutno nema metodu za brisanje simbola (namjerno
  - sinopsis traži da simboli "preživljavaju" do finalnog Vrta na Otoku VI).
  Ako neka buduća zagonetka zaista treba trošenje predmeta, dodati
  `SymbolInventory.remove(symbol_id)` metodu.
- Otok III (kazališni reflektor) i Otok IV ("soba koja se steže") su jedine
  mehanike koje odstupaju od standardnog "pokupi → primijeni" obrasca -
  vidi detaljne TODO komentare u odgovarajućim stub skriptama.
- Sav placeholder vizual koristi `ColorRect`/`modulate` boje. Kad grafika
  stigne, preporučeni redoslijed zamjene: (1) Liska sprite/animacije,
  (2) pozadine otoka, (3) interaktivni objekti, (4) UI skin.
- Zvuk (glazba, ambijentalni zvukovi, SFX interakcije) nije uopće
  posredovan kroz kod - preporuka je dodati `AudioManager` autoload
  po istom obrascu kao `DialogueManager` kad zvuk bude spreman.
