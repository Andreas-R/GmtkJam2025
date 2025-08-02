class_name TutorialController

extends Node2D

@onready var slingshot: Slingshot = $/root/Main/Earth/Slingshot
@onready var hand: Node2D = $Hand
@onready var hand_sprite: Node2D = $Hand/Sprite2D
@onready var hand_shadow: Node2D = $Hand/Shadow

var hand_shadow_offset = Vector2(15.0, 8.0)

var tutorial_tween: Tween

func _process(_delta: float) -> void:
    hand_shadow.global_position = hand_sprite.global_position + hand_shadow_offset
    hand_shadow.global_rotation = hand_sprite.global_rotation

    if !slingshot.made_initial_shot:
        play_slingshot_tutorial()
    else:
        if tutorial_tween != null && tutorial_tween.is_running():
            cancel_slingshot_tutorial()

func play_slingshot_tutorial():
    if tutorial_tween != null && tutorial_tween.is_running():
        return

    if tutorial_tween != null:
        tutorial_tween.kill()
    tutorial_tween = create_tween()
    tutorial_tween.tween_callback(func():
        hand.global_position = Vector2(250.0, -80.0)
        hand.global_rotation_degrees = -45.0
        hand.scale = Vector2.ZERO
        hand.visible = true
    ).set_delay(0.5).set_delay(2.0)
    tutorial_tween.tween_property(hand, "scale", Vector2.ONE, 0.25)
    tutorial_tween.tween_property(hand, "global_position", Vector2(80.0, -80.0), 0.5).set_delay(0.5)
    tutorial_tween.tween_property(hand, "global_rotation_degrees", -135.0, 0.5)
    tutorial_tween.tween_property(hand, "global_position", Vector2(80.0, -50.0), 0.5).set_delay(0.25)
    tutorial_tween.tween_property(hand, "global_position", Vector2(350.0, 50.0), 1.0).set_delay(0.25)
    tutorial_tween.tween_property(hand, "global_position", Vector2(350.0, 20.0), 0.15).set_delay(0.5)
    tutorial_tween.tween_property(hand, "global_rotation_degrees", -45.0, 0.5).set_delay(0.5)
    tutorial_tween.tween_property(hand, "scale", Vector2.ZERO, 0.25)
    tutorial_tween.tween_callback(func():
        hand.visible = false
    ).set_delay(0.5)

func cancel_slingshot_tutorial():
    tutorial_tween.kill()
    tutorial_tween = null
    hand.visible = false

func play_orbit_tutorial():
    pass

func cancel_orbit_tutorial():
    pass
