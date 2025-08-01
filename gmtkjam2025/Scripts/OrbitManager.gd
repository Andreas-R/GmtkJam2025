class_name OrbitManager

extends Node2D

@onready var _orbit_prefab: PackedScene = preload("res://Prefabs/Orbit.tscn")
@onready var _slingshot: Slingshot = $/root/Main/Earth/Slingshot

@export var orbit_radius_offset: float = 200
@export var orbit_radius_distance: float = 100
@export_range(1, 20) var initial_orbits: int = 2
@export var min_satellite_spacing: float = 100.0

var _orbits: Array

signal orbit_drag_start(orbit_index: int)
signal orbit_drag_end(orbit_index: int)

func _ready() -> void:
    _orbits = get_children().filter(func(c): return c is Orbit)
    if _orbits.size() < initial_orbits:
        for i in range(initial_orbits):
            add_orbit()

func _process(_delta: float) -> void:
    pass

func add_orbit() -> void:
    var new_orbit: Orbit = _orbit_prefab.instantiate()
    new_orbit.radius = orbit_radius_offset + orbit_radius_distance * (_orbits.size())
    new_orbit.parts = round(new_orbit.radius / 7)
    new_orbit.clockwise_rotation = (_orbits.size() % 2) == 0
    new_orbit.rotation_speed_deg = max(16 - _orbits.size() * 2, 1)
    new_orbit.set_collider_width(orbit_radius_distance)
    new_orbit.set_min_satellite_spacing(min_satellite_spacing)
    new_orbit.orbit_index = _orbits.size()
    _slingshot.state_changed.connect(new_orbit.on_slingshot_state_changed)
    new_orbit.set_orbit_drag_signals(orbit_drag_start, orbit_drag_end)
    orbit_drag_start.connect(new_orbit.on_orbit_drag_start)
    orbit_drag_end.connect(new_orbit.on_orbit_drag_end)
    add_child(new_orbit)
    _orbits.append(new_orbit)

func get_closest_orbit(target_position: Vector2) -> Orbit:
    var orbit_index = round(max(global_position.distance_to(target_position) - orbit_radius_offset, 0) / orbit_radius_distance)
    var closest_orbit = _orbits.get(clamp(orbit_index, 0, _orbits.size() - 1))
    return closest_orbit

func target_orbit(target: Orbit) -> void:
    for orbit: Orbit in _orbits:
        if orbit == target:
            orbit.target()
        else:
            orbit.untarget()

func get_orbit(orbit_index: int) -> Orbit:
    if orbit_index >= _orbits.size():
        return null
    return _orbits.get(orbit_index)
