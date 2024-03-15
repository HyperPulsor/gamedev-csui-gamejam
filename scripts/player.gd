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
@onready var fireballTimer = get_node("%FireballTimer")
@onready var fireballAttackTimer = get_node("%FireballAttackTimer")
@onready var healthBar = get_node("%HealthBar")
@onready var shieldLabel = get_node("%ShieldLabel")
@onready var labelTimer = get_node("%TimerLabel")
@onready var shieldTimer = $ShieldTimer

@export var hp = 100
@export var speed = 150

var maxhp = 100
var animation = "Idle"
var iceSpear = preload("res://scenes/IceSpear.tscn")
var fireball = preload("res://scenes/Fireball.tscn")
var icespear_ammo = 0
var icespear_baseammo = 1
var icespear_attackspeed = 1.5
var icespear_level = 1

var fireball_ammo = 0
var fireball_baseammo = 1
var fireball_attackspeed = 3
var fireball_level = 1

var experience = 0
var experience_level = 1
var collected_experience = 0
var enemy_close = []
var last_movement = Vector2.UP

var collected_upgrades = []
var upgrade_options = []
var armor_upgrade = 0
var speed_upgrade = 0
var spell_cooldown = 0
var spell_size = 0
var additional_attacks = 0
var isShielded = false
var time = 0

func _ready():
	attack()
	set_progress_bar(experience, calculate_exp_cap())
	_on_hurt_box_hurt(0,0,0)
 
func _physics_process(_delta):
	sprite.play(animation)
	player_movement()
	if hp <= 0:
		get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
	
func attack():
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_attackspeed
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()
	if fireball_level > 0:
		fireballTimer.wait_time = fireball_attackspeed
		if fireballTimer.is_stopped():
			fireballTimer.start()

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
		last_movement = movement
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
	if not isShielded:
		hp -= damage
		healthBar.max_value = maxhp
		healthBar.value = hp

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
			
func _on_fireball_timer_timeout():
	fireball_ammo += fireball_baseammo
	fireballAttackTimer.start()


func _on_fireball_attack_timer_timeout():
	if fireball_ammo > 0:
		var fireball_attack = fireball.instantiate()
		fireball_attack.position = position
		fireball_attack.last_movement = last_movement
		fireball_attack.level = fireball_level
		add_child(fireball_attack)
		fireball_ammo -= 1
		if fireball_ammo > 0:
			fireballAttackTimer.start()
		else:
			fireballAttackTimer.stop()

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
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level * 5
	elif experience_level < 40:
		exp_cap = 95 + (experience_level-19) * 8
	else:
		exp_cap = 255 + (experience_level-39) * 12
	return exp_cap

func calculate_exp(gem_exp):
	var exp_required = calculate_exp_cap()
	collected_experience += gem_exp
	if experience + collected_experience >= exp_required:
		collected_experience -= exp_required - experience
		experience_level += 1
		experience = 0
		exp_required = calculate_exp_cap()
		level_up()
		calculate_exp(0)
	else:
		experience += collected_experience
		collected_experience = 0
	set_progress_bar(experience, exp_required)

func set_progress_bar(value = 1, max_value = 100):
	progressBar.value = value
	progressBar.max_value = max_value
		
func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_exp(gem_exp)

func level_up():
	soundLevelUp.play()
	label.text = str("Level: ", experience_level)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel, "position", Vector2(220,50), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	var options = 0
	var optionsmax = 3
	while options < optionsmax:
		var item_choice = itemOptions.instantiate()
		item_choice.item = get_random_upgrade()
		upgradeChoose.add_child(item_choice)
		options += 1
	get_tree().paused = true
	
func upgrade_character(upgrade):
	match upgrade:
		"icespear1":
			icespear_level = 1
			icespear_baseammo += 1
		"icespear2":
			icespear_level = 2
			icespear_baseammo += 1
		"icespear3":
			icespear_level = 3
		"icespear4":
			icespear_level = 4
			icespear_baseammo += 2
		"fireball1":
			fireball_level = 1
			fireball_baseammo += 1
		"fireball2":
			fireball_level = 2
			fireball_baseammo += 1
		"fireball3":
			fireball_level = 3
			fireball_attackspeed -= 0.5
		"fireball4":
			fireball_level = 4
			fireball_baseammo += 1
		"food":
			hp += 20
			hp = clamp(hp,0,maxhp)
		"shield":
			start_shield()
	var options = upgradeChoose.get_children()
	for i in options:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	levelPanel.visible = false
	levelPanel.position = Vector2(800, 50)
	get_tree().paused = false
	calculate_exp(0)

func get_random_upgrade():
	var dblist = []
	for i in UpgradeDb.UPGRADES:
		if i in collected_upgrades:
			pass
		elif i in upgrade_options:
			pass
		elif UpgradeDb.UPGRADES[i]["type"] == "item":
			pass
		elif UpgradeDb.UPGRADES[i]["prerequisite"].size() > 0:
			var to_add = true
			for n in UpgradeDb.UPGRADES[i]["prerequisite"]:
				if not n in collected_upgrades:
					to_add = false
			if to_add:
				dblist.append(i)
		else:
			dblist.append(i)
	if dblist.size() > 0:
		var randomitem = dblist.pick_random()
		upgrade_options.append(randomitem)
		return randomitem
	else:
		return null
		

func start_shield():
	shieldTimer.start()
	shieldLabel.text = "Shield Active!"
	isShielded = true
	
func _on_shield_timer_timeout():
	shieldLabel.text = ""
	isShielded = false

func change_time(part_time = 0):
	time = part_time
	var get_minutes = int(time/60.0)
	var get_seconds = time % 60
	if get_minutes < 10: # 1 digit
		get_minutes = str(0, get_minutes)
	if get_seconds < 10:
		get_seconds = str(0, get_seconds)
	labelTimer.text = str(get_minutes, ":", get_seconds)
