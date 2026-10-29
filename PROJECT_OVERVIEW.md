# Project Overview — Agentic AI Workshop (Godot 4.7)

## Engine & Config
- **Engine**: Godot 4.7 (Forward Plus renderer, gl_compatibility backend)
- **Resolution**: 1920x1080, viewport stretch mode
- **Main Scene**: `res://survivors_game.tscn`
- **Language**: GDScript
- **Autoload**: `FeatureLibrary` → `res://features/library.gd`

## Genre
Top-down survival shooter — player moves with WASD, auto-fires at nearby enemies that chase the player. When health reaches zero, game over screen appears and the tree pauses.

---

## Scene Hierarchy (Main: `survivors_game.tscn`)

```
Game (Node2D)                          ← game.gd — spawner + game-over logic
├── Timer                              ← spawns enemies every 0.3s on random path positions
├── Player (CharacterBody2D)           ← player.tscn / player.gd — in group "player"
│   ├── HappyBoo (AnimatedSprite2D)    ← character sprite with walk/idle animations
│   ├── CollisionShape2D               ← rectangle 66x38
│   ├── Camera2D                       ← follows player
│   ├── Gun (Area2D)                   ← gun.tscn / gun.gd — auto-aim + auto-fire
│   │   ├── CollisionShape2D           ← circle r=987 detection radius
│   │   ├── WeaponPivot (Marker2D)     ← pivot for weapon rotation
│   │   │   ├── Pistol (Sprite2D)      ← pistol sprite
│   │   │   └── ShootingPoint (Marker2D) ← bullet spawn origin
│   │   └── Timer                      ← fires every 0.353s
│   ├── HurtBox (Area2D)               ← detects overlapping mobs, applies damage
│   └── HealthBar (ProgressBar)        ← visual health display above player
├── Path2D → PathFollow2D              ← spawn path (pentagonal loop around arena)
├── GameOver (CanvasLayer)             ← hidden until death; shows "Game Over" label + dark overlay
└── PineTree x10                       ← decorative scenery (trees/pine_tree.tscn)
```

---

## Feature System (the part that matters in the workshop)

Every participant owns one feature — an enemy or an item — in their own folder:

```
res://features/<studentname>-<featurename>/
```

**`features/library.gd`** (autoload `FeatureLibrary`) reads two text manifests
at startup and exposes the registered scenes:

| File | Contents |
|---|---|
| `features/enemies.txt` | one `res://.../*.tscn` path per line |
| `features/items.txt` | one `res://.../*.tscn` path per line |

Lines starting with `#` are ignored; duplicates are skipped; a path that does not
exist produces a warning and is skipped rather than crashing the game.

API used by the game:
- `FeatureLibrary.random_enemy() -> PackedScene` — a random registered enemy, or `res://mob.tscn` if the list is empty
- `FeatureLibrary.random_item() -> PackedScene` — a random registered item, or `null` if none
- `FeatureLibrary.enemies` / `.items` — the loaded arrays

**Templates** students copy:
- `features/_template/enemy/` — `CharacterBody2D`, layer 2, chases the player, `take_damage()`, optional `death_sound`
- `features/_template/item/` — `Area2D`, mask 1, detects the player, optional `pickup_sound`, `heal_amount`

Nothing in the main scene needs editing to add a feature. That is deliberate: it
keeps the integration surface at one line of text per feature, so nineteen people
can work in parallel without touching the same scene.

---

## Scripts Summary

### `game.gd` — Game Manager / Spawner
- **Extends**: `Node2D`
- **Responsibilities**: Spawn enemies and items at random positions along a PathFollow2D, handle game-over state
- **Key Functions**:
  - `spawn_mob()` — instantiates `FeatureLibrary.random_enemy()` at a random point on the path
  - `spawn_item()` — instantiates `FeatureLibrary.random_item()` (only if items are registered)
  - `_process(delta)` — item drop timer, controlled by exported `item_interval` (default 8s; 0 disables)
  - `_on_timer_timeout()` — triggers enemy spawn (every 0.3s)
  - `_on_player_health_depleted()` — shows GameOver UI, pauses tree

### `player.gd` — Player Controller
- **Extends**: `CharacterBody2D`
- **Responsibilities**: Movement (WASD via input actions), animation state, damage from overlapping enemies
- **Signals**: `health_depleted` — emitted when health ≤ 0
- **Key Variables**:
  - `health = 100.0`, `MAX_HEALTH = 100.0`
  - `SPEED = 600` px/s
  - `DAMAGE_RATE = 6.0` per overlapping mob per second
