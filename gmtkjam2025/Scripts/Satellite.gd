class_name Satellite

extends Node2D

enum SatelliteState {
    CHARGING,
    TARGETING,
    IN_ORBIT,
}

@export var speed_factor: float = 1.5
@export var min_speed: float = 100

var state: SatelliteState = SatelliteState.CHARGING

var target_pos: Vector2
var speed: float = 0

func _process(delta: float):
    match state:
        SatelliteState.CHARGING:
            pass
        SatelliteState.TARGETING:
            var dist := (target_pos - global_position).length()
            speed = max(dist * speed_factor, min_speed)
            global_position = global_position.move_toward(target_pos, speed * delta)

            if dist < 0.001:
                # TODO search nearest orbit
                state = SatelliteState.IN_ORBIT
        SatelliteState.IN_ORBIT:
            pass

func target(pos: Vector2):
    target_pos = pos
    state = SatelliteState.TARGETING
