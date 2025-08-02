class_name GameManager

extends Node2D

static var ORBIT_THRESHOLDS = [0, 3, 7, 12, 18, 25, 32];
static var ASTEROID_SPAWN_TIMES = [10.0, 9.5, 9.0, 8.5, 8.0, 7.5, 7.0];

@onready var game_ui_manager: GameUiManager = $/root/Main/UI/GameUI
@onready var camera_controller: CameraController = $/root/Main/CameraController
@onready var orbit_manager: OrbitManager = $/root/Main/OrbitManager
@onready var asteroid_spawner: AsteroidSpawner = $/root/Main/AsteroidSpawner

func _ready() -> void:
    call_deferred("start_game")

func start_game() -> void:
    game_ui_manager.blend_in()
    game_ui_manager.update_next_orbit(ORBIT_THRESHOLDS[1])
    orbit_manager.init_orbits()
    camera_controller.zoom_camera(true)
    asteroid_spawner.spawn_time = ASTEROID_SPAWN_TIMES[0]
    asteroid_spawner.init_spawner()

func check_for_next_orbit():
    var orbit_count := orbit_manager._orbits.size()

    if orbit_count >= ORBIT_THRESHOLDS.size():
        return

    var satellite_count := orbit_manager.count_satellites()

    if satellite_count >= ORBIT_THRESHOLDS[orbit_count]:
        orbit_manager.add_orbit()
        camera_controller.zoom_camera()
        asteroid_spawner.spawn_time = ASTEROID_SPAWN_TIMES[orbit_count]
        if orbit_count < ORBIT_THRESHOLDS.size() - 1:
            game_ui_manager.update_next_orbit(ORBIT_THRESHOLDS[orbit_count + 1])
        else:
            game_ui_manager.hide_next_orbit()
