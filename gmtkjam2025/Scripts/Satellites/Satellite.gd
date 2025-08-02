class_name Satellite

extends Node2D

enum SatelliteType {
    DEFAULT,
    SHIELDER,
    CHARGER,
}

enum SatelliteState {
    IDLE,
    TARGETING,
    IN_ORBIT,
    LEAVING,
}

static var explosion_prefab: PackedScene = load("res://Prefabs/Satellites/Explosion.tscn") as PackedScene

@export var speed_factor: float = 1.5
@export var min_speed: float = 100

@onready var main: Node2D = $/root/Main
@onready var leaving_star: LeavingStar = $LeavingStar

var state: SatelliteState = SatelliteState.IDLE

var target_orbit: Orbit
var speed: float = 0

var is_approaching_target_position: bool = false
var target_node: Node2D

var leaving_rotation_direction: int = 1

func _ready() -> void:
    leaving_rotation_direction = [-1, 1].pick_random()

func _process(delta: float):
    match state:
        SatelliteState.IDLE:
            pass
        SatelliteState.TARGETING:
            var dist := (target_node.global_position - global_position).length()
            speed = max(dist * speed_factor, min_speed)
            global_position = global_position.move_toward(target_node.global_position, speed * delta)
            global_position = global_position.move_toward(global_position.normalized() * target_orbit.radius, 0.2 * speed * delta)
            global_rotation = global_position.angle() + PI / 2

            if !is_approaching_target_position and dist < 150:
                target_node.reparent(target_orbit._satellite_targets)
                is_approaching_target_position = true
            if abs(target_orbit.radius - global_position.length()) < 20:
                target_orbit.attach_satellite(self)
                state = SatelliteState.IN_ORBIT
                target_node.queue_free()
                var energy_shield: EnergyShield = get_node_or_null("EnergyShield")
                if energy_shield != null:
                    energy_shield.deploy_shield()
        SatelliteState.LEAVING:
            rotation += leaving_rotation_direction * delta * PI / 2
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

func dismiss_from_orbits():
    get_spacer().queue_free()
    reparent(main)
    state = SatelliteState.LEAVING
    var tween: Tween = create_tween()
    tween.tween_property(self, "global_position", global_position.normalized() * (target_orbit.radius + 100), 1).set_ease(Tween.EASE_OUT)
    tween.parallel().tween_property(self, "modulate", Color.hex(0x141624), 1).set_ease(Tween.EASE_OUT)
    tween.parallel().tween_property(self, "scale", Vector2.ZERO, 1).set_ease(Tween.EASE_IN)
    tween.tween_callback(on_satellite_left)

func on_satellite_left():
    leaving_star.reparent(main)
    leaving_star.play()
    # TODO: Play Sound Effect
    queue_free()

func destroy():
    var explosion := explosion_prefab.instantiate() as Explosion
    main.add_child(explosion)
    explosion.global_position = global_position
    explosion.play()
    if target_node != null:
        target_node.queue_free()
    queue_free()

func get_spacer() -> SatelliteSpacer:
    return $SatelliteSpacer
