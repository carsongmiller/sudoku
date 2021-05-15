Board board;
int windowMargin = 50;
int cellSize = 100;
color fillColor = color(255, 253, 208);
color fontColor = color(0);
color mouseoverColor = color(200, 198, 158);
boolean ctrlPressed = false;
boolean shiftPressed = false;
boolean altPressed = false;

void setup() {
	size(1000, 1000);
	background(128);
	board = new Board(windowMargin, windowMargin, cellSize);
	frameRate(120);
}

void draw() {
	board.draw(mouseX, mouseY);
}

void mouseClicked() {
	board.mouseClicked(mouseX, mouseY);
}

void keyPressed() {
	if (key == CODED) {
		if (keyCode == CONTROL) {
			ctrlPressed = true;
		}
		if (keyCode == SHIFT) {
			shiftPressed = true;
		}
		if (keyCode == ALT) {
			altPressed = true;
		}
	}

	board.keyPressed(keyCode, ctrlPressed);

	if (key == 'h') {
		board.printHouseSelected();
	}

	if (key == 'w') {
		println(Solver.checkWin(board.getArrayGrid()));
	}

	if (key == 'p') {
		board.simplePrint();
	}

	if (key == 's') {
		board.setFromString("368947512192568347754213986483179265627835491519624873875391624231486759946752138");
	}

	if (key == 'g') {
		// String strBoard = "295743861431865900876192543387459216612387495549216738763534189928671354154938600";
		String strBoard = Solver.gridToString(board.getArrayGrid());


		int[][] b = Solver.stringToGrid(strBoard);
		List<String> solutions = new ArrayList<String>();
		Solver.solve(b, 0, solutions, 1000);
		if (solutions.size() > 0) {
			println(solutions.size());
			for (int i = 0; i < solutions.size(); ++i) {
				println(solutions.get(i));
			}
			board.setFromString(solutions.get(0));
		}
		else {
			println("Generation unsuccessful :(");
		}
	}

	//Ctrl + c
	if (keyCode == 67 && ctrlPressed) {
		board.clear();
	}

	//Ctrl + y
	if (keyCode == 89 && ctrlPressed) {
		board.redo();
		println("redo");
	}

	//Ctrl + z
	if (keyCode == 90 && ctrlPressed) {
		board.undo();
		println("undo");
	}

	//Ctrl + h
	if (keyCode == 72 && ctrlPressed) {
		board.printHistory();
	}
}

void keyReleased() {
	if (key == CODED) {
		if (keyCode == CONTROL) {
			ctrlPressed = false;
		}
		if (keyCode == SHIFT) {
			shiftPressed = false;
		}
		if (keyCode == ALT) {
			altPressed = false;
		}
	}
}

float textHeight() {
	return textAscent()+textDescent();  
}

void printArray(int[][] a) {
	int len1 = a.length;
	int len2 = a[0].length;

	for (int r = 0; r < len1; ++r) {
		for (int c = 0; c < len2; ++c) {
			print(a[r][c]);
		}
		println();
	}
}