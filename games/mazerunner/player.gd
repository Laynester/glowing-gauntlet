extends Node2D

@onready var player: Node2D = $Player

signal moved
signal firstWalk

const SPEED = 300
var map: TileMap
var isMoving = false

var parent

var hasWalked = false

func _ready():
	parent = get_parent()

func _physics_process(_delta):
	if isMoving == false: return
	
	if global_position == player.global_position:
		isMoving = false
		return
		
	player.global_position = player.global_position.move_toward(global_position, SPEED * _delta)
	createGhosting()
	
func _process(_delta):
	moveCamera()
	if isMoving || parent.timerClock.is_stopped(): return
	
	if Input.is_action_pressed("move_up"):
		move(Vector2.UP)
	elif Input.is_action_pressed("move_down"):
		move(Vector2.DOWN)
	elif Input.is_action_pressed("move_left"):
		move(Vector2.LEFT)
	elif Input.is_action_pressed("move_right"):
		move(Vector2.RIGHT)

func moveCamera():
	var playerx =  player.global_position.x
	var playery =  player.global_position.y
	var camera = parent.get_node("Camera")

	camera.position.x = playerx
	camera.position.y = playery

	Main.game().moveAudio(camera.position)

func move(dir: Vector2):
	if !hasWalked:
		hasWalked = true
		firstWalk.emit()

	var curTile: Vector2i = map.local_to_map(global_position)
	var targTile: Vector2i = Vector2i(
		curTile.x + dir.x,
		curTile.y + dir.y
	)
	
	var tileData: TileData = map.get_cell_tile_data(parent.PATH_LAYER, targTile)
	
	if !tileData: return
	
	isMoving = true
	global_position = map.map_to_local(targTile)

	player.global_position = map.map_to_local(curTile)


func setMap(localMap: TileMap):
	map = localMap;
	moveCamera()

func setPosition(coords, zI):
	self.z_index = zI
	self.position = coords

func createGhosting():
	var trail = Sprite2D.new()
	trail.texture = player.get_node("PlayerSprite").texture
	trail.global_position = player.global_position
	trail.z_index = 3
	parent.add_child(trail)
	
	var tween = get_tree().create_tween()
	tween.tween_property(trail, "scale", Vector2(0,0), 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(trail.queue_free)

func _on_player_area_entered(area: Area2D):
	if area.is_in_group("ruby"):
		parent.removeRuby(area.position)
		area.queue_free()
		parent.addScore(1)

	if area.is_in_group("enemy"):
		parent.die()

	if area.is_in_group("boomtube"):
		parent.enterTube()
		area.queue_free()

