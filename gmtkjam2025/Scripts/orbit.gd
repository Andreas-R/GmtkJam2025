@tool
extends Node2D
class_name Orbit

enum OrbitState {
	IDLE,
	DRAGGED,
	TARGETTED
}

@onready var _donut_collider: DonutCollisionPolygon2D = $DonutCollider

@export var radius: float = 200
@export_range(1, 200) var parts: int = 30
@export_range(1, 100) var segments: int = 100
@export_range(1, 100) var line_width: float = 3.0
@export var clockwise_rotation: bool = true
@export_range(0, 360) var rotation_speed_deg: int = 10
@export var base_color: Color = Color.WHITE
@export var hover_color: Color = Color.LIGHT_GRAY # TODO: Not yet in use
@export var drag_color: Color = Color.GRAY
@export var target_color: Color = Color.LIGHT_SALMON

var _collider_width

var _state: OrbitState
var _local_rotation_speed_deg: float
var _last_mouse_angle: float
var _color: Color = base_color

func _ready():
	assert(_collider_width > 0)
	rotation = 0
	_state = OrbitState.IDLE
	_color = base_color
	_local_rotation_speed_deg = _get_base_rotation_speed()
	_donut_collider.radius = radius
	_donut_collider.width = _collider_width

func _draw():
	assert(parts > 0)
	var step = 360.0 / parts if parts == 1 else 360.0 / (parts * 2)
	var i = .0
	while i < 360.0:
		draw_arc(position, radius, deg_to_rad(i), deg_to_rad(i + step), max((segments + 1.0) / parts, 2), _color, line_width, true)
		i = i + step * 2

func _process(delta: float) -> void:
	match _state:
		OrbitState.DRAGGED:
			var current_angle = get_local_mouse_position().rotated(-rotation).angle()
			var delta_angle = wrapf(current_angle - _last_mouse_angle, -PI, PI)
			var mouse_angular_speed = delta_angle / delta
			_local_rotation_speed_deg += mouse_angular_speed * 1.3
			_last_mouse_angle = current_angle
			if Input.is_action_just_released("left_mouse_click"):
				_change_state(OrbitState.IDLE)
		OrbitState.TARGETTED, OrbitState.IDLE:
			_local_rotation_speed_deg = lerpf(_local_rotation_speed_deg, _get_base_rotation_speed(), 0.05)

	_rotate(_local_rotation_speed_deg, delta)
	queue_redraw()

func _rotate(speed_deg: float, delta: float) -> void:
	rotation += deg_to_rad(speed_deg) * delta

func _get_base_rotation_speed() -> float:
	return rotation_speed_deg * (1 if clockwise_rotation else -1)

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_change_state(OrbitState.DRAGGED)
			_last_mouse_angle = get_local_mouse_position().rotated(-rotation).angle()

func _change_state(state: OrbitState) -> void:
	match state:
		OrbitState.IDLE:
			get_tree().create_tween().tween_property(self, "_color", base_color, 0.1)
		OrbitState.DRAGGED:
			get_tree().create_tween().tween_property(self, "_color", drag_color, 0.1)
		OrbitState.TARGETTED:
			get_tree().create_tween().tween_property(self, "_color", target_color, 0.1)
	_state = state

func _get_configuration_warnings() -> PackedStringArray:
	if not get_children().any(func(c): return is_instance_of(c, DonutCollisionPolygon2D)):
		return ["Please Attach a DonutCollisionPolygon2D called DonutCollider"]
	return []

func set_collider_width(collider_width: float) -> void:
	_collider_width = collider_width

func target() -> void:
	if _state != OrbitState.DRAGGED:
		_change_state(OrbitState.TARGETTED)

func untarget() -> void:
	if _state != OrbitState.DRAGGED:
		_change_state(OrbitState.IDLE)