- **Key Functions**:
  - `heal(amount)` — adds health up to `MAX_HEALTH`, updates the bar. Called by item features.
- **Groups**: `player` — enemies and items find the player with `get_tree().get_first_node_in_group("player")`
- **Input Actions**: `move_left`, `move_right`, `move_up`, `move_down` (A/D/W/S)

### `mob.gd` — Original Enemy AI (still the fallback enemy)
- **Extends**: `CharacterBody2D`
- **Responsibilities**: Chase player, take damage, spawn death effect on kill
- **Key Variables**:
  - `speed = randf_range(200, 300)` (random per mob)
  - `health = 3` (takes 3 bullets to kill)
- **Signals**: `died` (defined but not currently connected)
- **Key Functions**:
  - `_physics_process()` — moves toward player via `direction_to()`
  - `take_damage()` — plays hurt animation, decrements health, spawns smoke explosion on death

### `gun.gd` — Auto-Aim Weapon
- **Extends**: `Area2D`
- **Responsibilities**: Detect nearest enemy in range (r=987), rotate toward it, fire bullets
- **Key Functions**:
  - `_process()` — finds closest overlapping body, calls `look_at()` to aim
  - `shoot()` — instantiates bullet at ShootingPoint with matching transform
  - `_on_timer_timeout()` — triggers shoot (every 0.353s)

### `bullet_2d.gd` — Projectile
- **Extends**: `Area2D`
- **Responsibilities**: Move forward in facing direction, self-destruct on range expiry or body collision
- **Key Variables**:
  - `SPEED = 1000` px/s
  - `RANGE = 1200` px max travel distance
- **Key Functions**:
  - `_physics_process()` — moves along rotated RIGHT vector, destroys if past range
  - `_on_body_entered(body)` — calls `body.take_damage()` if method exists, then self-destructs

### `features/library.gd` — Feature Registry (autoload)
- **Extends**: `Node`
- **Responsibilities**: Parse the manifests, load the scene paths, hand out random enemies/items
- **Key Functions**: `_load_manifest(path)`, `random_enemy()`, `random_item()`

### `smoke_explosion/smoke_explosion.gd` — Death Effect
- **Extends**: `Node2D`
- **Responsibilities**: Play explosion animation with randomized shader offset, auto-remove on finish

---

## Collision Layers
| Layer | Purpose |
|-------|---------|
| 1 (default) | Player body / Gun detection area |
| 2 ("player") | Enemy collision layer — enemies are on this layer; player HurtBox, Gun and bullets detect it |

- **Player CollisionShape2D**: default layer; items detect it with `collision_mask = 1`
- **HurtBox (Area2D)**: mask=2 (detects enemies), layer=0
- **Gun (Area2D)**: mask=2 (detects enemies for aiming), layer=0
- **Enemy CollisionShape2D**: layer=2
- **Bullet (Area2D)**: mask=3, calls `take_damage()` on any body that has it

---

## Assets Structure
```
characters/
├── happy_boo/         ← player character sprite + animations
└── slime/             ← enemy character sprite + animations
pistol/
├── pistol.png         ← weapon sprite
├── projectile.png     ← bullet sprite
├── impact/            ← muzzle impact effects
└── muzzle_flash/      ← muzzle flash effects
smoke_explosion/       ← death particle effect (shader-based)
trees/
└── pine_tree.tscn     ← decorative tree scene
features/
├── _template/enemy/   ← starting point for an enemy feature
├── _template/item/    ← starting point for an item feature
└── <student>-<thing>/ ← student feature folders (art/, sound/, scene, script)
addons/
└── colorpicker_presets/  ← editor plugin
```

---

## Game Flow
1. Game starts → Timer spawns enemies every 0.3s at random positions on a pentagonal path around the arena, picking a random registered enemy (or the original slime)
2. Each enemy chases the player at its own speed
3. Gun auto-detects nearest enemy in range (987px radius), aims, and fires every 0.353s
4. Bullets travel at 1000 px/s up to 1200px range; hitting an enemy calls `take_damage()`
5. Enemies that run out of health die (smoke explosion for the slime, whatever the student built for their own)
6. If enemies overlap the player's HurtBox, player loses 6 HP/enemy/second
7. Every `item_interval` seconds an item drops at a random point on the path, if any item features are registered
8. When player health reaches 0 → Game Over screen shows, game pauses
