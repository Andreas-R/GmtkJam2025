class_name CameraController

extends Camera2D

var zoom_tween: Tween

@onready var orbit_manager: OrbitManager = $/root/Main/OrbitManager

func tween_zoom():
    var zoom_factor := calc_zoom_factor(orbit_manager._orbits.size())

    if zoom_factor == zoom.x:
        return

    if zoom_tween != null:
        zoom_tween.kill()
    zoom_tween = create_tween().set_ease(Tween.EASE_IN_OUT)
    zoom_tween.tween_property(self, "zoom", Vector2(zoom_factor, zoom_factor), 1.0)

func calc_zoom_factor(number_of_orbits: int) -> float:
    var max_radius: float = orbit_manager.orbit_radius_offset + max(0, number_of_orbits - 1) * orbit_manager.orbit_radius_distance
    return orbit_manager.orbit_radius_offset / max_radius

func calc_zoom_scale(number_of_orbits: int) -> float:
    return 1.0 / calc_zoom_factor(number_of_orbits)
