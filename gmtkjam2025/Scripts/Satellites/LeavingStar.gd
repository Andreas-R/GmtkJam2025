class_name LeavingStar

extends Node2D

func play():
    visible = true
    var scale_tween: Tween = create_tween()
    scale_tween.tween_property(self, "scale", Vector2.ONE * 1.7, 0.1).set_ease(Tween.EASE_IN)
    scale_tween.tween_property(self, "scale", Vector2.ZERO, 3).set_ease(Tween.EASE_OUT).set_delay(0.7)

    var tween: Tween = create_tween()
    tween.tween_property(self, "modulate", Color.WHITE, 0.8).set_ease(Tween.EASE_IN)
    tween.tween_property(self, "modulate", Color.TRANSPARENT, 2).set_ease(Tween.EASE_OUT)
    tween.parallel().tween_subtween(scale_tween)
    tween.tween_callback(queue_free)
