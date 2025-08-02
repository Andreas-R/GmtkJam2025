extends Node2D

class_name SatelliteTargets

func _rotate(speed_deg: float, delta: float) -> void:
    rotation += deg_to_rad(speed_deg) * delta
