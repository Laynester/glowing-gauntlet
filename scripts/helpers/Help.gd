extends Node2D

func hexToColor(hex: String, alpha: int = 1) -> Color:
	if hex.begins_with("#"):
		hex = hex.substr(1, hex.length())

	var r = hex.substr(0, 2).hex_to_int() / 255.0
	var g = hex.substr(2, 2).hex_to_int() / 255.0
	var b = hex.substr(4, 2).hex_to_int() / 255.0
	
	return Color(r, g, b, alpha)

func distanceBetween(astar: AStarGrid2D, one: Vector2i, two: Vector2i) -> int:
	return astar.get_id_path(one, two).size()