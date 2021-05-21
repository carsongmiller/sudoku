import controlP5.*;


Board board;
int windowMargin = 50;
int cellSize = 100;
color fillColor = color(255, 253, 208);
color fontColor = color(0);
color mouseoverColor = color(200, 198, 158);
boolean ctrlPressed = false;
boolean shiftPressed = false;
boolean altPressed = false;


ControlP5 cp5;
Textarea myTextarea;

//=========================
//Controls
//=========================

//Buttons
Button btn1;

//Text Boxes
TextBox tb, tb2;

//Text Boxes

void setup() {
	size(1500, 1000);
	
	board = new Board(windowMargin, windowMargin, cellSize);
	frameRate(120);
	
	tb = new TextBox(1100, 100, 200, 100);
	tb2 = new TextBox(1100, 225, 200, 100);
	btn1 = new Button("test", 1100, 400, 100, 50);

	cp5 = new ControlP5(this);

	myTextarea = cp5.addTextarea("txt")
					.setPosition(100,100)
					.setSize(200,200)
					.setFont(createFont("arial",20))
					.setLineHeight(14)
					.setColor(color(128))
					.setColorBackground(color(255))
					.setColorForeground(color(255,100));
					;
	myTextarea.setText("Lorem Ipsum is simply dummy text of the printing and typesetting"
					+" industry. Lorem Ipsum has been the industry's standard dummy text"
					+" ever since the 1500s, when an unknown printer took a galley of type"
					+" and scrambled it to make a type specimen book. It has survived not"
					+" only five centuries, but also the leap into electronic typesetting,"
					+" remaining essentially unchanged. It was popularised in the 1960s"
					+" with the release of Letraset sheets containing Lorem Ipsum passages,"
					+" and more recently with desktop publishing software like Aldus"
					+" PageMaker including versions of Lorem Ipsum."
					);

	cp5.addSlider("changeWidth")
		.setRange(100,400)
		.setValue(200)
		.setPosition(100,20)
		.setSize(100,19)
		;
	

	cp5.addSlider("changeHeight")
		.setRange(100,400)
		.setValue(200)
		.setPosition(100,40)
		.setSize(100,90)
		;
}


void draw() {
	clear();
	background(128);
	//Draw the board
	//board.draw(mouseX, mouseY);

	tb.display();
	tb2.display();
	btn1.display();

	if(keyPressed && key==' ') {
		myTextarea.scroll((float)mouseX/(float)width);
	}
	if(keyPressed && key=='l') {
		myTextarea.setLineHeight(mouseY);
	}
}

void changeWidth(int theValue) {	
	myTextarea.setWidth(theValue);
}

void changeHeight(int theValue) {
	myTextarea.setHeight(theValue);
}

void mousePressed() {
	tb.mousePressed();
	tb2.mousePressed();
	btn1.mousePressed();
}

void mouseReleased() {
	board.mouseClicked(mouseX, mouseY);

	tb.mouseReleased();
	tb2.mouseReleased();
	btn1.mouseReleased();
}

void keyPressed() {
if(key=='r') {
	myTextarea.setText("Lorem ipsum dolor sit amet, consectetur adipiscing elit."
						+" Quisque sed velit nec eros scelerisque adipiscing vitae eu sem."
						+" Quisque malesuada interdum lectus. Pellentesque pellentesque molestie"
						+" vestibulum. Maecenas ultricies, neque at porttitor lacinia, tellus enim"
						+" suscipit tortor, ut dapibus orci lorem non ipsum. Mauris ut velit velit."
						+" Fusce at purus in augue semper tincidunt imperdiet sit amet eros."
						+" Vestibulum nunc diam, fringilla vitae tristique ut, viverra ut felis."
						+" Proin aliquet turpis ornare leo aliquam dapibus. Integer dui nisi, condimentum"
						+" ut sagittis non, fringilla vestibulum sapien. Sed ullamcorper libero et massa"
						+" congue in facilisis mauris lobortis. Fusce cursus risus sit amet leo imperdiet"
						+" lacinia faucibus turpis tempus. Pellentesque pellentesque augue sed purus varius"
						+" sed volutpat dui rhoncus. Lorem ipsum dolor sit amet, consectetur adipiscing elit"
						);
						
	} else if(key=='c') {
		myTextarea.setColor(0xffffffff);
	}

	tb.keyPressed();
	tb2.keyPressed();

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

	//=========================
	//Game Hotkeys
	//=========================

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