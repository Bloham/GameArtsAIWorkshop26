extends Node2D

const PINE_TREE_SCENE := preload("res://trees/pine_tree.tscn")
const HALF_WIDTH := 1600.0
const HALF_HEIGHT := 1000.0
const TREE_SPACING := 80.0


func _ready() -> void:
	var trees_per_horizontal_edge := int(HALF_WIDTH * 2.0 / TREE_SPACING)
	for index in range(trees_per_horizontal_edge + 1):
		var x := -HALF_WIDTH + index * TREE_SPACING
		_add_border_tree(Vector2(x, -HALF_HEIGHT), PI)
		_add_border_tree(Vector2(x, HALF_HEIGHT), 0.0)

	var trees_per_vertical_edge := int(HALF_HEIGHT * 2.0 / TREE_SPACING)
	for index in range(1, trees_per_vertical_edge):
		var y := -HALF_HEIGHT + index * TREE_SPACING
		_add_border_tree(Vector2(-HALF_WIDTH, y), PI / 2.0)
		_add_border_tree(Vector2(HALF_WIDTH, y), -PI / 2.0)


func _add_border_tree(at_position: Vector2, facing: float) -> void:
	var tree := PINE_TREE_SCENE.instantiate() as Node2D
	tree.position = at_position
	tree.rotation = facing
	add_child(tree)
