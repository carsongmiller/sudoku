import java.util.List;
import java.util.Collections;
import java.util.Arrays;

class Board {
	private Cell grid[][] = new Cell[9][9];
	private color c_fill = color(255, 253, 208);
	private color c_font = color(0);
	private color c_ErrorFont = color(180, 0, 0);
	private color c_noteFont = color(30, 30, 30);
	private color c_mouseover = color(180, 180, 140);
	private color c_selected = color(250, 250, 240);
	private color c_houseSelected = color(210, 210, 170);
	private int cellSize, top, left;

	//grid history controllers
	private List<Cell[][]> gridHistory = new ArrayList<Cell[][]>();
	private int historyPlace = 0;

	public Board(int l, int t, int cs, color fillC, color fontC, color mouseC) {
		left = l;
		top = t;
		cellSize = cs;
		c_fill = fillC;
		c_font = fontC;
		c_mouseover = mouseC;

		for (int r = 0; r < 9; ++r) {
			for (int c = 0; c < 9; ++c) {
				grid[r][c] = new Cell(0, left + (cellSize * c), top + (cellSize * r), cellSize,
				c_fill, c_font, c_mouseover, c_selected, c_houseSelected, c_noteFont, c_ErrorFont);
			}
		}
	}

	public Board(int l, int t, int cs) {
		left = l;
		top = t;
		cellSize = cs;

		for (int r = 0; r < 9; ++r) {
			for (int c = 0; c < 9; ++c) {
				grid[r][c] = new Cell(0, left + (cellSize * c), top + (cellSize * r), cellSize,
				c_fill, c_font, c_mouseover, c_selected, c_houseSelected, c_noteFont, c_ErrorFont);
			}
		}
	}

	public void setCell(int r, int c, int v) {
		if (v >= 0 && v < 9) {
			grid[r][c].setValue(v);
		}
	}

	public void draw(int mX, int mY) {
		for (int r = 0; r < 9; ++r) {
			for (int c = 0; c < 9; ++c) {
				grid[r][c].draw(mX, mY);
			}
		}

		strokeWeight(3);
		noFill();
		rect(left, top, cellSize * 9, cellSize * 9); //outside
		line(left, top + cellSize * 3, left + cellSize * 9, top + cellSize * 3); //top horizontal
		line(left, top + cellSize * 6, left + cellSize * 9, top + cellSize * 6); //bottom horizontal
		line(left + cellSize * 3, top, left + cellSize * 3, top + cellSize * 9); //left vertical
		line(left + cellSize * 6, top, left + cellSize * 6, top + cellSize * 9); //right vertical
	}

	public void clear() {
		for (int r = 0; r < 9; ++r) {
			for (int c = 0; c < 9; ++c) {
				grid[r][c].clear();
			}
		}
	}

	public Cell[][] getGrid() {
		return grid;
	}

	public void mouseClicked(int mX, int mY) {
		clearAllCellSelection();

		//see if we're within a cell
		boolean found = false;
		int r, c = 0;
		for (r = 0; r < 9; ++r) {
			for (c = 0; c < 9; ++c) {
				int tempS = grid[r][c].size();
				int tempL = grid[r][c].left();
				int tempT = grid[r][c].top();
				if (mX > tempL && mX < (tempL + tempS) && mY > tempT && mY < (tempT + tempS)) {
					found = true;
					break;
				}
			}
			if (found) break;
		}

		if (found) {
			grid[r][c].select();
			setAllHouseMemberSelected(r, c);
		}
	}

	private void setAllHouseMemberSelected(int r, int c) {
		ArrayList<PVector> members = Solver.getHouseMembers(r, c);
		for (PVector m : members) {
			grid[int(m.x)][int(m.y)].houseSelected();
		}
	}

	private void clearAllCellSelection() {
		for (int r = 0; r < 9; ++r) {
			for (int c = 0; c < 9; ++c) {
				grid[r][c].clearSelection();
			}
		}
	}

