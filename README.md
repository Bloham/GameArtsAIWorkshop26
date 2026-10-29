# Game Arts — AI Workshop 2026

Your project for the AI workshop at Novia. The game in this repository already
runs. Your job is to make one part of it **yours**, using an AI coding agent to
do the typing.

**You own one feature, from beginning to end** — the art, the sound, the code,
and getting it into the game. Nineteen of you, nineteen features, one game.

---

## What you need

- **Godot 4.7** — [godotengine.org/download](https://godotengine.org/download)
- **Codex**, installed on your machine (you get it through NOVIA — see [docs/CODEX.md](docs/CODEX.md))
- **Git** or [GitHub Desktop](https://desktop.github.com)
- **Krita** (installed) or [Photopea](https://www.photopea.com) in the browser
- [bfxr.net](https://www.bfxr.net) for sound, or your phone to record

---

## Setup — five minutes

```bash
git clone https://github.com/Bloham/GameArtsAIWorkshop26.git
cd GameArtsAIWorkshop26
```

Open the folder in Godot (Project Manager → Import → `project.godot`) and press
**F5**. You should be shooting slimes within a minute.

Then start Codex **in this folder** and say:

> Read AGENTS.md and PROJECT_OVERVIEW.md, then summarise how this project is
> structured. Don't change anything yet.

If it describes the feature system back to you correctly, your setup is good.

---

## Your job

1. **Claim a feature** — see [docs/roster.md](docs/roster.md). Put your GitHub handle next to a free number, choose enemy or item, and commit that line.
2. **Copy the template** into a folder with your name.
3. **Draw it** — digitally. Krita or Photopea, 512×512, transparent background.
4. **Give it a sound** — record it, or generate one in bfxr.
5. **Build it** with Codex, one request at a time, and test with **F6**.
6. **Register it** — one line in `features/enemies.txt` or `features/items.txt`.
7. **Press F5.** Your feature spawns in the game. That is the finish line.

Step-by-step detail, sizes and naming: **[features/README.md](features/README.md)**.

---

## What "done" means

**What is in the build and playable is what counts.** Not a drawing in your
folder, not a script in the editor, not a branch nobody merged. Registered and
running in the game is done.

This is also how the course is assessed: the feature that works beats the
ambitious one that doesn't.

---

## How the project fits together

```
project.godot            the Godot project — open this
survivors_game.tscn      main scene: player, spawner, game over
player.gd / mob.gd       player controller, enemy chase AI
gun.gd / bullet_2d.gd    auto-aim weapon, projectile
game.gd                  spawner + game-over logic

features/
  enemies.txt            ← register your enemy here
  items.txt              ← register your item here
  library.gd             the autoload that loads registered features
  _template/enemy/       copy this for an enemy
  _template/item/        copy this for an item
  yourname-thing/        your feature lives here, and only yours

docs/roster.md           who owns which feature
docs/CODEX.md            how to work with your agent
AGENTS.md                the agent reads this automatically
PROJECT_OVERVIEW.md      scene tree, scripts, collision layers
```

The game asks `FeatureLibrary` for a random enemy or item when it spawns
something. `FeatureLibrary` reads those two text files. That is the whole
integration — nobody edits a shared scene, which is why nineteen of you can work
at the same time.

---

## Working with others

- **Always `git pull` before you start**, and again before you open a Pull Request.
- **Stay in your folder.** `game.gd`, `player.gd` and `features/library.gd` are shared wiring that everyone depends on.
- **Never edit or delete another student's folder.**
- **Conflict on `enemies.txt`?** Keep both lines — that file is almost impossible to break.
- **Never commit `.godot/`, `export_presets.cfg`, or a password.** This repository is public.

---

## Getting help

- Ask Codex first, but give it the error message, not "it doesn't work".
- Ask Ben when the agent and you are both stuck, or when you want to do something the project doesn't allow yet.
- Questions about the course itself: **benjamin.vehling@novia.fi**

---

## Credits and licence

- Base project built from GDQuest's free course [Your First 2D Game in Godot 4](https://www.gdquest.com/library/first_2d_game_godot4_vampire_survivor/). Graphics by GDQuest, **CC BY 4.0** — see [ATTRIBUTION.md](ATTRIBUTION.md).
- Workshop code and material: **MIT** — see [LICENSE](LICENSE).
- What you make stays **yours**. By pushing it here you agree it can stay in this repository under CC BY 4.0, credited to you in your folder and filenames.
