extends CharacterBody2D

signal health_depleted
signal progression_changed(level: int, skill_points: int, xp: int, xp_to_next: int)
signal level_up(level: int)

const MAX_HEALTH := 100.0
const BASE_SPEED := 600.0

var health = 100.0
var level := 1
var skill_points := 0
var experience := 0
var xp_to_next := 5
var _speed_boost_time_remaining := 0.0
var _speed_multiplier := 1.0


func apply_speed_boost(duration: float = 5.0, multiplier: float = 1.75) -> void:
	_speed_boost_time_remaining = maxf(duration, 0.0)
	_speed_multiplier = maxf(multiplier, 1.0)


func gain_experience(amount: int = 1) -> void:
	experience += amount
	while experience >= xp_to_next:
		experience -= xp_to_next
		level += 1
		skill_points += 1
		xp_to_next += 2
		_play_level_up_effect()
		level_up.emit(level)
	progression_changed.emit(level, skill_points, experience, xp_to_next)


func _play_level_up_effect() -> void:
	var burst := Node2D.new()
	burst.z_index = 20
	add_child(burst)
	for ring_index in 2:
		var ring := Line2D.new()
		ring.width = 9.0 if ring_index == 0 else 4.0
		ring.default_color = Color(0.35, 0.95, 1.0, 1.0) if ring_index == 0 else Color(1.0, 0.82, 0.25, 1.0)
		ring.begin_cap_mode = Line2D.LINE_CAP_ROUND
		ring.end_cap_mode = Line2D.LINE_CAP_ROUND
		for point_index in 49:
			var angle := TAU * float(point_index) / 48.0
			ring.add_point(Vector2.RIGHT.rotated(angle) * 48.0)
		burst.add_child(ring)
	var particles := CPUParticles2D.new()
	particles.amount = 42
	particles.lifetime = 0.9
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.direction = Vector2.UP
	particles.spread = 180.0
	particles.initial_velocity_min = 170.0
	particles.initial_velocity_max = 360.0
	particles.gravity = Vector2.ZERO
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 7.0
	particles.color = Color(1.0, 0.78, 0.22, 1.0)
	burst.add_child(particles)
	particles.emitting = true
	var effect_tween := create_tween().set_parallel(true)
	effect_tween.tween_property(burst, "scale", Vector2(2.4, 2.4), 0.75).from(Vector2(0.45, 0.45)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	effect_tween.tween_property(burst, "modulate:a", 0.0, 0.75).set_ease(Tween.EASE_IN)
	var player_tween := create_tween()
	player_tween.tween_property(self, "modulate", Color(0.45, 1.0, 1.0), 0.12)
	player_tween.tween_property(self, "modulate", Color.WHITE, 0.32)
	var camera := get_node_or_null("Camera2D")
	if camera is Camera2D:
		var camera_tween := create_tween()
		for shake_index in 6:
			camera_tween.tween_property(camera, "offset", Vector2(randf_range(-9.0, 9.0), randf_range(-7.0, 7.0)), 0.035)
		camera_tween.tween_property(camera, "offset", Vector2.ZERO, 0.12)
	await get_tree().create_timer(1.0).timeout
	burst.queue_free()


## Called by item features (e.g. a health pack). Keeps the health bar in sync.
func heal(amount: float) -> void:
	health = min(health + amount, MAX_HEALTH)
	%HealthBar.value = health


func take_damage(amount: float) -> void:
	if health <= 0.0:
		return
	health = maxf(health - amount, 0.0)
	%HealthBar.value = health
	if health <= 0.0:
		health_depleted.emit()


func _physics_process(delta):
	if _speed_boost_time_remaining > 0.0:
		_speed_boost_time_remaining = maxf(_speed_boost_time_remaining - delta, 0.0)
		if _speed_boost_time_remaining == 0.0:
			_speed_multiplier = 1.0

	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * BASE_SPEED * _speed_multiplier

	move_and_slide()
	
	if velocity.length() > 0.0:
		%HappyBoo.play_walk_animation()
	else:
		%HappyBoo.play_idle_animation()
	
	# Taking damage
	const DAMAGE_RATE = 6.0
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs:
		health -= DAMAGE_RATE * overlapping_mobs.size() * delta
		%HealthBar.value = health
		if health <= 0.0:
			health_depleted.emit()
