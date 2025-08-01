class_name SatelliteSpacer

extends Node2D

enum SpacingState {
    SPACING_OUT,
    STEADY
}

@onready var collider: CollisionObject2D = $Area2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D

@export var max_force: float = 20.0
var _orbit_index: int = -1
# var _parent_satellite: Satellite
var _parent_satellite
var _other_spacers: Array[SatelliteSpacer]

var _min_spacing: float = 50.0

var _state: SpacingState

func _ready() -> void:
    collision_shape.shape = CircleShape2D.new()
    collision_shape.shape.radius = _min_spacing
    _other_spacers = []
    #assert(get_parent() is Satellite) # TODO: Activate once testing done
    _parent_satellite = get_parent()
    _state = SpacingState.STEADY
    set_orbit_index(1) # TODO: Remove

func _process(delta: float) -> void:
    match _state:
        SpacingState.STEADY:
            return
        SpacingState.SPACING_OUT:
            _parent_satellite.position = _parent_satellite.position.rotated(_get_avg_target_angle() * max_force * delta)
            _parent_satellite.rotation = _parent_satellite.position.angle() + PI / 2

func set_orbit_index(orbit_index: int) -> void:
    collider.set_collision_mask_value((orbit_index % 16) + 16, true)
    collider.set_collision_layer_value((orbit_index % 16) + 16, true)
    _orbit_index = orbit_index

# TODO: Change return to Satellite
func get_satellite() -> Node2D:
    return _parent_satellite

func set_spacing(spacing: float) -> void:
    _min_spacing = spacing

func _get_avg_target_angle() -> float:
    var avg_angle: float = .0
    for spacer: SatelliteSpacer in _other_spacers:
        var position_diff: Vector2 = _parent_satellite.position - spacer.get_satellite().position
        var pushing_power: float = max(1.0 - (position_diff.length() / (_min_spacing * 2)), 0.001) 
        avg_angle += _parent_satellite.position.angle_to(position_diff) * pushing_power * pushing_power
    avg_angle /= _other_spacers.size()
    return avg_angle

func _on_area_2d_area_entered(area: Area2D) -> void:
    _state = SpacingState.SPACING_OUT
    _other_spacers.append(area.get_parent())

func _on_area_2d_area_exited(_area: Area2D) -> void:
    _other_spacers.erase(_area.get_parent())
    print("Spacer Exited: ", _other_spacers.size(), " left")
    if _other_spacers.size() == 0:
        _state = SpacingState.STEADY
