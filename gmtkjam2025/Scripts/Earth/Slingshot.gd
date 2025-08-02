class_name Slingshot

extends Node2D

enum SlingshotState {
    IDLE,
    AIMING,
    SHOOTING,
}

static var satellite_prefab: PackedScene = load("res://Prefabs/Satellites/Satellite.tscn") as PackedScene

@export var aim_color: Color = Color.RED
@export var aim_crosshair_color: Color = Color.RED
@export var saddle_shadow: Node2D
@export var band_1_shadow: Node2D
@export var band_2_shadow: Node2D
@export var band_1_handle_shadow: Node2D
@export var band_2_handle_shadow: Node2D

@onready var main: Node2D = $/root/Main
@onready var orbit_manager: OrbitManager = $/root/Main/OrbitManager
@onready var earth: Earth = get_parent()
@onready var pivot: Node2D = $Pivot
@onready var saddle: Node2D = $Pivot/Saddle
@onready var band_1: Node2D = $Pivot/Band1
@onready var band_2: Node2D = $Pivot/Band2
@onready var band_1_handle: Node2D = $Pivot/Band1Handle
@onready var band_2_handle: Node2D = $Pivot/Band2Handle
@onready var band_1_end: Node2D = $Pivot/Saddle/Band1End
@onready var band_2_end: Node2D = $Pivot/Saddle/Band2End
@onready var crosshair: Sprite2D = $Crosshair
@onready var satellite_counter: SatelliteCounter = get_parent().find_child("SatelliteCounter")

var state: SlingshotState = SlingshotState.IDLE

var target_saddle_pos: Vector2
var shoot_tween: Tween
var satellite: Satellite

var saddle_shadow_offset = Vector2(15.0, 8.0)
var band_shadow_offset = Vector2(10.0, 5.0)
var band_handle_shadow_offset = Vector2(8.0, 3.0)

signal state_changed(new_state: SlingshotState)

func _ready() -> void:
    crosshair.modulate = aim_crosshair_color
    _change_state(SlingshotState.IDLE)

func _process(_delta: float):
    match state:
        SlingshotState.IDLE:
            pass
        SlingshotState.AIMING:
            var mouse_world_pos := get_global_mouse_position()
            var dir := global_position - mouse_world_pos
            var max_charge_dist = 300 + max(0, orbit_manager._orbits.size() - 1) * 100
            var dist: float = min(max_charge_dist, dir.length())
            pivot.rotation = dir.angle() + PI * 0.5
            saddle.position = Vector2(0, dist)
            saddle_shadow.global_position = saddle.global_position + saddle_shadow_offset
            saddle_shadow.global_rotation = saddle.global_rotation
            place_band(band_1, band_1_end, band_1_handle, band_1_handle_shadow, band_1_shadow)
            place_band(band_2, band_2_end, band_2_handle, band_2_handle_shadow, band_2_shadow)
            var max_orbit_radius: float = orbit_manager.orbit_radius_offset + max(0, orbit_manager._orbits.size() - 1) * orbit_manager.orbit_radius_distance
            var orbit := orbit_manager.get_closest_orbit(global_position + dir.normalized() * dist * (max_orbit_radius / max_charge_dist))
            if orbit != null:
                crosshair.global_position = global_position + dir.normalized() * orbit.radius
                crosshair.global_rotation = crosshair.global_position.angle() + PI * 0.5
                orbit_manager.target_orbit(orbit)
        SlingshotState.SHOOTING:
            saddle_shadow.global_position = saddle.global_position + saddle_shadow_offset
            saddle_shadow.global_rotation = saddle.global_rotation
            place_band(band_1, band_1_end, band_1_handle, band_1_handle_shadow, band_1_shadow)
            place_band(band_2, band_2_end, band_2_handle, band_2_handle_shadow, band_2_shadow)
            
    queue_redraw()

func _draw():
    if state == SlingshotState.AIMING:
        var dir := crosshair.global_position - saddle.global_position
        var dist := dir.length()
        var clamped_dist: float = max(0, dist - 30)
        draw_dashed_line(saddle.global_position, saddle.global_position + (dir / dist) * clamped_dist, aim_color, 7, 40, false, true)

