class_name GameStorage

var totalRubies = 0
var scores = []

func loadData():
	var file = FileAccess.open("user://saved_game.json", FileAccess.READ)

	if file:
		var contents = file.get_as_text()
		var json = JSON.new()
		var result = json.parse(contents)

		print(contents)

		if result == OK:
			var data = json.get_data()

			if data.has("totalRubies"):
				totalRubies = data["totalRubies"]

func saveGame():
	var file = FileAccess.open("user://saved_game.json", FileAccess.WRITE)

	if file:
		var data = JSON.stringify({
			"totalRubies": totalRubies
		})

		file.store_line(data)