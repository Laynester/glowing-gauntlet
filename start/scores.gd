extends CanvasLayer

@onready var scoreGrid = $Panel/Container/ScoreScroll/VBox/Scores

var fakers = []

func _ready():
	setupScores("ticks")

func setupScores(key: String):
	var scores = Main.Storage.scores

	sortArrayOfDictsByValue(scores, key)

	for faker in fakers:
		faker.queue_free()

	fakers = []

	for score in scores:
		generateForScore(score)

func generateForScore(score):
	var board = scoreGrid.duplicate()
	board.show()

	board.get_node("time").text = str(score["ticks"])
	board.get_node("enemies").text = str(score["enemies"])
	board.get_node("rubies").text = str(score["rubies"])
	board.get_node("rounds").text = str(score["rounds"])

	fakers.append(board)

	$Panel/Container/ScoreScroll/VBox.add_child(board)

func sortArrayOfDictsByValue(array, key):
	var sortMe = func(a, b) -> int:
		return a[key] > b[key]

	array.sort_custom(sortMe)

func _on_button_pressed():
	queue_free()

func _on_time_pressed():
	setupScores("ticks")

func _on_enemies_pressed():
	setupScores("enemies")

func _on_rubies_pressed():
	setupScores("rubies")

func _on_rounds_pressed():
	setupScores("rounds")
