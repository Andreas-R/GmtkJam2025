class_name UiManager

extends Node

@onready var game_manager: GameManager = $/root/Main/GameManager
@onready var orbit_manager: OrbitManager = $/root/Main/OrbitManager
@onready var demandPanel: Control = $GameUI/DemandPanel
@onready var demandValueLabel: Label = $GameUI/DemandPanel/HBoxContainer/Value
@onready var nextOrbitPanel: Control = $GameUI/NextOrbitPanel
@onready var nextOrbitValueLabel: Label = $GameUI/NextOrbitPanel/HBoxContainer/Value

func _ready():
    demandPanel.modulate = Color.TRANSPARENT
    nextOrbitPanel.modulate = Color.TRANSPARENT

func _process(_delta: float):
    update_demand()

func blend_in():
    var blend_in_tween_1 = get_tree().create_tween()
    blend_in_tween_1.tween_property(demandPanel, "modulate", Color.TRANSPARENT, 1.0)
    blend_in_tween_1.tween_property(demandPanel, "modulate", Color.WHITE, 2.0)
    
    var blend_in_tween_2 = get_tree().create_tween()
    blend_in_tween_2.tween_property(nextOrbitPanel, "modulate", Color.TRANSPARENT, 1.0)
    blend_in_tween_2.tween_property(nextOrbitPanel, "modulate", Color.WHITE, 2.0)

func update_demand():
    var satellite_count := orbit_manager.count_satellites()
    demandValueLabel.text = str(satellite_count, "/", "?")

func update_next_orbit(value: int):
    nextOrbitValueLabel.text = str(value)

func hide_next_orbit():
    var blend_out_tween = get_tree().create_tween()
    blend_out_tween.tween_property(nextOrbitPanel, "modulate", Color.TRANSPARENT, 2.0)
