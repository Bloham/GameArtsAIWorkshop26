# Agent Instructions

You are working in a **Godot 4.7** 2D top-down survival shooter written in
**GDScript**, in a Game Arts course at Novia. The person prompting you is a
**student**, not a programmer — they may be new to Godot and new to git.

`PROJECT_OVERVIEW.md` describes the scenes, scripts and collision layers. Read it
when you need to know how a piece connects.

## How to work

The student decides what to build. You make it happen.

- Change whatever the request actually requires — one file or twenty. There is
  no fixed folder, no fixed order, no prescribed workflow.
- Anything in this project is fair game if the student asks for it. If a change
  touches shared code, say so in one sentence so they know what to test.
- Keep the project runnable. If you cannot verify that it runs, say so plainly
  instead of claiming success.
- Explain in a sentence or two what you changed and where.
- Prefer the smallest change that gives a visible result. Visible wins in a
  classroom.

## Git: pull, commit and push after every change

Everyone in the room shares this repository, live. After each completed change:

```
git pull --rebase
git add -A
git commit -m "short description of what changed"
git push
```

Before you start a change, `git pull --rebase` first.

If the push is rejected: `git pull --rebase`, then push again. Never use
`--force`, never rewrite pushed history. If a conflict cannot be resolved
cleanly, stop and tell the student which files conflict — do not guess at
someone else's work.

Commit messages are one line, in the present tense, describing the change.

Never commit `export_presets.cfg`, `.godot/`, or anything containing a password,
token or key.

## Facts about this project

- **Enemies** are `CharacterBody2D` on collision layer 2. Bullets call
  `take_damage()`. They chase the player via
  `get_tree().get_first_node_in_group("player")`.
- **Items** are `Area2D` with `collision_layer = 0` and `collision_mask = 1`. On
  `body_entered` they check `is_in_group("player")`, apply their effect, then
  `queue_free()`.
- **Registering** a new enemy or item is one line in `features/enemies.txt` or
  `features/items.txt` — a `res://` path per line.
- **Art and sound** live next to the scene that uses them. Godot imports new
  PNGs on its own; if a texture does not appear, that is a reimport issue, not a
  code fix.
- `.godot/` is a local editor cache, not source.

That is the whole brief. Build what the student asks for.
