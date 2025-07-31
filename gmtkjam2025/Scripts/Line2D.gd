extends Node2D

var red_line_scene = preload("res://Scenes/RedLine.tscn")
var spawn_timer: Timer

func _ready():
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 2.0
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

func _on_spawn_timer_timeout():
	var red_line_instance = red_line_scene.instantiate()
	
	var random_x = randf_range(50, 700)
	var random_y = randf_range(50, 500)
	red_line_instance.position = Vector2(random_x, random_y)
	
	add_child(red_line_instance)
