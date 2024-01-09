extends Area2D

@onready var sprite = $Enemy
@onready var light: Light2D = $Light
@onready var sound: AudioStreamPlayer2D = $Sounds

var parent
var astar: AStarGrid2D

var path: Array[Vector2i]

func _ready():
	parent = get_parent()
	astar = parent.astar
	light.color = Help.hexToColor("f74242")

func reset(tile: Vector2):
	path.clear()
	astar = parent.astar
	global_position = tile


func _process(_delta):
	if !parent.isGameRunning():
		sound.stop()
		return

	checkDistance()

	if path.is_empty():
		getRandomPath()
		return

func _physics_process(delta):
	if path.is_empty() || !parent.isGameRunning(): return

	var map = parent.get_node("TileMap")
	var target = map.map_to_local(path.front())

	global_position = global_position.move_toward(target, 150 * delta)
	createGhosting()

	if global_position == target:
		path.pop_front()
		parent.spawnRuby(target.x, target.y)

func getRandomPath():
	var curTile = parent.get_node("TileMap").local_to_map(global_position)

	path = astar.get_id_path(
		curTile,
		parent.randomTile(parent.PATH_LAYER, Vector2i(parent.PATH_TILE, 0))
	)

func createGhosting():
	var trail = Sprite2D.new()
	trail.texture = sprite.texture
	trail.global_position = global_position
	trail.z_index = 3
	parent.add_child(trail)
	trail.scale = scale
	
	var tween = get_tree().create_tween()
	tween.tween_property(trail, "scale", Vector2(0,0), 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(trail.queue_free)

func checkDistance():
	var character = parent.get_node("CHARACTER")
	var distance = Help.distanceBetween(astar,
		parent.get_node("TileMap").local_to_map(global_position),
		parent.get_node("TileMap").local_to_map(character.global_position)
	)

	var tween = get_tree().create_tween()

	if(distance >= 8):
		tween.tween_property(self, "scale", Vector2(0,0), 0.5).set_trans(Tween.TRANS_LINEAR)
	else: 
		tween.tween_property(self, "scale", Vector2(1,1), 0.5).set_trans(Tween.TRANS_LINEAR)
	
