class_name GameUiManager

extends Node

@export var demand_above_color: Color = Color.GREEN
@export var demand_at_color: Color = Color.YELLOW
@export var demand_below_color: Color = Color.RED

@export var health_full_color: Color = Color.GREEN
@export var health_empty_color: Color = Color.RED

@onready var game_manager: GameManager = $/root/Main/GameManager
@onready var orbit_manager: OrbitManager = $/root/Main/OrbitManager
@onready var demand_manager: DemandManager = $/root/Main/DemandManager
@onready var demand_panel: Control = $DemandPanel
@onready var demand_value_label: Label = $DemandPanel/VBoxContainer/HBoxContainer/Value
@onready var next_orbit_panel: Control = $NextOrbitPanel
@onready var next_orbit_value_label: Label = $NextOrbitPanel/HBoxContainer/Value
@onready var health_bar: TextureProgressBar = $DemandPanel/VBoxContainer/HBoxContainer2/TextureProgressBar
@onready var left_arrow_1: TextureRect = $DemandPanel/VBoxContainer/HBoxContainer2/ArrowsLeft/Arrow1
@onready var left_arrow_2: TextureRect = $DemandPanel/VBoxContainer/HBoxContainer2/ArrowsLeft/Arrow2
@onready var left_arrow_3: TextureRect = $DemandPanel/VBoxContainer/HBoxContainer2/ArrowsLeft/Arrow3
@onready var right_arrow_1: TextureRect = $DemandPanel/VBoxContainer/HBoxContainer2/ArrowsRight/Arrow1
@onready var right_arrow_2: TextureRect = $DemandPanel/VBoxContainer/HBoxContainer2/ArrowsRight/Arrow2
@onready var right_arrow_3: TextureRect = $DemandPanel/VBoxContainer/HBoxContainer2/ArrowsRight/Arrow3

func _ready():
    demand_panel.modulate = Color.TRANSPARENT
    next_orbit_panel.modulate = Color.TRANSPARENT

    left_arrow_1.visible = false
    left_arrow_2.visible = false
    left_arrow_3.visible = false
    right_arrow_1.visible = false
    right_arrow_2.visible = false
    right_arrow_3.visible = false

func _process(_delta: float):
    update_demand()

func blend_in():
    var blend_in_tween_1 = get_tree().create_tween()
    blend_in_tween_1.tween_property(demand_panel, "modulate", Color.TRANSPARENT, 1.0)
    blend_in_tween_1.tween_property(demand_panel, "modulate", Color.WHITE, 2.0)
    
    var blend_in_tween_2 = get_tree().create_tween()
    blend_in_tween_2.tween_property(next_orbit_panel, "modulate", Color.TRANSPARENT, 1.0)
    blend_in_tween_2.tween_property(next_orbit_panel, "modulate", Color.WHITE, 2.0)

func update_demand():
    var satellite_count := orbit_manager.count_satellites()
    demand_value_label.text = str(satellite_count, "/", demand_manager.demand)
    if satellite_count > demand_manager.demand:
        demand_value_label.set("theme_override_colors/font_color", demand_above_color)
    elif satellite_count < demand_manager.demand:
        demand_value_label.set("theme_override_colors/font_color", demand_below_color)
    else:
        demand_value_label.set("theme_override_colors/font_color", demand_at_color)

func update_health(value: float):
    health_bar.value = value
    health_bar.tint_progress = lerp(health_empty_color, health_full_color, value / 100.0)

func update_arrows(demand_difference: int, health: float):
    if health >= 100 || health <= 0:
        left_arrow_1.visible = false
        left_arrow_2.visible = false
        left_arrow_3.visible = false
        right_arrow_1.visible = false
        right_arrow_2.visible = false
        right_arrow_3.visible = false
        return

    right_arrow_1.visible = demand_difference >= 1
    right_arrow_2.visible = demand_difference >= 3
    right_arrow_3.visible = demand_difference >= 5
    left_arrow_1.visible = demand_difference <= -1
    left_arrow_2.visible = demand_difference <= -3
    left_arrow_3.visible = demand_difference <= -5


func update_next_orbit(value: int):
    next_orbit_value_label.text = str(value)

func hide_next_orbit():
    var blend_out_tween = get_tree().create_tween()
    blend_out_tween.tween_property(next_orbit_panel, "modulate", Color.TRANSPARENT, 2.0)
