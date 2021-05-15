class Cell {
	private boolean notes[] = new boolean[9];
	private int value = 0;

	//Fonts
	private color c_fill;
	private color c_font;
	private color c_ErrorFont;
	private color c_noteFont;
	private color c_mouseover;
	private color c_selected;
	private color c_houseSelected;
	
	private int size, top, left;
	private float _valueFontScaler = 0.75;
	private float _noteFontScaler = 0.2;
	private float _noteOuterPaddingTop = 0.05;
	private float _noteOuterPaddingSide = 0.08;
	private boolean isMouseover = false;
	private boolean selected = false;
	private boolean houseSelected = false;
	private boolean error = false; //cell is redundant to another cell in the same house


	public Cell(int v, int l, int t, int s, color fillC, color fontC, color mouseC, color selectedC, color houseC, color noteFontC, color errorFontC) {
		if (v >= 0 && v <= 9) {
			value = v;
		}
		else {
			value = 0;
		}
		c_fill = fillC;
		c_font = fontC;
		c_mouseover = mouseC;
		c_selected = selectedC;
		c_houseSelected = houseC;
		c_noteFont = noteFontC;
		c_ErrorFont = errorFontC;
		size = s;
		left = l;
		top = t;
	}

	//deep copy constructor
	// public Cell(Cell that) {
	// 	Cell(that.value, that.left, that.top, that.size, that.c_fill, that.c_font, that.c_mouseover, that.c_selected, that.c_houseSelected, that.c_noteFont, that.c_ErrorFont);
	// }

	public void draw(int mX, int mY) {
		checkMouseover(mX, mY);
		if (selected) { //first priority
			fill(c_selected);
		}
		else if (isMouseover) { //second priority
			fill(c_mouseover);
		}
		else if (houseSelected) { //third priority
			fill(c_houseSelected);
		}
		else { //last priority
			fill(c_fill);
		}
		stroke(5);
		strokeWeight(1);
		rect(left, top, size, size);
		
		if (value >= 1 && value <= 9) {
			//if this cell is an error, color it differently
			if (error) {
				fill(c_ErrorFont);
			}
			else {
				fill(c_font);
			}
			textSize(size * _valueFontScaler);
			textAlign(CENTER, TOP);
			text(value, left + (size / 2), top - textHeight()/2 + size/2);
		}
		else {
			drawNotes();
		}
	}

	private void drawNotes() {
		for (int r = 0; r < 3; ++r) {
			for (int c = 0; c < 3; ++c) {
				
				if (notes[(r * 3) + c]) {
					fill(c_font);
					textSize(size * _noteFontScaler);
					int horAlign, vertAlign = 0;

					//calculate left shifts
					int leftShift, topShift = 0;
					if (c == 0) {
						leftShift = int(size * _noteOuterPaddingSide);
						horAlign = LEFT;
					}
					else if (c == 1) {
						leftShift = int(size / 2);
						horAlign = CENTER;
					}
					else {
						leftShift = int(size - (size * _noteOuterPaddingSide));
						horAlign = RIGHT;
					}

					//calculate top shifts
					if (r == 0) {
						topShift = int(size * _noteOuterPaddingTop);
						vertAlign = TOP;
					}
					else if (r == 1) {
						topShift = int(size / 2 - textHeight() / 2);
						vertAlign = TOP;
					}
					else if (r == 2) {
						topShift = int(size - (size * _noteOuterPaddingTop));
						vertAlign = BOTTOM;
					}

					textAlign(horAlign, vertAlign);
					
					text((r * 3) + c + 1, left + leftShift, top + topShift);
				}
			}
		}
	}

	public void addNote(int n) {
		if (n >= 1 && n <= 9) {
			notes[n-1] = true;
		}
	}

	public void clearNote(int n) {
		if (n >= 1 && n <= 9) {
			notes[n-1] = false;
		}
	}

	public void allAllNotes() {
		for (int i = 1; i <= 9; ++i) {
			notes[i-1] = true;
		}
	}

	public void clearAllNotes() {
		for (int i = 1; i <= 9; ++i) {
			notes[i-1] = false;
		}
	}

	public boolean hasNote(int n) {
		if (n >= 1 && n <= 9) {
			if (notes[n-1]) return true;
			else return false;
		}
		else {
			return false;
		}
	}

	public void clear() {
		clearAllNotes();
		setValue(0);
		clearError();
	}

	public void setValue(int v) {
		if (v >= 0 && v <= 9) { //0 = blank
			value = v;
			clearAllNotes();
			if (value == 0) clearError();
		}
	}

	public int getValue() {
		return value;
	}

	public int size() {
		return size;
	}

	public int left() {
		return left;
	}

	public int top() {
		return top;
	}

	private float textHeight() {
		return textAscent()+textDescent();  
	}

	private void checkMouseover(int mX, int mY) {
		if (mX > left && mX < (left + size) && mY > top && mY < (top + size)) {
			isMouseover = true;
		}
		else {
			isMouseover = false;
		}
	}

	public void select() {
		selected = true;
	}

	public void clearSelection() {
		selected = false;
		houseSelected = false;
	}

	public boolean isSelected() {
		return selected;
	}

	public void houseSelected() {
		houseSelected = true;
	}

	public boolean isHouseSelected() {
		return houseSelected;
	}

	public void setError() {
		error = true;
	}

	public void clearError() {
		error = false;
	}
};