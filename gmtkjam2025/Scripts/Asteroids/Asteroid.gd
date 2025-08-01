class_name Asteroid

extends Node2D

func on_area_2d_area_entered(area: Area2D) -> void:
    var area_parent = area.get_parent()

    if area_parent is Satellite:
        area_parent.damage()
