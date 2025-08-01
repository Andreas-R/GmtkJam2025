extends Node2D

class_name OrbitManager

@onready var _orbit_prefab: PackedScene = preload("res://Prefabs/Orbit.tscn")

@export var orbit_radius_offset: float = 200
@export var orbit_radius_distance: float = 100
@export_range(1, 20) var initial_orbits: int = 2

var _orbits: Array

func _ready() -> void:
	_orbits = get_children().filter(func(c): return c is Orbit).map(func(c): return c.get_typed_script() as Orbit)
	if _orbits.size() < initial_orbits:
		for i in range(initial_orbits):
			add_orbit()

func _process(_delta: float) -> void:
	if _orbits.size() > 0:
		var closest_orbit = get_closest_orbit(get_global_mouse_position()) # TODO: Remove test lines
		for non_targets in _orbits.filter(func(c): return c != closest_orbit):
			non_targets.untarget()
		closest_orbit.target()


func add_orbit() -> void:
	var new_orbit: Orbit = _orbit_prefab.instantiate()
	new_orbit.radius = orbit_radius_offset + orbit_radius_distance * (_orbits.size())
	new_orbit.set_collider_width(orbit_radius_distance)
	add_child(new_orbit)
	_orbits.append(new_orbit)

func get_closest_orbit(target_position: Vector2) -> Orbit:
	var orbit_index = round(max(global_position.distance_to(target_position) - orbit_radius_offset, 0) / orbit_radius_distance)
	var closest_orbit = _orbits.get(clamp(orbit_index, 0, _orbits.size() - 1))
	return closest_orbit
