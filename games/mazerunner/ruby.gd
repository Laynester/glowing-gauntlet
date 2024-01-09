extends Area2D

var parent

func _ready():
	parent = get_parent().get_parent()
	scale = Vector2(0.0, 0.0)

func scaleUp():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.0,1.0), 0.2).set_trans(Tween.TRANS_LINEAR)

func scaleDown():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(0.0,0.0), 0.2).set_trans(Tween.TRANS_LINEAR)

func _process(_delta):
	checkDistance()

func checkDistance():
	var character = parent.get_node("CHARACTER")
	var distance = Help.distanceBetween(parent.astar,
		parent.get_node("TileMap").local_to_map(global_position),
		parent.get_node("TileMap").local_to_map(character.global_position)
	)
	
	if(distance >= 5): scaleDown()
	elif distance >= 8: scale = Vector2(0.0, 0.0)
	else: scaleUp()
