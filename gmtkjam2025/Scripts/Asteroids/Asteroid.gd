class_name Asteroid

extends Node2D

@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D

var no_collision = false

func _process(delta):
    rotate(2 * PI * delta)

func on_area_2d_area_entered(area: Area2D) -> void:
    if no_collision:
        return

    var area_parent = area.get_parent()

    if area_parent is Satellite:
        area_parent.damage()
    elif area_parent is EnergyShield:
        visible = false
        no_collision = true
        area_parent.destroy_shield()
