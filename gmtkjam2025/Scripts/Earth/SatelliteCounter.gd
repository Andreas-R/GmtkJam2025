class_name SatelliteCounter

extends Node2D

@export var color1: Color = Color.RED
@export var color2: Color = Color.GREEN

@onready var timer: Timer = $Timer
@onready var counterPivot: Node2D = $CounterPivot
@onready var counterLabel: Label = $CounterPivot/CounterLabel
@onready var progress: TextureProgressBar = $Progress

var satelliteCount: int = 100;
var spawn_time: float = 5;
var wobble_tween: Tween

func _ready() -> void:
    update_counter()
    start_timer(spawn_time)

func _process(_delta: float):
    var t := (timer.wait_time - timer.time_left) / timer.wait_time
    progress.value = t * 100
    progress.modulate = lerp(color1, color2, t)

func start_timer(wait_time: float):
    timer.start(wait_time)

func on_timer_timeout() -> void:
    satelliteCount += 1
    update_counter()
    wobble()
    start_timer(spawn_time)

func update_counter():
    counterLabel.text = str(satelliteCount)

func decrease_counter():
    satelliteCount -= 1
    counterLabel.text = str(satelliteCount)

func wobble():
    if wobble_tween != null:
        wobble_tween.kill()
    wobble_tween = create_tween().set_ease(Tween.EASE_IN_OUT)

    wobble_tween.tween_property(counterPivot, "scale", Vector2(1.5, 1.5), 0.1)
    wobble_tween.tween_property(counterPivot, "scale", Vector2(0.75, 0.75), 0.1)
    wobble_tween.tween_property(counterPivot, "scale", Vector2(1, 1), 0.1)
