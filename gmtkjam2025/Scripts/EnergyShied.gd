class_name EnergyShield

extends Node2D

@onready var timer: Timer = $Timer
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D

var deploy_tween: Tween

var cooldown: float = 15.0;

func on_timer_timeout() -> void:
    deploy_shield()
    timer.start(cooldown)

func deploy_shield():
    collision_shape.disabled = false
    if deploy_tween != null:
        deploy_tween.kill()
    deploy_tween = create_tween().set_ease(Tween.EASE_IN_OUT)
    deploy_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.35)
    deploy_tween.tween_property(self, "scale", Vector2.ONE, 0.1)
    
func destroy_shield():
    collision_shape.disabled = true
    if deploy_tween != null:
        deploy_tween.kill()
    deploy_tween = create_tween().set_ease(Tween.EASE_IN_OUT)
    deploy_tween.tween_property(self, "scale", Vector2.ZERO, 0.1)
    timer.start(cooldown)