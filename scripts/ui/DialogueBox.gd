extends CanvasLayer
## DialogueBox
##
## UI prikaz narativnog teksta koji dolazi iz DialogueManager autoloada.
## Skriva se kad nema aktivnog dijaloga, prikazuje se i ažurira tekst
## kad DialogueManager emitira `line_shown`.
##
## Igrač nastavlja dijalog istom tipkom kojom se interagira sa svijetom
## ("interact") - ovo je namjerna odluka radi jednostavnosti kontrola.

@onready var _panel: Panel = $Panel
@onready var _label: Label = $Panel/MarginContainer/Label
@onready var _continue_hint: Label = $Panel/ContinueHint


func _ready() -> void:
	DialogueManager.line_shown.connect(_on_line_shown)
	DialogueManager.sequence_finished.connect(_on_sequence_finished)
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not DialogueManager.is_active:
		return

	if event.is_action_pressed("interact"):
		DialogueManager.advance()
		# Spriječi da isti pritisak tipke "propadne" do Liskine _handle_interact_input
		# i nenamjerno aktivira objekt u svijetu iza dijaloga.
		get_viewport().set_input_as_handled()


func _on_line_shown(text: String) -> void:
	visible = true
	if _label:
		_label.text = text


func _on_sequence_finished() -> void:
	visible = false
