class_name Satellite

extends Node2D

enum SatelliteState {
    IDLE,
    TARGETING,
    IN_ORBIT,
}

@export var speed_factor: float = 1.5
@export var min_speed: float = 100

var state: SatelliteState = SatelliteState.IDLE

var target_pos: Vector2
var target_orbit: Orbit
var speed: float = 0

func _process(delta: float):
    match state:
        SatelliteState.IDLE:
            pass
        SatelliteState.TARGETING:
            var dist := (target_pos - global_position).length()
            speed = max(dist * speed_factor, min_speed)
            global_position = global_position.move_toward(target_pos, speed * delta)

            if dist < 0.001:
                target_orbit.attach_satellite(self)
                state = SatelliteState.IN_ORBIT
        SatelliteState.IN_ORBIT:
            pass

func target(pos: Vector2, orbit: Orbit):
    target_pos = pos
    target_orbit = orbit
    state = SatelliteState.TARGETING

func damage():
    destroy()

func destroy():
    queue_free()
