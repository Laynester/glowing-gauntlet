class_name MazeGeneration

func newMaze(width, height):
    var MAZEX = int(width)
    var MAZEY = int(height)

    var maze = _createEmptyMaze(MAZEX, MAZEY)
    _populateWalls(maze, MAZEX, MAZEY)
    _ensureConnectivity(maze, MAZEX, MAZEY)
    _setEdgeWalls(maze, MAZEX, MAZEY)

    return maze

func _createEmptyMaze(width, height):
    var maze = []
    for i in range(height):
        var row = []
        for j in range(width):
            row.append("x")
        maze.append(row)
    return maze

func _populateWalls(maze, width, height):
    var area = width * height
    var pathtiles = area / 2

    for i in range(int(pathtiles)):
        var randx = randi() % width
        var randy = randi() % height
        maze[randy][randx] = "x"

func _ensureConnectivity(maze, width, height):
    var hasblocks = true
    while hasblocks:
        hasblocks = false
        for y in range(1, height - 1):
            for x in range(1, width - 1):
                var blockCount = _countBlocks(maze, x, y)
                if blockCount == 0:
                    _makePath(maze, x, y)
                    hasblocks = true
                elif blockCount == 4:
                    _makeWall(maze, x, y)
                    hasblocks = true
                elif maze[y][x] == "o":
                    var pathCount = _countPathsAround(maze, x, y)
                    if pathCount <= 1:
                        _makePathToWall(maze, x, y)

func _countBlocks(maze, x, y):
    var blockCount = 0
    if maze[y][x] == "o":
        blockCount += 1
    if maze[y - 1][x] == "o":
        blockCount += 1
    if maze[y][x - 1] == "o":
        blockCount += 1
    if maze[y - 1][x - 1] == "o":
        blockCount += 1
    return blockCount

func _makePath(maze, x, y):
    var del = randi() % 4
    match del:
        0:
            maze[y][x] = "o"
        1:
            maze[y - 1][x] = "o"
        2:
            maze[y][x - 1] = "o"
        3:
            maze[y - 1][x - 1] = "o"

func _makeWall(maze, x, y):
    var del = randi() % 4
    match del:
        0:
            maze[y][x] = "x"
        1:
            maze[y - 1][x] = "x"
        2:
            maze[y][x - 1] = "x"
        3:
            maze[y - 1][x - 1] = "x"

func _countPathsAround(maze, x, y):
    var pathCount = 0
    if maze[y + 1][x] == "o":
        pathCount += 1
    if maze[y - 1][x] == "o":
        pathCount += 1
    if maze[y][x - 1] == "o":
        pathCount += 1
    if maze[y][x + 1] == "o":
        pathCount += 1
    return pathCount

func _makePathToWall(maze, x, y):
    var del = randi() % 4
    match del:
        0:
            if maze[y + 1][x] == "x":
                maze[y + 1][x] = "o"
            else:
                maze[y - 1][x] = "o"
        1:
            if maze[y - 1][x] == "x":
                maze[y - 1][x] = "o"
            else:
                maze[y + 1][x] = "o"
        2:
            if maze[y][x + 1] == "x":
                maze[y][x + 1] = "o"
            else:
                maze[y][x - 1] = "o"
        3:
            if maze[y][x - 1] == "x":
                maze[y][x - 1] = "o"
            else:
                maze[y][x + 1] = "o"

func _setEdgeWalls(maze, width, height):
    for i in range(width):
        maze[0][i] = "x"
        maze[height - 1][i] = "x"
    for i in range(height):
        maze[i][0] = "x"
        maze[i][width - 1] = "x"