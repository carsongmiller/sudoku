static class Solver {

	//Contains all of the functions related to solving a board
	//functions are designed to take a double int array as input
	//designed for standard 9x9 sudoku grids only

	//backtracking algorithm to solutions to a given board
	//if board contains a number that is not 0-9, will return 0
	//randomizes order in which values are tried to obtain varied solutions

	//g = grid
	//pos = position at which to start search
	//solutions = list of found solutions
	//count = 
	//max = max # of solutions to find
	public static void solve(int[][] g, int pos, List<String> solutions, int max) {
		//b will never be copied
		//we'll just undo any bad moves we make

		//take care of terminal case first
		//we're only filling valid values, so if grid is full, we have a solution
		if (gridFull(g)) {
			solutions.add(gridToString(g));
			return;
		}

		pos %= 81;
		int c = pos % 9;
		int r = pos / 9;
		
		if (g[r][c] < 0 || g[r][c] > 9) {
			//cell has an invalid number in it (not 0-9)
			return;
		}
		if (g[r][c] != 0) {
			//cell is already valid. Just call recursively again with pos incremented
			solve(g, pos + 1, solutions, max);
		}

		//randomize which moves we try first so that we get new boards each time
		int valueList[] = {1, 2, 3, 4, 5, 6, 7, 8, 9};
		shuffleList(valueList);

		for(int i = 0; i < 9; ++i) {
			//if the next valud is legal to play, play it
			if(checkValid(g, valueList[i], r, c)) {
				g[r][c] = valueList[i];
				//recursively call this function with the updated board, and increment pos
				solve(g, pos + 1, solutions, max);
				g[r][c] = 0;

				if (solutions.size() >= max) return;
			}
		}

		return;
	}


	public static boolean checkValid(Cell[][] b, int v, int r, int c) {
		//if cell is populated, automatically not valid
		if (b[r][c].getValue() != 0) return false;

		ArrayList<PVector> members = getHouseMembers(r, c);
		for (PVector m : members) {
			if (b[int(m.x)][int(m.y)].getValue() == v) return false;
		}
		return true;
	}

	//overloaded to take a simlpe array board
	public static boolean checkValid(int[][] b, int v, int r, int c) {
		//if cell is populated, automatically not valid
		if (b[r][c] != 0) return false;

		ArrayList<PVector> members = getHouseMembers(r, c);
		for (PVector m : members) {
			if (b[int(m.x)][int(m.y)] == v) return false;
		}
		return true;
	}

	public static void shuffleList(int[] l) {
		Integer integerArray[] = new Integer[l.length];
		for (int i = 0; i < l.length; ++i) {
			integerArray[i] = l[i];
		}
		List<Integer> intList = Arrays.asList(integerArray);
		Collections.shuffle(intList);
		intList.toArray(integerArray);

		for (int i = 0; i < l.length; ++i) {
			l[i] = integerArray[i];
		}
	}


	public static boolean checkWin(int[][] b) {
		boolean error = false;
		for (int r = 0; r < 9; ++r) {
			for (int c = 0; c < 9; ++c) {
				int v = b[r][c];
				if (v == 0) return false; //if we've got a blank value we don't have a win

				//check all other members of the same house to make sure they're different
				ArrayList<PVector> members = getHouseMembers(r, c);
				for(PVector m : members) {
					if (b[int(m.x)][int(m.y)] == v) {
						return false;
					}
				}
			}
		}
		return true;
	}

	//get all cells in the same house
	public static ArrayList<PVector> getHouseMembers(int r, int c) {
		ArrayList<PVector> members = new ArrayList<PVector>();

		//column
		for (int y = 0; y < 9; ++y) {
			if (y != r) {
				members.add(new PVector(y, c));
			}
		}

		//row
		for (int x = 0; x < 9; ++x) {
			if (x != c) {
				members.add(new PVector(r, x));
			}
		}

		//box
		int boxR[] = new int[3];
		int boxC[] = new int[3];
		//find R's
		if (r >= 0 && r <= 2) {
			boxR[0] = 0;
			boxR[1] = 1;
			boxR[2] = 2;
		}
		else if (r >= 3 && r <= 5) {
			boxR[0] = 3;
			boxR[1] = 4;
			boxR[2] = 5;
		}
		else {
			boxR[0] = 6;
			boxR[1] = 7;
			boxR[2] = 8;
		}
		//find C's
		if (c >= 0 && c <= 2) {
			boxC[0] = 0;
			boxC[1] = 1;
			boxC[2] = 2;
		}
		else if (c >= 3 && c <= 5) {
			boxC[0] = 3;
			boxC[1] = 4;
			boxC[2] = 5;
		}
		else {
			boxC[0] = 6;
			boxC[1] = 7;
			boxC[2] = 8;
		}

		for (int x = 0; x < 3; ++x) {
			for (int y = 0; y < 3; ++y) {
				if (boxR[x] != r && boxC[y] != c) {
					members.add(new PVector(boxR[x], boxC[y]));
				}
			}
		}
		
		return members;
	}

	public static String gridToString(int[][] g) {
		String str = "";
		for (int r = 0; r < 9; ++r) {
			for (int c = 0; c < 9; ++c) {
				str += g[r][c];
			}
		}
		return str;
	}

	public static int[][] stringToGrid(String str) {
		String trimmed = "";
		int[][] grid = new int[9][9];

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
				grid[r][c] = int(trimmed.charAt((r * 9) + c)) - 48;
			}
		}

		return grid;
	}

	//tells whether a grid is full of numbers 1-9 or not
	//will return false if any cell has non 1-9 in it
	private static boolean gridFull(int[][] g) {
		for (int r = 0; r < 9; ++r) {
			for (int c = 0; c < 9; ++c) {
				if (g[r][c] < 1 || g[r][c] > 9) return false;
			}
		}
		return true;
	}
};