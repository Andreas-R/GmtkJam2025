class_name CameraController

extends Camera2D

var zoom_tween: Tween

@onready var orbit_manager: OrbitManager = $/root/Main/OrbitManager

func tween_zoom(before_orbit_add = false, callback: Callable = func():):
    var max_radius: float = orbit_manager.orbit_radius_offset + max(0, orbit_manager._orbits.size() - (0 if before_orbit_add else 1)) * orbit_manager.orbit_radius_distance
    var zoom_factor := orbit_manager.orbit_radius_offset / max_radius

    if zoom_factor == zoom.x:
        return

    if zoom_tween != null:
        zoom_tween.kill()
    zoom_tween = create_tween().set_ease(Tween.EASE_IN_OUT)
    zoom_tween.tween_property(self, "zoom", Vector2(zoom_factor, zoom_factor), 1.0)
    if callback != null:
        zoom_tween.tween_callback(callback)
