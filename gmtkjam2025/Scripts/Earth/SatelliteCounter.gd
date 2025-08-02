class_name SatelliteCounter

extends Node2D

@export var color1: Color = Color.RED
@export var color2: Color = Color.GREEN

@onready var game_manager: GameManager = $/root/Main/GameManager
@onready var timer: Timer = $Timer
@onready var counter_pivot: Node2D = $CounterPivot
@onready var counter_label: Label = $CounterPivot/CounterLabel
@onready var progress: TextureProgressBar = $Progress

var satellite_count: int = 1;
var spawn_time: float = 6.0;
var wobble_tween: Tween

func _ready() -> void:
    update_counter()

func _process(_delta: float):
    if game_manager.started_game:
        var t := (timer.wait_time - timer.time_left) / timer.wait_time
        progress.value = t * 100
        progress.modulate = lerp(color1, color2, t)

func start():
    timer.start(spawn_time)

func on_timer_timeout() -> void:
    increase_counter(1)
    timer.start(spawn_time)

func update_counter():
    counter_label.text = str(satellite_count)
    
func increase_counter(amount: int, animate = true):
    satellite_count += amount
    update_counter()
    if animate:
        wobble()

func decrease_counter():
    satellite_count -= 1
    counter_label.text = str(satellite_count)

func wobble():
    if wobble_tween != null:
        wobble_tween.kill()
    wobble_tween = create_tween().set_ease(Tween.EASE_IN_OUT)

    wobble_tween.tween_property(counter_pivot, "scale", Vector2(1.5, 1.5), 0.1)
    wobble_tween.tween_property(counter_pivot, "scale", Vector2(0.75, 0.75), 0.1)
    wobble_tween.tween_property(counter_pivot, "scale", Vector2(1, 1), 0.1)
