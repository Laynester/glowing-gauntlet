extends NinePatchRect

signal timeOut

var my_timer
var time = 0

func addTime():
	time += 1
	setTime()

func setTime():
	var minutes = time / 60
	var seconds = time % 60

	$Time.text = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)

func getTime() -> String:
	return $Time.text
