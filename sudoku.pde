import javax.swing.*;
import java.awt.event.*;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.Dimension;


Board board;
int windowMargin = 50;
int cellSize = 100;
color fillColor = color(255, 253, 208);
color fontColor = color(0);
color mouseoverColor = color(200, 198, 158);
boolean ctrlPressed = false;
boolean shiftPressed = false;
boolean altPressed = false;


JFrame f = new JFrame("Button Example");  
JButton b = new JButton("Click Here");



//=========================
//Controls
//=========================

//Buttons
List<Button> btnList = new ArrayList<Button>();
Button btn1 = new Button("test", 1100, 100, 100, 50);

//Text Boxes
TextBox tb, tb2;

//Text Boxes

void setup() {
	size(1500, 1000);
	background(128);
	board = new Board(windowMargin, windowMargin, cellSize);
	frameRate(120);
	
	tb = new TextBox(1100, 100, 200, 100);
	tb2 = new TextBox(1100, 225, 200, 100);
}


void draw() {
	//Draw the board
	board.draw(mouseX, mouseY);

	tb.display();
	tb2.display();

	//Draw all the controls
	for (Button b : btnList) {
		b.draw();
	}
}

void mouseClicked() {
	board.mouseClicked(mouseX, mouseY);

	if (tb.checkFocus()) tb.focused = true;
	else tb.focused = false;

	if (tb2.checkFocus()) tb2.focused = true;
	else tb2.focused = false;
}

void keyPressed() {
	tb.tKeyTyped();
	tb2.tKeyTyped();

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
		Solver.solve(b, 0, solutions, 1);
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