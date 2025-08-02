@tool
class_name OrbitOutline

extends Node2D

@export_category("Circle Properties")
@export var radius: float = 200
@export_range(1, 200) var parts: int = 50
@export_range(1, 100) var segments: int = 100
@export_range(1, 100) var line_width: float = 3.0
@export var line_width_multiplier: float = 1.0
@export_group("Rotation")
@export var clockwise_rotation: bool = true
@export_range(0, 360) var rotation_speed_deg: float = 20
@export_group("Colours")
@export var base_color: Color = Color.WHITE
@export var hover_color: Color = Color.LIGHT_GRAY
@export var drag_color: Color = Color.GRAY
@export var target_color: Color = Color.LIGHT_SALMON

var _rotation_speed_multiplier: float = 1.0
var _local_rotation_speed_deg: float
var _local_line_width: float

var _color: Color = base_color

func _ready() -> void:
    _local_line_width = line_width
    _color = base_color
    _local_rotation_speed_deg = _get_base_rotation_speed()

func _draw():
    assert(parts > 0)
    var step = 360.0 / parts if parts == 1 else 360.0 / (parts * 2)
    var i = .0
    while i < 360.0:
        draw_arc(position, radius, deg_to_rad(i), deg_to_rad(i + step), max((segments + 1.0) / parts, 2), _color, _local_line_width, true)
        i = i + step * 2

func _process(_delta: float) -> void:
    queue_redraw()

func _rotate(speed_deg: float, delta: float) -> void:
    rotation += deg_to_rad(speed_deg) * delta

func _get_base_rotation_speed() -> float:
    return rotation_speed_deg * (1 if clockwise_rotation else -1) * _rotation_speed_multiplier

func stop_rotation() -> void:
    _rotation_speed_multiplier = 0.0

func slow_rotation() -> void:
    _rotation_speed_multiplier = 0.2

func start_rotation() -> void:
    _rotation_speed_multiplier = 1.0

func set_line_width(_line_width: float) -> void:
    _local_line_width = _line_width