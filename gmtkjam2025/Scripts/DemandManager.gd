class_name DemandManager

extends Node2D

@onready var game_ui_manager: GameUiManager = $/root/Main/UI/GameUI
@onready var orbit_manager: OrbitManager = $/root/Main/OrbitManager
@onready var timer: Timer = $Timer

var tick_time: float = 10.0;
var health: float = 100.0
var demand: int = 0
var health_decrease: float = 0.5
var health_increase: float = 0.5

func start():
    timer.start(tick_time)

func _process(delta: float):
    var satellite_count := orbit_manager.count_satellites()

    if satellite_count > demand:
        health = min(100.0, health + health_increase * delta * (satellite_count - demand))
    elif satellite_count < demand:
        health = max(0.0, health - health_decrease * delta * (demand - satellite_count))
    
    game_ui_manager.update_health(health)
    game_ui_manager.update_arrows(satellite_count - demand, health)

    if health <= 0:
        pass # Game over

func on_timer_timeout() -> void:
    increase_demand(1)
    timer.start(tick_time)

func increase_demand(amount: int):
    demand += amount
