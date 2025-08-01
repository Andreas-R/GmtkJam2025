class_name Explosion

extends Node2D

@onready var particleSystem: CPUParticles2D = $CPUParticles2D

func _ready() -> void:
    particleSystem.emitting = true

func on_cpu_particles_2d_finished() -> void:
    queue_free()
