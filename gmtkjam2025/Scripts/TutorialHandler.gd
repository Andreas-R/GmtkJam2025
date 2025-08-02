class_name TutorialController

extends Node2D

static var made_initial_shot: bool = false
static var made_initial_orbit_drag: bool = false

@onready var hand: Node2D = $Hand
@onready var hand_sprite: Node2D = $Hand/Sprite2D
@onready var hand_shadow: Node2D = $Hand/Shadow

var hand_shadow_offset = Vector2(15.0, 8.0)

var slingshot_tutorial_tween: Tween
var orbit_tutorial_tween: Tween

func _process(_delta: float) -> void:
    hand_shadow.global_position = hand_sprite.global_position + hand_shadow_offset
    hand_shadow.global_rotation = hand_sprite.global_rotation

    if !made_initial_shot:
        play_slingshot_tutorial()
    elif slingshot_tutorial_tween != null && slingshot_tutorial_tween.is_running():
        cancel_slingshot_tutorial()

    if made_initial_shot:
        if !made_initial_orbit_drag:
            play_orbit_tutorial()
        elif orbit_tutorial_tween != null && orbit_tutorial_tween.is_running():
            cancel_orbit_tutorial()

func play_slingshot_tutorial():
    if slingshot_tutorial_tween != null && slingshot_tutorial_tween.is_running():
        return
    if slingshot_tutorial_tween != null:
        slingshot_tutorial_tween.kill()
    slingshot_tutorial_tween = create_tween()
    slingshot_tutorial_tween.tween_callback(func():
        hand.global_position = Vector2(250.0, -80.0)
        hand.global_rotation_degrees = -45.0
        hand.scale = Vector2.ZERO
        hand.visible = true
    ).set_delay(0.5).set_delay(3.0)
    slingshot_tutorial_tween.tween_property(hand, "scale", Vector2.ONE, 0.25)
    slingshot_tutorial_tween.tween_property(hand, "global_position", Vector2(80.0, -80.0), 0.5).set_delay(0.5)
    slingshot_tutorial_tween.tween_property(hand, "global_rotation_degrees", -135.0, 0.5).set_delay(0.25)
    slingshot_tutorial_tween.tween_property(hand, "global_position", Vector2(80.0, -50.0), 0.5).set_delay(0.25)
    slingshot_tutorial_tween.tween_property(hand, "global_position", Vector2(350.0, 50.0), 0.75).set_delay(0.25)
    slingshot_tutorial_tween.tween_property(hand, "global_position", Vector2(350.0, 20.0), 0.15).set_delay(0.25)
    slingshot_tutorial_tween.tween_property(hand, "global_rotation_degrees", -45.0, 0.5).set_delay(0.25)
    slingshot_tutorial_tween.tween_property(hand, "scale", Vector2.ZERO, 0.25).set_delay(0.25)
    slingshot_tutorial_tween.tween_callback(func():
        hand.visible = false
    ).set_delay(0.5)

func cancel_slingshot_tutorial():
    slingshot_tutorial_tween.kill()
    slingshot_tutorial_tween = null
    hand.visible = false

func play_orbit_tutorial():
    if orbit_tutorial_tween != null && orbit_tutorial_tween.is_running():
        return
    if orbit_tutorial_tween != null:
        orbit_tutorial_tween.kill()
    orbit_tutorial_tween = create_tween()
    orbit_tutorial_tween.tween_callback(func():
        hand.global_position = Vector2(480.0, -540.0)
        hand.global_rotation_degrees = -45.0
        hand.scale = Vector2.ZERO
        hand.visible = true
    ).set_delay(0.5).set_delay(3.0)
    orbit_tutorial_tween.tween_property(hand, "scale", Vector2.ONE, 0.25)
    orbit_tutorial_tween.tween_property(hand, "global_rotation_degrees", -135.0, 0.5).set_delay(0.5)
    orbit_tutorial_tween.tween_property(hand, "global_position", Vector2(480.0, -510.0), 0.5).set_delay(0.25)
    orbit_tutorial_tween.tween_method(
        func(progress: float) -> void:
            var t = progress
            # Linear interpolation of X
            var x = 480.0 + 180 * 4 * t * (1 - t)
            var y = lerp(-510.0, 350.0, t)
            hand.global_position = Vector2(x, y),
        0.0, 1.0, 1.75
    ).set_delay(0.25)
    orbit_tutorial_tween.tween_property(hand, "global_position", Vector2(480.0, 320.0), 0.15).set_delay(0.25)
    orbit_tutorial_tween.tween_property(hand, "global_rotation_degrees", -45.0, 0.5).set_delay(0.25)
    orbit_tutorial_tween.tween_property(hand, "scale", Vector2.ZERO, 0.25).set_delay(0.25)
    orbit_tutorial_tween.tween_callback(func():
        hand.visible = false
    ).set_delay(0.5)

func cancel_orbit_tutorial():
    orbit_tutorial_tween.kill()
    orbit_tutorial_tween = null
    hand.visible = false
