extends Node2D
## Ljuljacka
##
## Vizualni simbol emocionalne stagnacije na Otoku I - njiše se sama od
## sebe, bez vjetra, dok igrač ne riješi zagonetku "Zaustavljanje petlje".
##
## Placeholder implementacija: rotira dijete "VisualPlaceholder" oko
## gornje točke (pivot) koristeći sin() krivulju. Kad stigne finalna
## grafika, ovo se može zamijeniti AnimationPlayer resursom bez izmjene
## logike zaustavljanja (stop_swinging).

@export var swing_amplitude_degrees: float = 25.0
@export var swing_speed: float = 2.0

@onready var _visual: Node2D = get_node_or_null("VisualPlaceholder")

var _is_swinging: bool = true
var _time: float = 0.0


func _process(delta: float) -> void:
	if not _is_swinging or not _visual:
		return

	_time += delta * swing_speed
	_visual.rotation_degrees = sin(_time) * swing_amplitude_degrees


## Poziva se iz ZaustavljanjePetlje.gd čim igrač riješi zagonetku.
## Njihanje se postupno smiruje umjesto naglog prekida (bolji "feel").
func stop_swinging() -> void:
	_is_swinging = false
	if _visual:
		var tween: Tween = create_tween()
		tween.tween_property(_visual, "rotation_degrees", 0.0, 1.5)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
