extends CharacterBody2D

@export var speed = 40
@export var hp = 10
@export var knockback_recover = 3.5
@export var experience = 1

@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $AnimatedSprite2D
@onready var hit_sound = $HitSound

var death = preload("res://scenes/Explosion.tscn")
var gem = preload("res://scenes/Gem.tscn")

var animation = "Run"
var knockback = Vector2.ZERO

signal remove_from_array(object)
	
func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recover)
	sprite.play(animation)
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	velocity += knockback
	move_and_slide()

func death_behaviour():
	emit_signal("remove_from_array", self)
	var enemy_death = death.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	var new_gem = gem.instantiate()
	new_gem.global_position = global_position
	new_gem.exp_value = experience
	loot_base.call_deferred("add_child", new_gem)
	queue_free()
	

func _on_hurt_box_hurt(damage, angle, knockback_amount):
	hp -= damage
	knockback = angle * knockback_amount
	if hp <= 0:
		death_behaviour()
	else:
		hit_sound.play()
