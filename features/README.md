# One feature per person

You own one feature **from beginning to end**: the art, the sound, the code, and
getting it into the game. Nobody else builds it for you, and nobody else has to
touch a file you own.

Pick one:

- **An enemy** — chases the player, can be shot, dies with a sound
- **An item** — a health pack, a coin, a bomb, a speed boost, anything the player walks into

---

## The rule

Nothing is "done" because it works in your own scene. It is done when it runs
**in the game** with the whole group playing. That means registered — see step 4.

---

## Start here: copy a template

```bash
git pull
cp -r features/_template/enemy features/yourname-lava-blob
```

For an item:

```bash
cp -r features/_template/item features/yourname-health-pack
```

Then rename the files inside (`enemy_template.tscn` → `lava_blob.tscn`,
`enemy_template.gd` → `lava_blob.gd`) and change the script path in the scene.

Everything you make lives in **your** folder. That is why nineteen people can
work at the same time without collisions.

---

## 1. Art — digital, no paper

- **Krita** (installed) or **Photopea** (browser, [photopea.com](https://www.photopea.com)) — both free
- New canvas: **512 × 512**, background **transparent** (not white)
- Draw the character **facing right** — the game flips it when needed
- Use layers; save the working file (`.kra` / `.psd`) in `art/` too, so you can reopen it
- Export **PNG** into `features/yourname-thing/art/`

Sizes that work: enemies 256–512 px on the long side, items 64–256 px.

A PNG with a white background shows as a **white box** in the game. Check the
checkerboard pattern before you export.

---

## 2. Sound

Two routes, both fine:

- **Record it** — phone voice memo, a thump on the desk, a squeak. Send it to your PC, keep it short (under 1 second for hits, 2–3 for pickups).
- **Generate it** — [bfxr.net](https://www.bfxr.net) or [jsfxr](https://sfxr.me) in the browser, hit "Export WAV".

Put the file in `features/yourname-thing/sound/`, then drag it onto the
`death_sound` (enemy) or `pickup_sound` (item) field in the Inspector.

---

## 3. Code

1. Open your scene in Godot.
2. Drag your PNG from the FileSystem onto the `Sprite` node's **Texture**.
3. Tune the exported values in the Inspector: `speed`, `health` for enemies;
   `heal_amount` for items.
4. Ask your AI agent for more behaviour — **one request at a time**.
5. Test with **F6** (runs only your scene).

**Items need F5.** Your item only does something when the player walks into it,
and F6 has no player. Register it (step 4) and test in the full game.

Keep these true or your feature won't work in the game:

- Enemy: on **collision layer 2**, has a `take_damage()` function
- Item: **collision mask 1**, does its thing on `body_entered`

---

## 4. Register it — this is how it gets into the game

Open `features/enemies.txt` (or `features/items.txt`) and add **one line** at
the bottom:

```
res://features/yourname-thing/lava_blob.tscn
```

Then press F5. Your enemy now spawns, your item now drops.

That text file is the only shared file you touch. **Add your line, never delete
anyone else's.** If two people edit it at once, Git keeps both lines — it is one
of the few files here that merges cleanly.

---

## 5. Ship it

```bash
git add -A
git commit -m "add lava blob enemy"
git push -u origin code/your-name
```

Open a Pull Request. One feature per PR.

---

## Rules of the road

- **Your folder only.** Don't edit `game.gd`, `player.gd`, or
  `features/library.gd` — those are the shared wiring, and everyone depends on them.
- **Don't rename or delete other people's folders.** Not even the ugly ones.
- **One feature, done deeply.** A simple enemy that works beats an ambitious one that doesn't.
- **Broke the game?** Delete your line from the manifest and say so. The game
  runs fine without you, and you can keep working on the scene.

---

## What a finished feature looks like

```
features/anna-lava-blob/
  lava_blob.tscn        the scene: CharacterBody2D, layer 2, take_damage()
  lava_blob.gd          chasing, health, death sound
  art/lava_blob.png     transparent PNG, 512 px
  art/lava_blob.kra     your working file
  sound/blob-die.wav    short, under 1 s
```

Plus one line in `features/enemies.txt`. That is a complete feature — art,
sound, code, and it spawns in the game.
