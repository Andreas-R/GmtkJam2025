class_name GameUiManager

extends Node

@export var demand_above_color: Color = Color.GREEN
@export var demand_at_color: Color = Color.YELLOW
@export var demand_below_color: Color = Color.RED

@onready var game_manager: GameManager = $/root/Main/GameManager
@onready var orbit_manager: OrbitManager = $/root/Main/OrbitManager
@onready var demand_manager: DemandManager = $/root/Main/DemandManager
@onready var demandPanel: Control = $DemandPanel
@onready var demandValueLabel: Label = $DemandPanel/HBoxContainer/Value
@onready var nextOrbitPanel: Control = $NextOrbitPanel
@onready var nextOrbitValueLabel: Label = $NextOrbitPanel/HBoxContainer/Value

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
    demandValueLabel.text = str(satellite_count, "/", demand_manager.demand)
    if satellite_count > demand_manager.demand:
        demandValueLabel.set("theme_override_colors/font_color", demand_above_color)
    elif satellite_count < demand_manager.demand:
        demandValueLabel.set("theme_override_colors/font_color", demand_below_color)
    else:
        demandValueLabel.set("theme_override_colors/font_color", demand_at_color)

func update_next_orbit(value: int):
    nextOrbitValueLabel.text = str(value)

func hide_next_orbit():
    var blend_out_tween = get_tree().create_tween()
    blend_out_tween.tween_property(nextOrbitPanel, "modulate", Color.TRANSPARENT, 2.0)
