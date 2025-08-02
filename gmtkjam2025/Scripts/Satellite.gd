class_name Satellite

extends Node2D

enum SatelliteState {
    IDLE,
    TARGETING,
    IN_ORBIT,
}

static var explosion_prefab: PackedScene = load("res://Prefabs/Explosion.tscn") as PackedScene

@export var speed_factor: float = 1.5
@export var min_speed: float = 100

@onready var main: Node2D = $/root/Main

var state: SatelliteState = SatelliteState.IDLE

var target_orbit: Orbit
var speed: float = 0

var is_approaching_target_position: bool = false
var target_node: Node2D

func _process(delta: float):
    match state:
        SatelliteState.IDLE:
            pass
        SatelliteState.TARGETING:
            var dist := (target_node.global_position - global_position).length()
            speed = max(dist * speed_factor, min_speed)
            global_position = global_position.move_toward(target_node.global_position, speed * delta)
            global_rotation = global_position.angle() + PI / 2

            if !is_approaching_target_position and dist < 150:
                target_node.reparent(target_orbit._satellite_targets)
                is_approaching_target_position = true
            if abs(target_orbit.radius - global_position.length()) < 20:
                target_orbit.attach_satellite(self)
                state = SatelliteState.IN_ORBIT
                target_node.queue_free()
        SatelliteState.IN_ORBIT:
            pass

func target(pos: Vector2, orbit: Orbit):
    target_node = Node2D.new()
    target_node.global_position = pos
    main.add_child(target_node)
    target_orbit = orbit
    state = SatelliteState.TARGETING

func damage():
    if state == SatelliteState.IDLE:
        return
    destroy()

func destroy():
    var explosion := explosion_prefab.instantiate() as Explosion
    main.add_child(explosion)
    explosion.global_position = global_position
    explosion.play()
    if target_node != null:
        target_node.queue_free()
    queue_free()
