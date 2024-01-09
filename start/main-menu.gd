extends CanvasLayer

@onready var music: AudioStreamPlayer2D = $Music
@onready var bg  = $UI/Background
@onready var totalRubies = $UI/Rubys/Total
var tween: Tween
var audio: AudioStream
var loop: bool

var curGame: Node2D

func _ready():
	moveAudio(Vector2(0,0))
	tryPlaySound("res://assets/audio/main-loop.mp3")
	tween = get_tree().create_tween()
	tween.tween_property($Black, "modulate", Color(1,1,1,0), 0.7).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback($Black.hide)

	Main.loadData()

	totalRubies.text = str(Main.totalRubies)
	
func _onPlay():
	$Black.show()
	tween = get_tree().create_tween()
	tween.tween_property($Black, "modulate", Color(1,1,1,1), 0.7).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(randomGame)

func gameOver(): 
	show()
	$Black.show()
	tryPlaySound("res://assets/audio/main-loop.mp3")

	if curGame:
		tween = get_tree().create_tween()
		tween.tween_property($Black, "modulate", Color(1,1,1,1), 0.7).set_trans(Tween.TRANS_LINEAR)
		tween.tween_callback(resetGame)

func resetGame():
	curGame.queue_free()
	$UI.show()
	tween = get_tree().create_tween()
	tween.tween_property($Black, "modulate", Color(1,1,1,0), 0.7).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback($Black.hide)
	moveAudio(Vector2(0,0))
	totalRubies.text = str(Main.totalRubies)

	
func randomGame():
	$UI.hide()
	var games = ["MR"]
	var rand = randi() % games.size()
	var game
	
	match games[rand]:
		"MR": 
			game = preload("res://games/mazerunner/MazeRunner.tscn")

	if game:
		var scene = game.instantiate()
		get_parent().get_node("Container").add_child(scene)
		curGame = scene

	if curGame:
		tween = get_tree().create_tween()
		tween.tween_property($Black, "modulate", Color(1,1,1,0), 0.7).set_trans(Tween.TRANS_LINEAR)
		tween.tween_callback(hide)
			

#sound stuff
func startPlaying():
	music.stream = audio
	music.stream.loop = loop
	music.volume_db = -100.0
	music.play()
	tween = get_tree().create_tween()
	tween.tween_property(music, "volume_db", 0.0, 0.6).set_trans(Tween.TRANS_LINEAR)

func tryPlaySound(url: String, localLoop: bool = true):
	audio = load(url)
	self.loop = localLoop
	
	if audio:
		if !localLoop:
			music.stream = audio
			music.play()
		elif music.playing:
			tween = get_tree().create_tween()
			tween.tween_property(music, "volume_db", -100.0, 0.6).set_trans(Tween.TRANS_LINEAR)
			tween.tween_callback(startPlaying)
		else:
			startPlaying()

func moveAudio(pos: Vector2):
	music.position = pos
