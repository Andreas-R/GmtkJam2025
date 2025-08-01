@tool
class_name Orbit

extends Node2D

enum OrbitState {
    IDLE,
    DRAGGED,
    HOVERED,
    TARGETTED
}

@onready var _satellite_spacer_prefab: PackedScene = preload("res://Prefabs/SatelliteSpacer.tscn")
@onready var _donut_collider: DonutCollisionPolygon2D = $DonutCollider
@onready var _satellite_container: Node = $Satellites

@export_category("Circle Properties")
@export var radius: float = 200
@export_range(1, 200) var parts: int = 50
@export_range(1, 100) var segments: int = 100
@export_range(1, 100) var line_width: float = 3.0
@export_group("Rotation")
@export var clockwise_rotation: bool = true
@export_range(0, 360) var rotation_speed_deg: float = 20
@export_group("Colours")
@export var base_color: Color = Color.WHITE
@export var hover_color: Color = Color.LIGHT_GRAY
@export var drag_color: Color = Color.GRAY
@export var target_color: Color = Color.LIGHT_SALMON
@export_category("Satellite Properties")
@export var min_satellite_spacing: float = 100.0
@export var orbit_index: int = 0

var _collider_width: float = 100
var _rotation_speed_multiplier: float = 1.0

var _state: OrbitState
var _local_rotation_speed_deg: float
var _local_line_width: float
var _last_mouse_angle: float
var _color: Color = base_color

var _is_hovered: bool = false
var _hover_line_width_multiplier: float = 4.0
var _hover_width_tween: Tween
var _slingshot_state: Slingshot.SlingshotState

var _is_other_dragged: bool = false
var _orbit_drag_start_signal: Signal
var _orbit_drag_end_signal: Signal

func _ready():
    assert(_collider_width > 0)
    rotation = 0
    _state = OrbitState.IDLE
    _color = base_color
    _local_rotation_speed_deg = _get_base_rotation_speed()
    _local_line_width = line_width
    _donut_collider.radius = radius
    _donut_collider.width = _collider_width

func _draw():
    assert(parts > 0)
    var step = 360.0 / parts if parts == 1 else 360.0 / (parts * 2)
    var i = .0
    while i < 360.0:
        draw_arc(position, radius, deg_to_rad(i), deg_to_rad(i + step), max((segments + 1.0) / parts, 2), _color, _local_line_width, true)
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
                _change_state(OrbitState.HOVERED if _is_hovered else OrbitState.IDLE)
        _:
            _local_rotation_speed_deg = lerpf(_local_rotation_speed_deg, _get_base_rotation_speed(), 0.05)

    _rotate(_local_rotation_speed_deg, delta)
    queue_redraw()

func _rotate(speed_deg: float, delta: float) -> void:
    rotation += deg_to_rad(speed_deg) * delta

func _get_base_rotation_speed() -> float:
    return rotation_speed_deg * (1 if clockwise_rotation else -1) * _rotation_speed_multiplier

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            _change_state(OrbitState.DRAGGED)
            _last_mouse_angle = get_local_mouse_position().rotated(-rotation).angle()

func _change_state(new_state: OrbitState) -> void:
    if new_state == _state or _is_other_dragged:
        # Cannot change state if other orbit is dragged
        return

    var old_state = _state
    _state = new_state

    if old_state == OrbitState.HOVERED:
        _reset_hover_state()
    if old_state == OrbitState.DRAGGED:
        _orbit_drag_end_signal.emit(orbit_index)
    match new_state:
        OrbitState.IDLE:
            get_tree().create_tween().tween_property(self, "_color", base_color, 0.1)
        OrbitState.DRAGGED:
            get_tree().create_tween().tween_property(self, "_color", drag_color, 0.1)
            _orbit_drag_start_signal.emit(orbit_index)
        OrbitState.TARGETTED:
            get_tree().create_tween().tween_property(self, "_color", target_color, 0.1)
        OrbitState.HOVERED:
            if old_state == OrbitState.TARGETTED:
                # Cannot go into hovered state if targetted
                return
            get_tree().create_tween().tween_property(self, "_color", hover_color, 0.1)
            _hover_width_tween = create_tween()
            _hover_width_tween.tween_property(self, "_local_line_width", line_width * _hover_line_width_multiplier, 0.15)

func _reset_hover_state() -> void:
    if _hover_width_tween != null and _hover_width_tween.is_running():
        _hover_width_tween.kill()
    _hover_width_tween = create_tween()
    _hover_width_tween.tween_property(self, "_local_line_width", line_width, 0.1)

func _get_configuration_warnings() -> PackedStringArray:
    if not get_children().any(func(c): return is_instance_of(c, DonutCollisionPolygon2D)):
        return ["Please Attach a DonutCollisionPolygon2D called DonutCollider"]
    return []

func set_collider_width(collider_width: float) -> void:
    _collider_width = collider_width

func target() -> void:
    if _state == OrbitState.TARGETTED:
        return

    if _state != OrbitState.DRAGGED:
        _change_state(OrbitState.TARGETTED)

func untarget() -> void:
    if _state != OrbitState.TARGETTED:
        return

    if _state != OrbitState.DRAGGED:
        _change_state(OrbitState.IDLE)

func set_min_satellite_spacing(spacing: float) -> void:
    min_satellite_spacing = spacing

func attach_satellite(attached_satellite: Satellite) -> void:
    var satellite_spacer: SatelliteSpacer = _satellite_spacer_prefab.instantiate()
    satellite_spacer.set_spacing(min_satellite_spacing)
    attached_satellite.add_child(satellite_spacer)
    attached_satellite.reparent(_satellite_container)
    satellite_spacer.set_orbit_index(orbit_index)

func on_slingshot_state_changed(slingshot_state: Slingshot.SlingshotState):
    _slingshot_state = slingshot_state
    if slingshot_state != Slingshot.SlingshotState.AIMING and _is_hovered:
        _change_state(OrbitState.HOVERED)

func set_orbit_drag_signals(start: Signal, end: Signal) -> void:
    _orbit_drag_start_signal = start
    _orbit_drag_end_signal = end

func on_orbit_drag_start(index: int) -> void:
    _is_other_dragged = index != orbit_index

func on_orbit_drag_end(index: int) -> void:
    _is_other_dragged = false
    if _is_hovered:
        _change_state(OrbitState.HOVERED)

func _on_mouse_entered() -> void:
    _is_hovered = true
    if _slingshot_state != Slingshot.SlingshotState.AIMING and _state != OrbitState.DRAGGED:
        _change_state(OrbitState.HOVERED)

func _on_mouse_exited() -> void:
    _is_hovered = false
    if _state == OrbitState.HOVERED:
        _change_state(OrbitState.IDLE)
