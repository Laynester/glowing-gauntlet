extends Node2D

const MazeGeneration = preload("res://games/Maze.gd")
@onready var tilemap: TileMap = $TileMap

# Tilemap constants
const WALL_LAYER = 0
const PATH_LAYER = 1

const WALL_TILE = 0
const PATH_TILE = 1

const tileRatio = 60

var WIDTH = 16
var HEIGHT = 16

var rubies = {}

var astar
var timerClock
var ticks = 0
var round = 1
var enemies = []

var gameStarted = false

func _ready():	
	$MRDeath.hide()
	astar = AStarGrid2D.new()
	generate_map()

	var cam = Camera2D.new()
	cam.name = "Camera"
	add_child(cam)
	setupTimer()
	spawnPlayer()

func setupTimer():
	timerClock = Timer.new()
	timerClock.wait_time = 1.0
	timerClock.one_shot = false
	timerClock.autostart = true
	add_child(timerClock)

	timerClock.connect("timeout", timeOut)

func timeOut():
	if !gameStarted: return

	ticks += 1
	$Scoreboard/Clock.addTime()

	if ticks % 30 == 0:
		spawnEnemy()

func generate_map():
	var maze = MazeGeneration.new().newMaze(WIDTH, HEIGHT)
	astar.clear()
	astar.size = Vector2i(WIDTH,HEIGHT)
	astar.cell_size = Vector2i(tileRatio, tileRatio)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()

	var ri = 0;
	for row in maze:
		var ci = 0;
		for col in row:
			if col == "x":
				setTile(ci,ri)
				astar.set_point_solid(Vector2i(ci,ri), true)

			if col == "o":
				tilemap.set_cell(WALL_LAYER, Vector2i(ci, ri), -1)
				tilemap.set_cell(PATH_LAYER, Vector2i(ci, ri), 0, Vector2i(PATH_TILE, 0))
			ci += 1
		ri += 1

	
func setTile(x: int, y: int):
	tilemap.set_cell(WALL_LAYER, Vector2i(x, y), 0, Vector2i(WALL_TILE, 0))
	
func spawnRuby(x: int, y: int):
	var tile = Vector2i(x,y)

	if isRubyAt(tile): return

	var ruby = preload("res://games/mazerunner/ruby.tscn").instantiate()
	ruby.global_position = tile
	ruby.z_index = 5

	$Rubies.add_child(ruby)
	rubies[tile] = ruby

func isRubyAt(pos: Vector2i):
	return pos in rubies
	
func removeRuby(pos: Vector2i):
	var tile = tilemap.local_to_map(pos)
	rubies.erase(tile)

func spawnPlayer():
	var tile = randomTile(PATH_LAYER, Vector2i(PATH_TILE, 0))
	var player = preload("res://games/mazerunner/player.tscn")
	if player:
		var scene = player.instantiate()
		scene.name = "CHARACTER"
		add_child(scene)
		scene.setPosition(tilemap.map_to_local(tile), 1)
		scene.setMap(tilemap)
		scene.connect("firstWalk",onFirstWalk)


func spawnEnemy():
	var tile = randomTile(PATH_LAYER, Vector2i(PATH_TILE, 0))
	var enemy = preload("res://games/mazerunner/MREnemy.tscn")
	if enemy:
		var scene = enemy.instantiate()
		add_child(scene)
		scene.global_position = tilemap.map_to_local(tile)
		scene.z_index = 3
		enemies.append(scene)
		var text = $Scoreboard/Enemies/Counter.text
		$Scoreboard/Enemies/Counter.text = str(enemies.size())

func onFirstWalk():
	spawnEnemy()
	Main.game().tryPlaySound("res://assets/audio/mazerunner.mp3")
	gameStarted = true
	
func randomTile(layerIndex: int, atlas: Vector2i): 
	var tiles = tilemap.get_used_cells_by_id(layerIndex, 0, atlas)
	
	var ind = randi() % tiles.size()
	
	return tiles[ind]
	
func addScore(amount: int):
	var text = $Scoreboard/Rubies/Counter.text
	var newAmount = int(text) + amount
	$Scoreboard/Rubies/Counter.text = str(newAmount)
	if newAmount % 10 == 0:
		boomTube()

	Main.Storage.totalRubies += amount
	Main.Storage.saveGame()

func boomTube():
	if has_node("TUBE"): return

	var tile = randomTile(PATH_LAYER, Vector2i(PATH_TILE, 0))
	var spawn = preload("res://games/mazerunner/MRTube.tscn")

	if spawn:
		var scene = spawn.instantiate()
		scene.name = "TUBE"
		add_child(scene)
		scene.scale = Vector2(0,0)
		scene.global_position = tilemap.map_to_local(tile)
		scene.z_index = 3
		scene.get_node("Light").color = Help.hexToColor("ffea05")
		var tween = get_tree().create_tween()
		tween.tween_property(scene, "scale", Vector2(1,1), 1).set_trans(Tween.TRANS_SINE)

var tempCB
func resetColor():
	WIDTH = WIDTH + 4
	HEIGHT = HEIGHT + 4
	tilemap.clear_layer(WALL_LAYER)
	tilemap.clear_layer(PATH_LAYER)
	generate_map()

	var tile = randomTile(PATH_LAYER, Vector2i(PATH_TILE, 0))

	get_node("CHARACTER").setPosition(tilemap.map_to_local(tile), 1)
	get_node("CHARACTER").setMap(tilemap)

	for enemy in enemies:
		tile = tilemap.map_to_local(randomTile(PATH_LAYER, Vector2i(PATH_TILE, 0)))
		enemy.reset(tile)
	
	for ruby in $Rubies.get_children():
		ruby.queue_free()

	rubies.clear()

	var test = func():
		timerClock.start()
		tempCB.queue_free()

	var tween = get_tree().create_tween()
	tween.tween_property(tempCB, "color", Help.hexToColor("ffea05", 0), 0.3).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(test)

func enterTube():
	timerClock.stop()
	tempCB = ColorRect.new()
	tempCB.color = Help.hexToColor("ffea05", 0)
	tempCB.custom_minimum_size = Main.game().get_viewport_rect().size
	tempCB.position = Vector2(0,0) - (Main.game().get_viewport_rect().size / 2)
	tempCB.z_index = 10
	tempCB.light_mask = 0

	get_node("CHARACTER").add_child(tempCB)

	var tween = get_tree().create_tween()
	tween.tween_property(tempCB, "color", Help.hexToColor("ffea05", 1), 0.3).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(resetColor)

	round += 1

func isGameRunning() -> bool:
	return (gameStarted && !timerClock.is_stopped())

func die():
	timerClock.stop()
	var time = $Scoreboard/Clock.getTime()
	var rubyCount = $Scoreboard/Rubies/Counter.text
	var enemyCount = enemies.size()
	$Scoreboard.hide()
	$MRDeath/texts/message.text = $MRDeath/texts/message.text.replace("%time%", time).replace("%rubies%", str(rubyCount)).replace("%enemies%", str(enemyCount))
	Main.game().tryPlaySound("res://assets/audio/endgame.mp3", false)
	$MRDeath/texts/ok.connect("pressed", gameOver)
	$MRDeath.show()
	Main.Storage.addHighscore(ticks, int(rubyCount), enemyCount, round)

func gameOver(): 
	Main.backToMenu()

