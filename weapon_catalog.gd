extends RefCounted

const BLUE_PISTOL := {
	"id": "blue_pistol",
	"name": "Blue Pistol",
	"weapon_type": "pistol",
	"weapon_color": Color(0.22, 0.45, 1.0),
	"bullet_color": Color(1.0, 0.18, 0.2),
	"projectile_style": "round",
	"damage": 1,
	"shots_per_second": 2.83,
	"slow_fraction": 0.0,
}

const RED_ICE_PISTOL := {
	"id": "red_ice_pistol",
	"name": "Red Ice Pistol",
	"weapon_type": "pistol",
	"weapon_color": Color(1.0, 0.18, 0.2),
	"bullet_color": Color(0.48, 0.84, 1.0),
	"projectile_style": "ice_spike",
	"damage": 5,
	"shots_per_second": 2.83,
	"slow_fraction": 0.0,
	"freeze_duration": 3.0,
}

const PINK_BOW := {
	"id": "pink_bow",
	"name": "Pink Heart Bow",
	"weapon_type": "bow",
	"weapon_color": Color(1.0, 0.35, 0.72),
	"bullet_color": Color(1.0, 0.48, 0.76),
	"projectile_style": "heart_arrow",
	"damage": 5,
	"shots_per_second": 0.8,
	"slow_fraction": 0.0,
}


static func get_weapon(weapon_id: String) -> Dictionary:
	match weapon_id:
		"blue_pistol":
			return BLUE_PISTOL.duplicate()
		"red_ice_pistol":
			return RED_ICE_PISTOL.duplicate()
		"pink_bow":
			return PINK_BOW.duplicate()
		_:
			push_error("Unknown weapon id: %s" % weapon_id)
			return BLUE_PISTOL.duplicate()
