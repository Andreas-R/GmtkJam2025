class_name Slingshot

extends Node2D

enum SlingshotState {
    IDLE,
    AIMING,
    SHOOTING,
}

static var satellite_prefab: PackedScene = load("res://Prefabs/Satellite.tscn") as PackedScene

@export var max_charge_dist = 300

@onready var main: Node2D = $/root/Main
@onready var orbitManager: OrbitManager = $/root/Main/OrbitManager
@onready var earth: Earth = get_parent()
@onready var pivot: Node2D = $Pivot
@onready var saddle: Node2D = $Pivot/Saddle
@onready var band_1: Node2D = $Pivot/Band1
@onready var band_2: Node2D = $Pivot/Band2
@onready var band_1_end: Node2D = $Pivot/Saddle/Band1End
@onready var band_2_end: Node2D = $Pivot/Saddle/Band2End
@onready var crosshair: Node2D = $Crosshair
@onready var satelliteCounter: SatelliteCounter = get_parent().find_child("SatelliteCounter")

var state: SlingshotState = SlingshotState.IDLE

var target_saddle_pos: Vector2
var shoot_tween: Tween
var satellite: Satellite

func _process(_delta: float):
    match state:
        SlingshotState.IDLE:
            pass
        SlingshotState.AIMING:
            var mouse_world_pos = get_global_mouse_position()
            var dir = global_position - mouse_world_pos
            var dist = min(max_charge_dist, dir.length())
            pivot.rotation = dir.angle() + PI * 0.5
            saddle.position = Vector2(0, dist)
            place_band(band_1, band_1_end)
            place_band(band_2, band_2_end)
            var orbit := orbitManager.get_closest_orbit(global_position + dir.normalized() * dist * 5)
            crosshair.global_position = global_position + dir.normalized() * orbit.radius
            orbitManager.target_orbit(orbit)
        SlingshotState.SHOOTING:
            place_band(band_1, band_1_end)
            place_band(band_2, band_2_end)
            
    queue_redraw()

func _draw():
    if state == SlingshotState.AIMING:
        draw_dashed_line(saddle.global_position, crosshair.global_position, Color.RED, 10, 30, false, true)

func reset_slingshot():
    pivot.rotation = 0
    saddle.position = Vector2.ZERO
    band_1.scale.y = 0
    band_2.scale.y = 0

func show_slingshot():
    saddle.visible = true
    band_1.visible = true
    band_2.visible = true
    crosshair.visible = true
    place_band(band_1, band_1_end)
    place_band(band_2, band_2_end)

func hide_slingshot():
    saddle.visible = false
    band_1.visible = false
    band_2.visible = false
    crosshair.visible = false
    place_band(band_1, band_1_end)
    place_band(band_2, band_2_end)

func place_band(band: Node2D, bandEnd: Node2D):
    var dir = bandEnd.global_position - band.global_position
    band.global_rotation = dir.angle() - PI * 0.5
    band.scale.y = dir.length()

func spawn_satellite():
    satellite = satellite_prefab.instantiate() as Satellite
    saddle.add_child(satellite)
    satellite.global_position = saddle.global_position
    satellite.global_rotation = saddle.global_rotation

func start_charging():
    state = SlingshotState.AIMING

    reset_slingshot()
    show_slingshot()
    spawn_satellite()

    earth.highlight(false)

func start_shooting():
    state = SlingshotState.SHOOTING
    
    crosshair.visible = false
    
    satelliteCounter.decrease_counter()

    orbitManager.target_orbit(null)

    target_saddle_pos = saddle.position * -0.75
    var orbit := orbitManager.get_closest_orbit(crosshair.global_position)
    
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
    satellite.target(crosshair.global_position, orbit)
    satellite = null

func idle_slingshot():
    state = SlingshotState.IDLE

    hide_slingshot()
    reset_slingshot()

    if earth.hovered:
        earth.highlight(true)

func _input(event):
    if event is InputEventMouseButton:
        var mouse_event := event as InputEventMouseButton

        if mouse_event.button_index == MOUSE_BUTTON_LEFT:
            if mouse_event.pressed && state == SlingshotState.IDLE && earth.hovered && satelliteCounter.satelliteCount > 0:
                start_charging()
            elif !mouse_event.pressed && state == SlingshotState.AIMING:
                start_shooting()
