class_name GameManager

extends Node2D

static var ORBIT_THRESHOLDS = [0, 5, 11, 18, 26, 35, 45];
static var ASTEROID_SPAWN_TIMES = [15.0, 14.0, 13.0, 12.0, 11.0, 10.0, 9.0];

@onready var game_ui_manager: GameUiManager = $/root/Main/UI/GameUI
@onready var slingshot: Slingshot = $/root/Main/Earth/Slingshot
@onready var satellite_counter: SatelliteCounter = $/root/Main/Earth/SatelliteCounter
@onready var demand_manager: DemandManager = $/root/Main/DemandManager
@onready var camera_controller: CameraController = $/root/Main/CameraController
@onready var upgrade_ui_manager: UpgradeUiManager = $/root/Main/UI/UpgradeUI
@onready var orbit_manager: OrbitManager = $/root/Main/OrbitManager
@onready var asteroid_spawner: AsteroidSpawner = $/root/Main/AsteroidSpawner

var started_game = false

signal upgrade_selection_started()

func _ready() -> void:
    call_deferred("setup_game")

func _process(_delta: float) -> void:
    if !started_game && slingshot.made_initial_shot:
        start_game()

func setup_game() -> void:
    game_ui_manager.blend_in()
    game_ui_manager.update_next_orbit(ORBIT_THRESHOLDS[1])
    orbit_manager.init_orbits()
    camera_controller.zoom_camera(true)

func start_game() -> void:
    started_game = true

    asteroid_spawner.spawn_time = ASTEROID_SPAWN_TIMES[0]
    asteroid_spawner.start()
    satellite_counter.start()
    demand_manager.start()

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

        await get_tree().create_timer(1.5).timeout

        upgrade_selection_started.emit()
        upgrade_ui_manager.show_menu()
