extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var iceSpearTimer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer")
@onready var progressBar = get_node("%ExpBar")
@onready var label = get_node("%LevelLabel")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeChoose = get_node("%UpgradeChoose")
@onready var soundLevelUp = get_node("%LevelUpSound")
@onready var itemOptions = preload("res://scenes/Item.tscn")

@export var hp = 10
@export var speed = 150

var animation = "Idle"
var iceSpear = preload("res://scenes/IceSpear.tscn")
var icespear_ammo = 0
var icespear_baseammo = 1
var icespear_attackspeed = 1.5
var icespear_level = 1
var experience = 0
var exp_level = 1
var exp_collected = 0
var enemy_close = []

func _ready():
	attack()
	set_progress_bar(experience, calculate_exp_cap())
 
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


func _on_grab_gem_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self

func calculate_exp_cap():
	var exp_cap = exp_level
	if exp_level < 20:
		exp_cap = exp_level * 5
	elif exp_level < 40:
		exp_cap = 95 + (exp_level-19) * 8
	else:
		exp_cap = 255 + (exp_level-39) * 12
	return exp_cap

func calculate_exp(gem):
	var exp_next_level = calculate_exp_cap()
	exp_collected += gem
	if experience + exp_collected >= exp_next_level:
		exp_collected -= exp_next_level - experience
		exp_level += 1
		label.text = str("Level: ", exp_level)
		experience = 0
		exp_next_level = calculate_exp_cap()
		level_up()
		calculate_exp(0) # handle kalo exp lebih gede
	else:
		experience += exp_collected
		exp_collected = 0
	set_progress_bar(experience, exp_next_level)

func set_progress_bar(value = 1, max_value = 100):
	progressBar.value = value
	progressBar.max_value = max_value
		
func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var gem = area.collect()
		calculate_exp(gem)

func level_up():
	soundLevelUp.play()
	label.text = str("Level: ", exp_level)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel, "position", Vector2(220,50), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	for i in range(3):
		var item_choice = itemOptions.instantiate()
		upgradeChoose.add_child(item_choice)
	get_tree().paused = true
	
func upgrade_character(upgrade):
	var options = upgradeChoose.get_children()
	for i in options:
		i.queue_free()
	levelPanel.visible = false
	levelPanel.position = Vector2(800, 50)
	get_tree().paused = false
	calculate_exp(0)
