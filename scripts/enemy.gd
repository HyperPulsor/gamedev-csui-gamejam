extends CharacterBody2D

@export var speed = 40
@export var hp = 10
@export var knockback_recover = 3.5

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $AnimatedSprite2D

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


func _on_hurt_box_hurt(damage, angle, knockback_amount):
	hp -= damage
	knockback = angle * knockback_amount
	if hp <= 0:
		emit_signal("remove_from_array", self)
		queue_free()
