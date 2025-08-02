class_name Orbit

extends Node2D

enum OrbitState {
    IDLE,
    DRAGGED,
    HOVERED,
    TARGETTED
}

static var _satellite_spacer_prefab: PackedScene = preload("res://Prefabs/Satellites/SatelliteSpacer.tscn")

@export_range(0, 360) var rotation_speed_deg: float = 20
@export_category("Satellite Properties")
@export var min_satellite_spacing: float = 100.0
@export var orbit_index: int = 0
@export var _orbit_outline: OrbitOutline 
@export var _satellite_targets: SatelliteTargets

@onready var main: Node2D = $/root/Main
@onready var game_manager: GameManager = $/root/Main/GameManager
@onready var _donut_collider: DonutCollisionPolygon2D = $DonutCollider
@onready var _satellite_container: Node = $Satellites
@onready var _limit_label: Node2D = $LimitLabel
@onready var _limit_label_value: Label = $LimitLabel/Value

var radius: float = 200
var satellite_approach_speed: float = 20

var _max_satellites = 0

var _collider_width: float = 100

var _state: OrbitState
var _last_mouse_angle: float
var _local_rotation_speed_deg: float
var _base_rotation_direction: int

var _is_hovered: bool = false
var _hover_line_width_multiplier: float = 3.0
var _hover_width_tween: Tween
var _slingshot_state: Slingshot.SlingshotState

var _is_other_dragged: bool = false
var _orbit_drag_start_signal: Signal
var _orbit_drag_end_signal: Signal

var _next_orbit: Orbit = null

func _ready():
    modulate = Color.TRANSPARENT
    assert(_collider_width > 0)
    rotation = 0
    _state = OrbitState.IDLE
    _donut_collider.radius = radius
    _donut_collider.width = _collider_width
    _base_rotation_direction = 1 if _orbit_outline.clockwise_rotation else -1
    _local_rotation_speed_deg = _get_base_rotation_speed(_base_rotation_direction)
    _max_satellites = floori((2 * radius * PI) / (min_satellite_spacing * 3))
    _orbit_outline._color = _orbit_outline.base_color
    _limit_label.position = Vector2(0, radius - 70)
    _limit_label_value.modulate = _orbit_outline.base_color

func blend_in():
    var blend_in_tween = get_tree().create_tween()
    blend_in_tween.tween_property(self, "modulate", Color.TRANSPARENT, 1.0)
    blend_in_tween.tween_property(self, "modulate", Color.WHITE, 1.0)

func _process(delta: float) -> void:
    _limit_label_value.text = str(count_satellites(), "/", _max_satellites)

    match _state:
        OrbitState.DRAGGED:
            var current_angle = get_local_mouse_position().rotated(-_satellite_container.rotation).angle()
            var delta_angle = wrapf(current_angle - _last_mouse_angle, -PI, PI)
            var mouse_angular_speed = delta_angle / delta
            _local_rotation_speed_deg += mouse_angular_speed * 1.3
            _last_mouse_angle = current_angle
            if Input.is_action_just_released("left_mouse_click"):
                _change_state(OrbitState.HOVERED if _is_hovered else OrbitState.IDLE)
        _:
            _local_rotation_speed_deg = lerpf(_local_rotation_speed_deg, _get_base_rotation_speed(_base_rotation_direction), 0.05)
    _satellite_container.rotation += deg_to_rad(_local_rotation_speed_deg) * delta
    _satellite_targets._rotate(satellite_approach_speed * sign(_local_rotation_speed_deg), delta)
    _orbit_outline._rotate(_local_rotation_speed_deg, delta)

func _get_base_rotation_speed(direction: float) -> float:
    return rotation_speed_deg * sign(direction)

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            _change_state(OrbitState.DRAGGED)
            _last_mouse_angle = get_local_mouse_position().rotated(-_satellite_container.rotation).angle()

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
            get_tree().create_tween().tween_property(_orbit_outline, "_color", _orbit_outline.base_color, 0.1)
            get_tree().create_tween().tween_property(_limit_label_value, "modulate", _orbit_outline.base_color, 0.1)
            _orbit_outline.start_rotation()
        OrbitState.DRAGGED:
            get_tree().create_tween().tween_property(_orbit_outline, "_color", _orbit_outline.drag_color, 0.1)
            get_tree().create_tween().tween_property(_limit_label_value, "modulate", _orbit_outline.drag_color, 0.1)
            _orbit_outline.start_rotation()
            _orbit_drag_start_signal.emit(orbit_index)
        OrbitState.TARGETTED:
            get_tree().create_tween().tween_property(_orbit_outline, "_color", _orbit_outline.target_color, 0.1)
            get_tree().create_tween().tween_property(_limit_label_value, "modulate", _orbit_outline.target_color, 0.1)
        OrbitState.HOVERED:
            if old_state == OrbitState.TARGETTED and not _is_hovered:
                # Cannot go into hovered state if targetted
                return
            _orbit_outline.slow_rotation()
            get_tree().create_tween().tween_property(_orbit_outline, "_color", _orbit_outline.hover_color, 0.1)
            get_tree().create_tween().tween_property(_limit_label_value, "modulate", _orbit_outline.hover_color, 0.1)
            _hover_width_tween = create_tween()
            _hover_width_tween.tween_property(_orbit_outline, "line_width_multiplier", _hover_line_width_multiplier, 0.15)

