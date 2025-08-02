class_name RocketController

extends Control

@export var index: int = 0
@export var amount: int = 1
@export var satellite_type: Satellite.SatelliteType = Satellite.SatelliteType.DEFAULT

@onready var upgrade_ui_manager: UpgradeUiManager = $/root/Main/UI/UpgradeUI
@onready var center: Control = $Center
@onready var satellite_icon: Control = $Center/Cargo/Satellite
@onready var shield_satellite_icon: Control = $Center/Cargo/ShieldSatellite
@onready var charger_satellite_icon: Control = $Center/Cargo/ChargerSatellite
@onready var amount_label: Label = $Center/AmountLabel/Value

var ellapsed_time: float = 0
var wobble_speed: float = 3.0
var wobble_factor: float = 0.0
var wobble_strength: float = 20.0
var start_pos: Vector2
var fly_tween: Tween
var shrink_tween: Tween
var hover_tween: Tween
var hovered: bool = false
var highlighted: bool = false

func _ready() -> void:
    start_pos = position
    amount_label.text = str("+", amount)
    satellite_icon.visible = true if satellite_type == Satellite.SatelliteType.DEFAULT else false
    shield_satellite_icon.visible = true if satellite_type == Satellite.SatelliteType.SHIELDER else false
    charger_satellite_icon.visible = true if satellite_type == Satellite.SatelliteType.CHARGER else false

func _process(delta: float) -> void:
    ellapsed_time += delta
    center.position = Vector2(0.0, sin((2.0 * PI * (index / 3.0)) + ellapsed_time * wobble_speed) * wobble_strength)

    if (hovered != highlighted) && upgrade_ui_manager.can_select:
        hightlight(hovered)

    if highlighted && !upgrade_ui_manager.can_select:
        hightlight(false)

func reset_rocket():
    position = start_pos
    scale = Vector2.ONE

func fly_in():
    if fly_tween != null:
        fly_tween.kill()
    fly_tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
    fly_tween.tween_property(self, "position", Vector2(start_pos.x, 0), upgrade_ui_manager.fly_in_time).set_delay((2 - index) * upgrade_ui_manager.rocket_offset_time)

func fly_out():
    if fly_tween != null:
        fly_tween.kill()
    fly_tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
    fly_tween.tween_property(self, "position", Vector2(start_pos.x, -start_pos.y), upgrade_ui_manager.fly_out_time).set_delay((2 - index) * upgrade_ui_manager.rocket_offset_time)

func shrink():
    if shrink_tween != null:
        shrink_tween.kill()
    shrink_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel(true)
    shrink_tween.tween_property(self, "scale", Vector2.ZERO, upgrade_ui_manager.shrink_time)
    shrink_tween.tween_property(self, "position", Vector2(start_pos.x * 0.3, position.y), upgrade_ui_manager.shrink_time)

func hightlight(highlighted_: bool):
    highlighted = highlighted_

    if hover_tween != null:
        hover_tween.kill()
    hover_tween = create_tween().set_ease(Tween.EASE_IN_OUT)
    if highlighted:
        hover_tween.tween_property(center, "scale", Vector2(1.2, 1.2), 0.1)
    else:
        hover_tween.tween_property(center, "scale", Vector2.ONE, 0.1)



func _on_mouse_entered() -> void:
    hovered = true

func _on_mouse_exited() -> void:
    hovered = false

func _on_pressed() -> void:
    upgrade_ui_manager.select_rocket(self)
