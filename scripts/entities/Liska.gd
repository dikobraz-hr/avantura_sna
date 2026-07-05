extends CharacterBody2D
class_name Liska
## Liska
##
## Igrivi lik. Liska je personifikacija Lenine potisnute djetinje
## otpornosti i znatiželje - igrač NIKAD ne upravlja samom Lenom, samo Liskom.
##
## IZOMETRIJSKA NAPOMENA (bitno za razumijevanje kretanja):
## Kretanje je i dalje "slobodno" u pikselima (NIJE grid-locked na tile
## koordinate) - Liska se pomiče direktno po ekranskim osima. WASD/strelice
## dakle pomiču Lisku po DIJAMANT mreži izometrijskog TileMapa vizualno
## ispravno, jer su ekranske osi u Godotovom izometrijskom TileMapu već
## poravnate s "gore-desno / dolje-lijevo" dijagonalama dijamanta - NE treba
## dodatna rotacija input vektora. Ako se ikad odluči na "pravi" grid-based
## pathing (korak po korak preko pločica), to bi zahtijevalo posebnu
## nadogradnju kretanja (pretvorba u tile-koordinate + interpolacija).
##
## Ova skripta implementira:
## 1) Slobodno kretanje po 8 osi (dijagonalno normalizirano)
## 2) Detekciju kojeg od 8 smjerova (Smjer enum) je Liska trenutno okrenuta,
##    na temelju vektora kretanja - koristi se za odabir ispravne
##    sprite/animacije kad stigne izometrijska grafika (8 smjerova)
## 3) Detekciju najbližeg Interactable objekta u dosegu (preko Area2D)
## 4) "VizualnaForma" - enum koji odgovara promjenama Liskinog izgleda
##    kroz priču (topla/organska -> origami -> prozirna utvara). Trenutno
##    se manifestira kroz modulate (boju/transparentnost) placeholder
##    vizuala; kad stigne finalna grafika, ovdje se prebacuje na
##    AnimatedSprite2D animacije po (VizualnaForma, Smjer) kombinaciji.
##
## VAŽNO za y-sort: čvor koji sadrži Lisku I sve objekte otoka (npr. "World"
## u Island1.tscn) treba imati `y_sort_enabled = true` da bi se izometrijsko
## preklapanje crtalo ispravno (objekt niže na ekranu ide ISPRED). Ovo se
## postavlja na razini scene, ne u ovoj skripti.

## Vizualne/simboličke forme Liske, koje odgovaraju Lenino emocionalnom
## stanju na trenutnom otoku podsvijesti (vidi sinopsis).
enum VizualnaForma {
	TOPLA_ORGANSKA,   # Otok I - šuma, utočište
	ORIGAMI_LOMLJIVA, # Otoci II-III - kriza, nesigurnost
	PROZIRNA_UTVARA   # Otoci IV-V - dno depresije
}

## 8 smjerova okretanja Liske, poredanih u smjeru kazaljke sata počevši
## od sjevera (gore). Odgovara rasporedu redaka u budućem sprite sheetu -
## vidi docs/DESIGN_DOCUMENT.md, poglavlje o art specifikaciji.
enum Smjer {
	SJEVER,
	SJEVEROISTOK,
	ISTOK,
	JUGOISTOK,
	JUG,
	JUGOZAPAD,
	ZAPAD,
	SJEVEROZAPAD
}

@export var move_speed: float = 220.0

## Referenca na vizualni placeholder (npr. Sprite2D) - postavlja se u sceni.
## Kad art stigne, ovo postaje AnimatedSprite2D i _apply_visual_form() se
## prilagodi.
@onready var visual_placeholder: Node = get_node_or_null("VisualPlaceholder")

## Area2D koja detektira Interactable objekte u blizini.
@onready var interaction_area: Area2D = get_node_or_null("InteractionArea")

## Trenutno najbliži interaktivni objekt u dosegu (ili null ako nema).
var _current_interactable: Interactable = null

## Lista svih Interactable objekata trenutno unutar interaction_area.
var _nearby_interactables: Array[Interactable] = []

var _current_form: VizualnaForma = VizualnaForma.TOPLA_ORGANSKA

## Trenutni smjer okrenutosti - zadržava zadnji smjer kad Liska stoji
## (ne resetira se na SJEVER kad igrač otpusti tipke).
var current_direction: Smjer = Smjer.JUG