func _reset_hover_state() -> void:
    if _hover_width_tween != null and _hover_width_tween.is_running():
        _hover_width_tween.kill()
    _hover_width_tween = create_tween()
    _hover_width_tween.tween_property(_orbit_outline, "line_width_multiplier", 1.0, 0.1)

func _get_configuration_warnings() -> PackedStringArray:
    if not get_children().any(func(c): return is_instance_of(c, DonutCollisionPolygon2D)):
        return ["Please Attach a DonutCollisionPolygon2D called DonutCollider"]
    return []

func set_collider_width(collider_width: float) -> void:
    _collider_width = collider_width

func target() -> void:
    if _state == OrbitState.TARGETTED:
        return
    _change_state(OrbitState.TARGETTED)

func untarget() -> void:
    if _state != OrbitState.TARGETTED:
        return
    _change_state(OrbitState.IDLE)

func set_min_satellite_spacing(spacing: float) -> void:
    min_satellite_spacing = spacing

func attach_satellite(attached_satellite: Satellite) -> void:
    var satellite_spacer: SatelliteSpacer = _satellite_spacer_prefab.instantiate()
    satellite_spacer.name = "SatelliteSpacer"
    satellite_spacer.set_spacing(min_satellite_spacing)
    attached_satellite.add_child(satellite_spacer)
    attached_satellite.reparent(_satellite_container)
    satellite_spacer.set_orbit_index(orbit_index)
    # if orbit is full -> pick the closest satellite and push it one orbit outwards
    if count_satellites() > _max_satellites:
        var kicked_out_satellite: Satellite = get_closest_satellite_to(attached_satellite)
        var kicked_out_spacer: SatelliteSpacer = kicked_out_satellite.get_spacer()
        kicked_out_spacer.queue_free()
        # if next orbit does not exist --> satellite.explode
        if _next_orbit != null:
            var position_in_next_orbit: Vector2 = kicked_out_satellite.global_position.normalized() * _next_orbit.radius # TODO: Calculate
            kicked_out_satellite.reparent(main)
            kicked_out_satellite.target(position_in_next_orbit, _next_orbit)
        else:
            kicked_out_satellite.destroy()
    game_manager.check_for_next_orbit()

func get_closest_satellite_to(reference_satellite: Satellite) -> Satellite:
    var closest: Satellite = null
    var closest_pos: float
    for sat: Satellite in _satellite_container.get_children():
        if sat == reference_satellite:
            continue
        var distance_to_reference = sat.global_position.distance_to(reference_satellite.global_position)
        if closest == null or distance_to_reference < closest_pos:
            closest = sat
            closest_pos = distance_to_reference
    return closest

func set_orbit_drag_signals(start: Signal, end: Signal) -> void:
    _orbit_drag_start_signal = start
    _orbit_drag_end_signal = end

func on_orbit_drag_start(index: int) -> void:
    _is_other_dragged = index != orbit_index

func on_orbit_drag_end(_index: int) -> void:
    _is_other_dragged = false
    if _is_hovered:
        _change_state(OrbitState.HOVERED)

func on_slingshot_state_changed(slingshot_state: Slingshot.SlingshotState):
    _slingshot_state = slingshot_state
    if slingshot_state != Slingshot.SlingshotState.AIMING and _state != OrbitState.DRAGGED and _is_hovered:
        _change_state(OrbitState.HOVERED)

func _on_mouse_entered() -> void:
    _is_hovered = true
    if _slingshot_state != Slingshot.SlingshotState.AIMING and _state != OrbitState.DRAGGED:
        _change_state(OrbitState.HOVERED)

func _on_mouse_exited() -> void:
    _is_hovered = false
    if _state == OrbitState.HOVERED:
        _change_state(OrbitState.IDLE)

func count_satellites() -> int:
    return _satellite_container.get_child_count()

func set_radius(new_radius: float) -> void:
    radius = new_radius
    _orbit_outline.radius = new_radius

func set_next_orbit(orbit: Orbit) -> void:
    _next_orbit = orbit
