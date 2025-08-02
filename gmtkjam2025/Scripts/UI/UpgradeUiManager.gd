class_name UpgradeUiManager

extends Control

@export var rockets: Array[RocketController]

@onready var satellite_counter: SatelliteCounter = $/root/Main/Earth/SatelliteCounter
@onready var slingshot: Slingshot = $/root/Main/Earth/Slingshot
@onready var background: ColorRect = $Background

var background_fade_time: float = 0.5
var fly_in_time: float = 2.0
var fly_out_time: float = 2.0
var shrink_time: float = 1.0
var rocket_offset_time: float = 0.25
var can_select = false

var background_tween: Tween

func _ready() -> void:
    visible = false

func show_menu():
    get_tree().paused = true
    visible = true

    for i in range(rockets.size()):
        rockets[i].reset_rocket()
        rockets[i].fly_in()

    if background_tween != null:
        background_tween.kill()
    background_tween = create_tween()
    background_tween.tween_property(background, "color", Color(Color.BLACK, 0.5), background_fade_time)

    await get_tree().create_timer(fly_in_time + (rockets.size() - 1) * rocket_offset_time).timeout

    enable_rockets()

func enable_rockets():
    can_select = true

func select_rocket(rocket: RocketController):
    if can_select == false:
        return
    can_select = false

    satellite_counter.increase_counter(rocket.amount, false)
    slingshot.next_satellite = rocket.satellite_type

    for i in range(rockets.size()):
        if rockets[i] == rocket:
            rockets[i].shrink()
        else:
            rockets[i].fly_out()

    if background_tween != null:
        background_tween.kill()
    background_tween = create_tween()
    background_tween.tween_property(background, "color", Color(Color.BLACK, 0.0), background_fade_time).set_delay(fly_out_time + (rockets.size() - 1) * rocket_offset_time - background_fade_time)

    await get_tree().create_timer(fly_out_time + (rockets.size() - 1) * rocket_offset_time).timeout

    for i in range(rockets.size()):
        rockets[i].reset_rocket()
        
    visible = false
    get_tree().paused = false