func reset_slingshot():
    pivot.rotation = 0
    saddle.position = Vector2.ZERO
    saddle_shadow.position = Vector2.ZERO
    band_1.scale.y = 0
    band_2.scale.y = 0
    band_1_shadow.scale.y = 0
    band_2_shadow.scale.y = 0

func show_slingshot():
    saddle.visible = true
    saddle_shadow.visible = true
    band_1.visible = true
    band_2.visible = true
    band_1_handle.visible = true
    band_2_handle.visible = true
    band_1_handle_shadow.visible = true
    band_2_handle_shadow.visible = true
    band_1_shadow.visible = true
    band_2_shadow.visible = true
    crosshair.visible = true
    place_band(band_1, band_1_end, band_1_handle, band_1_handle_shadow, band_1_shadow)
    place_band(band_2, band_2_end, band_2_handle, band_2_handle_shadow, band_2_shadow)

func hide_slingshot():
    saddle.visible = false
    saddle_shadow.visible = false
    band_1.visible = false
    band_2.visible = false
    band_1_handle.visible = false
    band_2_handle.visible = false
    band_1_handle_shadow.visible = false
    band_2_handle_shadow.visible = false
    band_1_shadow.visible = false
    band_2_shadow.visible = false
    crosshair.visible = false
    place_band(band_1, band_1_end, band_1_handle, band_1_handle_shadow, band_1_shadow)
    place_band(band_2, band_2_end, band_2_handle, band_2_handle_shadow, band_2_shadow)

func place_band(band: Node2D, band_end: Node2D, band_handle: Node2D, band_handle_shadow: Node2D, band_shadow: Node2D):
    var dir = band_end.global_position - band.global_position
    band.global_rotation = dir.angle() - PI * 0.5
    band.scale.y = dir.length()
    band_handle.global_position = band.global_position
    band_handle_shadow.global_position = band.global_position + band_handle_shadow_offset
    band_shadow.global_position = band.global_position + band_shadow_offset
    band_shadow.global_rotation = band.global_rotation
    band_shadow.scale.y = band.scale.y

func spawn_satellite():
    satellite = satellite_prefab.instantiate() as Satellite
    saddle.add_child(satellite)
    satellite.global_position = saddle.global_position
    satellite.global_rotation = saddle.global_rotation

func start_charging():
    _change_state(SlingshotState.AIMING)

    reset_slingshot()
    show_slingshot()
    spawn_satellite()

    earth.highlight(false)

func start_shooting():
    _change_state(SlingshotState.SHOOTING)
    
    crosshair.visible = false
    
    satellite_counter.decrease_counter()

    orbit_manager.target_orbit(null)

    target_saddle_pos = saddle.position * -0.75
    var orbit := orbit_manager.get_closest_orbit(crosshair.global_position)
    
    if shoot_tween != null:
        shoot_tween.kill()
    shoot_tween = create_tween().set_ease(Tween.EASE_IN)
    shoot_tween.tween_property(saddle, "position", target_saddle_pos, 0.15)
    shoot_tween.tween_callback(func(): launch_satellite(orbit))
    shoot_tween.tween_property(saddle, "position", target_saddle_pos * -0.5, 0.15)
    shoot_tween.tween_property(saddle, "position", target_saddle_pos * 0.25, 0.15)
    shoot_tween.tween_property(saddle, "position", Vector2.ZERO, 0.15)
    shoot_tween.tween_callback(idle_slingshot)

func launch_satellite(orbit: Orbit):
    satellite.reparent(main)
    if orbit != null:
        satellite.target(crosshair.global_position, orbit)
    satellite = null

func idle_slingshot():
    _change_state(SlingshotState.IDLE)

    hide_slingshot()
    reset_slingshot()

    if earth.hovered:
        earth.highlight(true)

func _change_state(new_state: SlingshotState):
    state = new_state
    state_changed.emit(new_state)

func _input(event):
    if event is InputEventMouseButton:
        var mouse_event := event as InputEventMouseButton

        if mouse_event.button_index == MOUSE_BUTTON_LEFT:
            if mouse_event.pressed && state == SlingshotState.IDLE && earth.hovered && satellite_counter.satellite_count > 0:
                start_charging()
            elif !mouse_event.pressed && state == SlingshotState.AIMING:
                start_shooting()
