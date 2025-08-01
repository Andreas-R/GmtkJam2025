class_name AsteroidSpawner

extends Node2D

static var asteroid_indicator_prefab: PackedScene = load("res://Prefabs/Asteroids/AsteroidIndicator.tscn") as PackedScene

@onready var orbitManager: OrbitManager = $/root/Main/OrbitManager
@onready var timer: Timer = $Timer

var spawn_time: float = 5.0;
var last_angle: float = 0;

func init_spawner() -> void:
    last_angle = randf_range(0, 2 * PI)
    start_timer(spawn_time)

func start_timer(wait_time: float):
    timer.start(wait_time)

func on_timer_timeout() -> void:
    spawn_asteroid_indicator()
    start_timer(spawn_time)

func spawn_asteroid_indicator():
    var number_of_orbits := orbitManager._orbits.size();

    var min_dist := orbitManager.orbit_radius_offset - orbitManager.orbit_radius_offset * 0.25
    var max_dist: float = 0

    if number_of_orbits <= 1:
        max_dist = min_dist
    else:
        max_dist = orbitManager.orbit_radius_offset + (floori(number_of_orbits * 0.5) - 0.5) * orbitManager.orbit_radius_distance

    var rand_dist = randf_range(min_dist, max_dist)
    var rand_angle = last_angle + randf_range(PI * 0.25, PI * 1.75)
    last_angle = rand_angle
    
    var asteroid_indicator := asteroid_indicator_prefab.instantiate() as AsteroidIndicator
    self.add_child(asteroid_indicator)
    asteroid_indicator.global_position = Vector2(0, rand_dist).rotated(rand_angle)
    asteroid_indicator.global_rotation = rand_angle

    asteroid_indicator.spawn()
