@tool
extends Node2D

@export var radius: float = 200
@export_range(1, 200) var parts: int = 30
@export_range(1, 100) var segments: int = 100
@export_range(1, 100) var line_width: float = 3.0
@export var clockwise_rotation: bool = true 
@export_range(0, 360) var rotation_speed_deg: int = 10

func _ready():
    rotation = 0;

func _draw():
    assert(parts > 0)
    var step = 360.0 / parts if parts == 1 else 360.0 / (parts * 2)
    var i = 0.0
    while i < 360.0:
        draw_arc(position, radius, deg_to_rad(i), deg_to_rad(i + step), max((segments + 1) / parts, 2), Color.WHITE, line_width, true)
        i = i + step * 2

func _process(delta: float) -> void:
    if (rotation_speed_deg % 360) != 0:
        if clockwise_rotation:
            rotation += deg_to_rad(rotation_speed_deg) * delta
        else:
            rotation -= deg_to_rad(rotation_speed_deg) * delta
    queue_redraw()
