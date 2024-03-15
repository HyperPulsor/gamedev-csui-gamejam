extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var iceSpearTimer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer")

@export var hp = 10
@export var speed = 150

var animation = "Idle"
var iceSpear = preload("res://scenes/IceSpear.tscn")
var icespear_ammo = 0
var icespear_baseammo = 1
var icespear_attackspeed = 1.5
var icespear_level = 1
var enemy_close = []

func _ready():
	attack()
 
func _physics_process(_delta):
	sprite.play(animation)
	player_movement()
	
func attack():
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_attackspeed
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()

func player_movement():
	var x_movement = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_movement = Input.get_action_strength("down") - Input.get_action_strength("up")
	var movement = Vector2(x_movement, y_movement)
	velocity = movement.normalized() * speed
	
	if velocity == Vector2.ZERO:
		animation = "Idle"
		if sprite.flip_h:
			$CollisionShape2D.position.x = 13
		else:
			$CollisionShape2D.position.x = - 13
	else:
		animation = "Move"
		if velocity < Vector2.ZERO:
			$CollisionShape2D.position.x = - 2
		elif velocity > Vector2.ZERO:
			$CollisionShape2D.position.x = 2
	
	if x_movement < 0:
		sprite.flip_h = true
	elif x_movement > 0:
		sprite.flip_h = false
	
	move_and_slide()


func _on_hurt_box_hurt(damage, _angle, _knockback):
	hp -= damage
	print(hp)


func _on_ice_spear_timer_timeout():
	icespear_ammo += icespear_baseammo
	iceSpearAttackTimer.start()


func _on_ice_spear_attack_timer_timeout():
	if icespear_ammo > 0:
		var icepsear_attack = iceSpear.instantiate()
		icepsear_attack.position = position
		icepsear_attack.target = get_random_target()
		icepsear_attack.level = icespear_level
		add_child(icepsear_attack)
		icespear_ammo -= 1
		if icespear_ammo > 0:
			iceSpearAttackTimer.start()
		else:
			iceSpearAttackTimer.stop()

func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP


func _on_detect_enemy_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)


func _on_detect_enemy_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)
