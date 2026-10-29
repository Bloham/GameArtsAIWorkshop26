extends Node
## FeatureLibrary — the one place that knows which student features exist.
##
## Every student owns one feature (an enemy or an item). A feature is a scene in
## its own folder under res://features/. This autoload reads the manifest files
## and hands the game a random scene whenever it needs to spawn something, so
## students never edit a shared file to get their work into the game.
##
## Manifests are plain text, one scene path per line. Lines starting with # are
## ignored, so you can leave notes in them:
##
##   res://features/anna-fire-slime/fire_slime.tscn

const ENEMIES_MANIFEST := "res://features/enemies.txt"
const ITEMS_MANIFEST := "res://features/items.txt"
const FALLBACK_ENEMY := "res://mob.tscn"

var enemies: Array[PackedScene] = []
var items: Array[PackedScene] = []


func _ready() -> void:
	enemies = _load_manifest(ENEMIES_MANIFEST)
	items = _load_manifest(ITEMS_MANIFEST)
	print("FeatureLibrary: %d enemy feature(s), %d item feature(s)"
		% [enemies.size(), items.size()])


func _load_manifest(path: String) -> Array[PackedScene]:
	var scenes: Array[PackedScene] = []
	if not FileAccess.file_exists(path):
		push_warning("FeatureLibrary: no manifest at " + path)
		return scenes

	var seen := {}
	for raw_line in FileAccess.get_file_as_string(path).split("\n"):
		var entry := raw_line.strip_edges()
		if entry.is_empty() or entry.begins_with("#") or seen.has(entry):
			continue
		seen[entry] = true

		if not ResourceLoader.exists(entry):
			push_warning("FeatureLibrary: manifest points at a missing scene: " + entry)
			continue

		var packed := load(entry)
		if packed is PackedScene:
			scenes.append(packed)
		else:
			push_warning("FeatureLibrary: not a scene: " + entry)

	return scenes


## A random student enemy, or the original slime if nobody registered one yet.
func random_enemy() -> PackedScene:
	if enemies.is_empty():
		return load(FALLBACK_ENEMY)
	return enemies.pick_random()


## A random student item, or null if no item features are registered.
func random_item() -> PackedScene:
	if items.is_empty():
		return null
	return items.pick_random()
