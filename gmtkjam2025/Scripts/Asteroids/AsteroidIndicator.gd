class_name AsteroidIndicator

extends Node2D

static var asteroid_prefab: PackedScene = load("res://Prefabs/Asteroids/Asteroid.tscn") as PackedScene

@onready var indicator: Sprite2D = $Indicator
@onready var asteroid: Asteroid = $Asteroid

var spawn_tween: Tween

func spawn():
    indicator.scale.y = 0
    indicator.visible = true
    indicator.modulate = Color(1.0, 0.5, 0.0, 1.0)
    
    spawn_tween = create_tween().set_ease(Tween.EASE_IN)
    spawn_tween.set_parallel(true)
    spawn_tween.tween_property(indicator, "scale", Vector2(indicator.scale.x, 60), 4.0)
    spawn_tween.tween_property(indicator, "modulate", Color(1.0, 0.0, 0.0, 1.0), 0.5).set_delay(4.0)
    spawn_tween.tween_property(indicator, "scale", Vector2(indicator.scale.x, 5), 0.75).set_delay(4.75)
    spawn_tween.tween_property(asteroid, "position", Vector2(-asteroid.position.x, asteroid.position.y), 6.0).set_delay(4.0)
    spawn_tween.tween_property(indicator, "scale", Vector2(indicator.scale.x, 0), 0.5).set_delay(9.0)
    spawn_tween.tween_callback(cleanup).set_delay(10.0)

func cleanup():
    queue_free()
