extends Area2D

@export var exp_value = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sound: AudioStreamPlayer = $CollectSound

var green_gem = preload("res://assets/Items/Gems/Gem_green.png")
var blue_gem = preload("res://assets/Items/Gems/Gem_blue.png")
var red_gem = preload("res://assets/Items/Gems/Gem_red.png")

var target = null
var speed = -1

func _ready():
	if exp_value < 5:
		return
	elif exp_value < 25:
		sprite.texture = blue_gem
	else:
		sprite.texture = red_gem

func _physics_process(delta):
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2 * delta
	
func collect():
	sound.play()
	collision.call_deferred("set", "disable", true)
	sprite.visible = false
	return exp_value


func _on_collect_sound_finished():
	queue_free()
