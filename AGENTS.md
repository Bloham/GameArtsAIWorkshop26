# Agent Instructions

You are working in a **Godot 4.7** 2D top-down survival shooter written in
**GDScript**, in a university course where the person prompting you is a **Game
Arts student**, not a programmer. They may never have used git or an engine
before.

Your job is not only to make the change. It is to make the change **and** leave
the student able to explain what happened.

## Read this first

- **`PROJECT_OVERVIEW.md`** — scene hierarchy, scripts, collision layers, the feature system. Read it before touching anything.
- **`features/README.md`** — the workflow the student is following.

## The shape of the work

The student owns **exactly one feature** — one enemy or one item — in **one
folder**:

```
res://features/<studentname>-<featurename>/
```

Copied from `features/_template/enemy/` or `features/_template/item/`.
Everything they need to change is inside their own folder.

**Stay inside their feature folder.** The rest of the project is shared wiring
that nineteen other students depend on.

## Ground rules

1. **One request at a time.** Small, working changes. A feature that runs beats
   an ambitious one that half-works.
2. **Never edit the shared wiring** — `game.gd`, `player.gd`, `gun.gd`,
   `bullet_2d.gd`, `features/library.gd`, or any `.tscn` outside their folder —
   unless the student explicitly asks and you explain the consequence.
3. **Registration is one line** in `features/enemies.txt` or
   `features/items.txt`. Ask the student to add it themselves: it is their finish
   line, and it teaches where the boundary is.
4. **Never touch `.godot/`.** Local editor cache, not source.
5. **Keep the project runnable.** If you cannot verify that it runs, say so
   plainly instead of claiming success.
6. **Don't rename scenes, nodes or files** unless asked — it breaks `res://`
   paths. If it is genuinely needed, update every reference in the same change.
7. **Explain in two or three sentences** what you changed and where. Enough for a
   beginner to follow, not a wall of text.

## What a feature must keep true

The game relies on these. A feature that breaks them will not work when it spawns
in the real game, even if it looks fine alone.

**Enemy** (`CharacterBody2D`):
- `collision_layer = 2` — bullets hit it, touching it hurts the player
- has a `take_damage()` function — that is what bullets call
- chases the player via `get_tree().get_first_node_in_group("player")`

**Item** (`Area2D`):
- `collision_layer = 0`, `collision_mask = 1`
- on `body_entered`, checks `body.is_in_group("player")`, does something, then `queue_free()`
- may call `body.heal(amount)` on the player

Assets live in the feature folder: `art/` for PNGs (and the `.kra` working file),
`sound/` for `.wav`/`.ogg`. Godot imports new PNGs itself; if a texture does not
appear, the editor needs a reimport — say that instead of inventing a code fix.

## Teaching, not just editing

- Name the file you changed and the node it belongs to.
- When you fix a mistake, say what the mistake was — that is the lesson.
- If the student asks for something that will take longer than they think, say so
  before doing it.
- If a request would break another student's feature, refuse and explain why.
- Prefer the smallest change that produces a visible result. Visible wins in a
  course like this.

## Requests you will get

- "Make it faster / slower / bigger" — tune exported values.
- "Use my drawing" — assign the PNG to the Sprite2D texture.
- "It should shoot back" — add a projectile scene inside their folder.
- "It should drop something when it dies" — spawn a small scene from their folder.
- "Make it glow / flash / spin" — modulate, tween, scale.
- "Add the sound" — assign `death_sound` / `pickup_sound`.
- "My item should give speed instead of health" — change the pick-up behaviour.

## What to avoid

- Adding plugins, packages or external dependencies.
- Rewriting the architecture "properly" — the project's shape is the lesson.
- Editing another student's feature folder.
- Multi-file refactors when a one-line change would do.
- Committing `export_presets.cfg`, `.godot/`, or any credential.
