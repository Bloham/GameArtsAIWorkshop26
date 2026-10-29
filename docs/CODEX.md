# Working with Codex in this project

Codex is your coding agent. It can read the project, edit scripts and scenes, and
explain what it did — but it only knows what you tell it and what it can find in
the repo.

## Start it correctly

Open your terminal **in the project folder** (the one with `project.godot`) and
start Codex there. If you start it in your home folder, it cannot see the game.

First message, every session:

> Read AGENTS.md and PROJECT_OVERVIEW.md. Then explain how the feature system
> works and where my feature folder is. Don't change anything.

That one message saves you twenty minutes of confusion. Codex reads `AGENTS.md`
automatically, which is why the file is written the way it is.

---

## How to ask for a change

**One change per message.** The agent is fast; your ability to check its work is
the bottleneck.

A good request has three parts: **where**, **what**, **how you'll know**.

> In `features/yourname-thing/your_thing.gd`, make the enemy move twice as fast.
> I'll know it worked when it reaches me in about a second instead of two.

A bad request:

> make it better

### Prompts that work well

- "Read the script and tell me what it does, in plain language, before changing anything."
- "Make the enemy flash red when it takes damage, and nothing else."
- "My sprite is at `features/my-thing/art/my_thing.png` — put it on the Sprite node."
- "It should drop a coin when it dies. Add the coin scene inside my feature folder."
- "This error appeared: *[paste it]*. Explain it before you fix it."

### Prompts that waste your time

- Several unrelated changes in one message — you can't tell which one broke it.
- "Rewrite it properly" — it will, and then nothing works and you can't explain why.
- Asking it to edit `game.gd` or another student's folder. It should refuse. Let it.

---

## Testing — the part students skip

- **F6** runs only your scene. Fast loop, use it constantly.
- **F5** runs the whole game. This is the real test.
- **Items cannot be tested with F6** — there is no player in the scene, so
  nothing happens. Register your item and test with F5.

After every accepted change, press F6 (or F5 for items) **before** asking for the
next thing. A chain of five unchecked changes is impossible to untangle.

---

## When it breaks

1. **Read the error.** The first line names the file and the line number.
2. **Paste the error to Codex** and ask it to explain before fixing.
3. **Undo** if the fix makes it worse: `Ctrl+Z` in the editor, or
   `git checkout -- .` in the terminal to throw away uncommitted changes.
4. **If the game won't start at all**, remove your line from
   `features/enemies.txt` / `items.txt`. The game runs again, and you can keep
   working on your scene alone.

Nothing you do here is unrecoverable. Commit when something works — a commit is a
save point you can always return to.

---

## What Codex is not

It is not a substitute for looking at your game. It cannot see the screen, judge
whether the feature is *fun*, or notice that your enemy is invisible because the
sprite has a white background. Those judgements are yours, and they are the ones
being assessed.

When the agent gives you something that runs but feels wrong, say so and describe
what you see. That skill — noticing, then describing precisely — is the actual
subject of this course.
