class_name GameStorage

var totalRubies = 0
var scores = []

func loadData():
	var file = FileAccess.open("user://saved_game.json", FileAccess.READ)

	if file:
		var contents = file.get_as_text()
		var json = JSON.new()
		var result = json.parse(contents)

		if result == OK:
			var data = json.get_data()

			if data.has("totalRubies"):
				totalRubies = data["totalRubies"]
			
			if data.has("scores"):
				scores = data["scores"]

func saveGame():
	var file = FileAccess.open("user://saved_game.json", FileAccess.WRITE)

	if file:
		var data = JSON.stringify({
			"totalRubies": totalRubies,
			"scores": scores
		})

		file.store_line(data)

func addHighscore(ticks: int, rubies: int, enemies: int, rounds: int):
	scores.append({
		"ticks": ticks,
		"rubies": rubies,
		"enemies": enemies,
		"rounds": rounds
	})
	saveGame()