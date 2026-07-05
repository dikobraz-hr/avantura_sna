extends CanvasLayer
## HUD
##
## Minimalan privremeni prikaz stanja igre dok ne stigne finalni UI dizajn:
## broj prikupljenih simbola i naziv trenutnog otoka. Koristan i za
## debugiranje tijekom developmenta.

@onready var _label: Label = $InfoLabel


func _ready() -> void:
	SymbolInventory.inventory_changed.connect(_refresh)
	GameManager.island_changed.connect(_on_island_changed)
	_refresh()


func _refresh() -> void:
	if not _label:
		return
	var island_name: String = GameEnums.Island.keys()[GameManager.current_island]
	var symbol_count: int = SymbolInventory.get_all_collected().size()
	_label.text = "Otok: %s   |   Simboli: %d" % [island_name, symbol_count]


func _on_island_changed(_island: GameEnums.Island) -> void:
	_refresh()