## Emitira se SAMO kad se smjer stvarno promijeni - AnimatedSprite2D
## (kad stigne art) treba slušati ovo umjesto provjere svaki frame.
signal direction_changed(new_direction: Smjer)


func _ready() -> void:
	if interaction_area:
		interaction_area.area_entered.connect(_on_interaction_area_entered)
		interaction_area.area_exited.connect(_on_interaction_area_exited)

	set_visual_form(VizualnaForma.TOPLA_ORGANSKA)


func _physics_process(_delta: float) -> void:
	_handle_movement()
	_handle_interact_input()


## Slobodno kretanje po 8 (dijagonalno normaliziranih) osi + ažuriranje
## smjera okrenutosti za buduće izometrijske animacije.
func _handle_movement() -> void:
	var input_vector: Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	if input_vector.length() > 0.0:
		input_vector = input_vector.normalized()
		_update_direction(input_vector)

	velocity = input_vector * move_speed
	move_and_slide()


## Pretvara vektor kretanja u jedan od 8 Smjer enum vrijednosti.
## Krug se dijeli na 8 jednakih isječaka od 45°, počevši od SJEVER (gore).
func _update_direction(input_vector: Vector2) -> void:
	# atan2(x, -y) daje kut gdje je 0 = gore (sjever), rastuci u smjeru kazaljke sata.
	var angle: float = atan2(input_vector.x, -input_vector.y)
	if angle < 0.0:
		angle += TAU

	var sector: int = int(round(angle / (TAU / 8.0))) % 8
	var new_direction: Smjer = sector

	if new_direction != current_direction:
		current_direction = new_direction
		direction_changed.emit(current_direction)


func _handle_interact_input() -> void:
	if not Input.is_action_just_pressed("interact"):
		return

	_update_closest_interactable()

	if _current_interactable:
		_current_interactable.try_interact(self)


## Kad se pojavi novi Interactable u dosegu, dodaj ga na listu kandidata.
func _on_interaction_area_entered(area: Area2D) -> void:
	if area is Interactable:
		_nearby_interactables.append(area)
		_update_closest_interactable()


func _on_interaction_area_exited(area: Area2D) -> void:
	if area is Interactable:
		_nearby_interactables.erase(area)
		_update_closest_interactable()


## Od svih Interactable objekata u dosegu, odabire najbliži - to je onaj
## s kojim će "interact" tipka stupiti u interakciju. Ako je samo jedan
## objekt u dosegu (čest slučaj), ovo je trivijalno brzo.
func _update_closest_interactable() -> void:
	_current_interactable = null
	var closest_dist: float = INF

	for obj in _nearby_interactables:
		if not is_instance_valid(obj):
			continue
		var d: float = global_position.distance_squared_to(obj.global_position)
		if d < closest_dist:
			closest_dist = d
			_current_interactable = obj


## Postavlja vizualnu formu Liske (npr. pri prijelazu na novi otok).
## GameManager ili Island skripta poziva ovo kad se promijeni emocionalni
## kontekst priče.
func set_visual_form(form: VizualnaForma) -> void:
	_current_form = form
	_apply_visual_form(form)


## Placeholder implementacija - dok nema finalne grafike, mijenjamo boju/
## transparentnost placeholder Sprite2D-a kao vizualni signal forme.
## TODO(art): zamijeniti s AnimatedSprite2D čije se animacije biraju
## kombinacijom (VizualnaForma, current_direction) - npr. animacija
## "topla_organska_jug_idle", "topla_organska_jug_walk", itd. po uzoru
## na SpriteFrames imenovanje. current_direction je već dostupan preko
## `direction_changed` signala, tako da promjena forme + smjera zajedno
## određuje koja se animacija pušta.
func _apply_visual_form(form: VizualnaForma) -> void:
	if not visual_placeholder:
		return

	match form:
		VizualnaForma.TOPLA_ORGANSKA:
			visual_placeholder.modulate = Color(0.95, 0.65, 0.35, 1.0) # topla narančasta
		VizualnaForma.ORIGAMI_LOMLJIVA:
			visual_placeholder.modulate = Color(0.85, 0.85, 0.9, 0.85) # blijedo, papirnato
		VizualnaForma.PROZIRNA_UTVARA:
			visual_placeholder.modulate = Color(0.7, 0.8, 0.95, 0.4) # gotovo prozirna
