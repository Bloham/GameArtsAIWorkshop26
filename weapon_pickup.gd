extends Area2D

const TINT_SHADER = preload("res://weapon_tint.gdshader")

var weapon_data: Dictionary = {}


func configure(new_weapon_data: Dictionary) -> void:
	weapon_data = new_weapon_data.duplicate()
	if is_node_ready():
		_update_visuals()


func _ready() -> void:
	_update_visuals()


func _update_visuals() -> void:
	if weapon_data.is_empty():
		return

	var is_bow: bool = weapon_data.get("weapon_type", "pistol") == "bow"
	var weapon_color: Color = weapon_data.get("weapon_color", Color.WHITE)
	var weapon_sprite := get_node("WeaponSprite") as Sprite2D
	var bow_visual := get_node("BowVisual") as Node2D
	weapon_sprite.visible = not is_bow
	bow_visual.visible = is_bow
	if is_bow:
		bow_visual.call("configure", "bow", weapon_color)
	else:
		_apply_tint(weapon_sprite, weapon_color)


func _apply_tint(sprite: Sprite2D, tint: Color) -> void:
	var tint_material := ShaderMaterial.new()
	tint_material.shader = TINT_SHADER
	tint_material.set_shader_parameter("tint_color", tint)
	sprite.material = tint_material


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or not body.has_method("equip_weapon"):
		return

	body.call("equip_weapon", weapon_data)
	queue_free()
