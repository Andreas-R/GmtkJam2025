class_name Earth

extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

var scale_sprite_tween: Tween
var hovered: bool = false

func on_area_2d_mouse_entered() -> void:
    hovered = true

    if scale_sprite_tween != null:
        scale_sprite_tween.kill()
    scale_sprite_tween = create_tween().set_ease(Tween.EASE_IN_OUT)
    scale_sprite_tween.tween_property(sprite, "scale", Vector2(1.15, 1.15), 0.1)
    scale_sprite_tween.tween_property(sprite, "scale", Vector2(1.1, 1.1), 0.1)

func on_area_2d_mouse_exited() -> void:
    hovered = false

    if scale_sprite_tween != null:
        scale_sprite_tween.kill()
    scale_sprite_tween = create_tween().set_ease(Tween.EASE_IN_OUT)
    scale_sprite_tween.tween_property(sprite, "scale", Vector2(0.95, 0.95), 0.1)
    scale_sprite_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
