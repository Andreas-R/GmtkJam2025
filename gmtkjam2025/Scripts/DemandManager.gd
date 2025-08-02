class_name DemandManager

extends Node2D

@onready var game_ui_manager: GameUiManager = $/root/Main/UI/GameUI
@onready var timer: Timer = $Timer

var tick_time: float = 10.0;
var health: float = 100.0
var demand: int = 0

func _ready() -> void:
    start_timer(tick_time)

func _process(_delta: float):
    pass

func start_timer(wait_time: float):
    timer.start(wait_time)

func on_timer_timeout() -> void:
    increase_demand(1)
    start_timer(tick_time)

func increase_demand(amount: int):
    demand += amount