	//k = keyCode
	public void keyPressed(int k, boolean ctrl) {
		boolean ctrlPressed = false;
		if (k >= 48 && k <= 57) { //ASCII 1-9
			k -= 48;
			for (int r = 0; r < 9; ++r) {
				for (int c = 0; c < 9; ++c) {
					if (grid[r][c].isSelected()) {
						if (ctrl) {
							cellNewNote(r, c, k);
						}
						else {
							cellNewValue(r, c, k);
						}

						//add this new grid to history athe front
						Cell bCopy[][] = new Cell[9][9];
						for (int x = 0; x < 9; ++x) {
							for (int y = 0; y < 9; ++y) {
								bCopy[x][y] = grid[x][y];
							}
						}
						gridHistory.add(0, bCopy);
					}
				}
			}
		}
		//arrow keys
		if (k == UP || k == DOWN || k == LEFT || k == RIGHT) {
			//if nothing has been selected yet, select 0,0
			boolean selectedFound = false;
			for (int r = 0; r < 9; ++r) {
				for (int c = 0; c < 9; ++c) {
					if (grid[r][c].isSelected()) selectedFound = true;
				}
			}
			if (selectedFound) {
				if(k == UP) {
					moveSelectionUp();
				}
				else if(k == DOWN) {
					moveSelectionDown();
				}
				else if(k == LEFT) {
					moveSelectionLeft();
				}
				else if(k == RIGHT) {
					moveSelectionRight();
				}
			}
			else {
				grid[0][0].select();
				setAllHouseMemberSelected(0, 0);
			}
		}
		
		
	}

	private void cellNewValue(int r, int c, int v) {
		//if cell already has value v, clear it
		if (grid[r][c].getValue() == v || v == 0) {
			grid[r][c].clear();
		}
		else {
			grid[r][c].setValue(v);
			grid[r][c].clearError();
			//if value was an error, color it differently
			ArrayList<PVector> members = Solver.getHouseMembers(r, c);
			for (PVector m : members) {
				if (grid[int(m.x)][int(m.y)].getValue() == v) {
					grid[r][c].setError();
					break;
				}
			}

			removeInvalidNotes(r, c, v);
		}

		if (Solver.checkWin(getArrayGrid())) println("Winner!");
	}

	//remove all now-invalid notes in the same house as the cell that was just filled
	private void removeInvalidNotes(int r, int c, int v) {
		ArrayList<PVector> members = Solver.getHouseMembers(r, c);
		for(PVector m : members) {
			if (grid[int(m.x)][int(m.y)].hasNote(v)) grid[int(m.x)][int(m.y)].clearNote(v);
		}
	}

	private void cellNewNote(int r, int c, int n) {
		if (grid[r][c].hasNote(n)) {
			grid[r][c].clearNote(n);
		}
		else {
			grid[r][c].addNote(n);
		}
	}

	private void moveSelectionUp() {
		for (int r = 0; r < 9; ++r) {
			for (int c = 0; c < 9; ++c) {
				if (grid[r][c].isSelected()) {
					clearAllCellSelection();
					int newR = r - 1;
					if (newR < 0) newR = 8;

					grid[newR][c].select();
					setAllHouseMemberSelected(newR, c);
					return;
				}
			}
		}
	}

	private void moveSelectionDown() {
		for (int r = 0; r < 9; ++r) {
			for (int c = 0; c < 9; ++c) {
				if (grid[r][c].isSelected()) {
					clearAllCellSelection();
					int newR = r + 1;
					if (newR > 8) newR = 0;

					grid[newR][c].select();
					setAllHouseMemberSelected(newR, c);
					return;
				}
			}
		}
	}

	private void moveSelectionLeft() {
		for (int r = 0; r < 9; ++r) {
			for (int c = 0; c < 9; ++c) {
				if (grid[r][c].isSelected()) {
					clearAllCellSelection();
					int newC = c - 1;
					if (newC < 0) newC = 8;

					grid[r][newC].select();
					setAllHouseMemberSelected(r, newC);
					return;
				}
			}
		}
	}

