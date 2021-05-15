static class Solver {

	//Contains all of the functions related to solving a board
	//functions are designed to take a double int array as input

	//backtracking algorithm to complete fill a given board
	//(solution will not necessarily be unique)
	//assumes cells only have values 0-9
	public static boolean fillBoard(int[][] b, int pos) {
		//b will never be copied
		//we'll just undo any bad moves we make

		//take care of terminal case first
		if (pos >= 81) return true;

		int c = pos % 9;
		int r = pos / 9;

		//if this cell is already full, just call recursively again with pos incremented
		if (b[r][c] != 0) {
			return fillBoard(b, pos + 1);
		}

		//randomize which moves we try first so that we get new boards each time
		int valueList[] = {1, 2, 3, 4, 5, 6, 7, 8, 9};
		shuffleList(valueList);

		for(int i = 0; i < 9; ++i) {
			//if the next valud is legal to play, play it
			if(checkValid(b, valueList[i], r, c)) {
				b[r][c] = valueList[i];
				//recursively call this function with the updated board, and increment pos
				if (fillBoard(b, pos + 1)) {
					//if the recursive call returned true, that means we got all the way to the final position and successfully placed a piece
					return true;
				}
				else {
					//if the call returned false, that means this last piece we played led to a board with no solution
					//un-play that move, then try the next value in this same square
					b[r][c] = 0;
				}
			}
		}
		//if we get here, then none of the possible values for this cell led to a solution, meaning this board has no solutions
		return false;
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
};