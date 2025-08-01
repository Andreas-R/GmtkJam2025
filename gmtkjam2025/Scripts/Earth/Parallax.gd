class_name Parallax

extends Node2D

@export var scroll_speed: float = 100.0
@export var parallax_width: int = 512

func _process(delta):
    for node: Node2D in get_children():
        node.position.x += scroll_speed * delta

        if scroll_speed > 0:
            if node.position.x >= parallax_width:
                node.position.x -= parallax_width
        else:
            if node.position.x <= parallax_width:
                node.position.x += parallax_width