	private void moveSelectionRight() {
		for (int r = 0; r < 9; ++r) {
			for (int c = 0; c < 9; ++c) {
				if (grid[r][c].isSelected()) {
					clearAllCellSelection();
					int newC = c + 1;
					if (newC > 8) newC = 0;

					grid[r][newC].select();
					setAllHouseMemberSelected(r, newC);
					return;
				}
			}
		}
	}

	//prints grid to the console
	public void printGrid() {
		for (int r = 0; r < 9; ++r) {
			if (r % 3 == 0) {
				println("+---------+---------+---------+");
			}
			for (int c = 0; c < 9; ++c) {
				if (c % 3 == 0) {
					print("|");
				}
				print(" " + grid[r][c].value + " ");
			}
			println("|");
		}
		println("+---------+---------+---------+");
	}

	//prints grid to the console (overloaded for simple array grid)
	public void printGrid(int[][] b) {
		for (int r = 0; r < 9; ++r) {
			if (r % 3 == 0) {
				println("+---------+---------+---------+");
			}
			for (int c = 0; c < 9; ++c) {
				if (c % 3 == 0) {
					print("|");
				}
				print(" " + b[r][c] + " ");
			}
			println("|");
		}
		println("+---------+---------+---------+");
	}

	//prints houseSelected data of grid to the console
	public void printHouseSelected() {
		for (int r = 0; r < 9; ++r) {
			if (r % 3 == 0) {
				println("+---------+---------+---------+");
			}
			for (int c = 0; c < 9; ++c) {
				if (c % 3 == 0) {
					print("|");
				}
				if (grid[r][c].isHouseSelected()) {
					print(" X ");
				}
				else {
					print(" O ");
				}
				
			}
			println("|");
		}
		println("+---------+---------+---------+");
	}

	//prints grid as a simple string
	public void simplePrint() {
		String str = "";
		for (int r = 0; r < 9; ++r) {
			for (int c = 0; c < 9; ++c) {
				str += grid[r][c].getValue();
			}
		}
		println(str);
	}

	public void simplePrint(Cell b[][]) {
		String str = "";
		for (int r = 0; r < 9; ++r) {
			for (int c = 0; c < 9; ++c) {
				str += b[r][c].getValue();
			}
		}
		println(str);
	}

	

	//ignores anything other than 0-9
	//if string doesn't contain 81x 0-9 char's, we fill the rest with 0's
	//If there are too many char's, we truncate
	public void setFromString(String str) {
		String trimmed = "";
		int count = 0;
		for (int i = 0; i < str.length(); i++){
			char c = str.charAt(i);
			if (c >= '0' && c <= '9') {
				trimmed += c;
				count += 1;
				if (count >= 81) break;
			}
		}

		if (trimmed.length() < 81) {
			int l = trimmed.length();
			for (int i = 0; i < (81 - l); ++i) {
				trimmed += '0';
			}
		}

		for (int r = 0; r < 9; ++r) {
			for (int c = 0; c < 9; ++c) {
				grid[r][c].setValue(int(trimmed.charAt((r * 9) + c)) - 48);
			}
		}
	}


	public void undo() {
		if (historyPlace + 1 < gridHistory.size()) {
		historyPlace += 1;
		grid = gridHistory.get(historyPlace);
		}
	}

	public void redo() {
		if (historyPlace - 1 >= 0) {
			historyPlace -= 1;
			grid = gridHistory.get(historyPlace);
		}
	}

	public void printHistory() {
		for (Cell[][] b : gridHistory) {
			simplePrint(b);
		}
	}

	//returns an int array of the grid
	private int[][] getArrayGrid() {
		int[][] simple = new int[9][9];
		for (int r = 0; r < 9; ++r) {
			for (int c = 0; c < 9; ++c) {
				simple[r][c] = grid[r][c].getValue();
			}
		}
		return simple;
	}
};