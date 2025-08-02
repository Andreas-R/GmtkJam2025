class_name GameManager

extends Node2D

static var ORBIT_THRESHOLDS = [3, 8, 15, 25];
static var ASTEROID_SPAWN_TIMES = [10.0, 9.0, 8.0, 7.0];

@onready var camera_controller: CameraController = $/root/Main/CameraController
@onready var orbit_manager: OrbitManager = $/root/Main/OrbitManager
@onready var asteroid_spawner: AsteroidSpawner = $/root/Main/AsteroidSpawner

func _ready() -> void:
    call_deferred("start_game")

func start_game() -> void:
    orbit_manager.init_orbits()
    camera_controller.tween_zoom()
    asteroid_spawner.spawn_time = ASTEROID_SPAWN_TIMES[0]
    asteroid_spawner.init_spawner()

func check_for_next_orbit():
    var orbit_count := orbit_manager._orbits.size()

    if orbit_count > ORBIT_THRESHOLDS.size():
        return

    var satellite_count := orbit_manager.count_satellites()

    if satellite_count >= ORBIT_THRESHOLDS[orbit_count - 1]:
        orbit_manager.add_orbit()
        camera_controller.tween_zoom()
        asteroid_spawner.spawn_time = ASTEROID_SPAWN_TIMES[orbit_count - 1]
