import java.awt.HeadlessException;
import java.awt.Toolkit;
import java.awt.datatransfer.DataFlavor;
import java.awt.datatransfer.UnsupportedFlavorException;
import java.io.IOException;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.Transferable;


public abstract class Control {
	//Position
	protected int top, left = 0;
	protected int width, height = 100;

	//Colors (with defaults)
	protected color c_bgEnabled = color(255);
	protected color c_bgDisabled = color(180);
	protected color c_textEnabled = color(0);
	protected color c_textDisabled = color(0);
	protected color c_borderUnfocused = color(0);
	protected color c_borderFocused = color(0);

	//Selection
	boolean focused = false;
	boolean enabled = true;

	public void display() {
		int borderWeight = focused ? 2 : 1;
		stroke(focused ? c_borderFocused : c_borderUnfocused); //rectangle border
		strokeWeight(borderWeight);
 		fill(enabled ? c_bgEnabled : c_bgDisabled); //rectangle color
		rect(left, top, width, height);
	}

	public void mousePressed() {
	}

	public void mouseReleased() {
		if (mouseIsOver()) focused = true;
		else focused = false;
	}
	
	public boolean mouseIsOver() {
		if (mouseX > left && mouseX < (left + width) && mouseY > top && mouseY < (top + height)) {
			return true;
		}
		return false;
	}
}

class TextBox extends Control{
	public boolean multiLine = false;
	public int margin = 5;
	public int limit = 1000;

	private boolean ctrlPressed, shiftPressed, altPressed = false;

	//text
	public String text = "";
	public int textSize = 20;
	public int justify = LEFT;
	public int useHeight = height;

	//blinking cursor
	private Stopwatch blinkSW = new Stopwatch();
	private boolean showCursor = false;
	final private char cursor = '|';

	TextBox(int left, int top, int width, int height) {
		super();

		this.left = left;
		this.top = top;
		this.width = width;
		this.height = height;
	}

	@Override
	void display() {
		int borderWeight = focused ? 2 : 1;
		useHeight = multiLine ? height : textSize + (2 * margin) + (2 * borderWeight);

		//draw rectangle
		stroke(focused ? c_borderFocused : c_borderUnfocused); //rectangle border
		strokeWeight(borderWeight);
 		fill(enabled ? c_bgEnabled : c_bgDisabled); //rectangle color
		rect(left, top, width, useHeight);

		//draw text
		fill(enabled ? c_textEnabled : c_textDisabled); //text color
		textSize(textSize);
		textAlign(justify);
		updateCursor();
		text(showCursor ? text + cursor : text, left + margin, top + margin, width - (margin * 2), useHeight - (margin * 2) + 2);
	}

	void keyPressed() {
		//update the modifier states even if we're not focused
		if (keyCode == CONTROL) {
			ctrlPressed = true;
			return;
		}
		else if (keyCode == SHIFT) {
			shiftPressed = true;
			return;
		}
		else if (keyCode == ALT) {
			altPressed = true;
			return;
		}

		if (focused) {
			final int len = text.length();

			//if we're focused, we don't want anything else in the program to use these keystrokes
			char k = key;
			int kc = keyCode;
			key = 0;
			keyCode = 0;

			if (k == ESC) {
				focused = false;
				return;
			}
			if (k == BACKSPACE) {
				text = text.substring(0, max(0, len-1));
			}

			else if (len >= limit) return;
			//========================================================
			//anything that may add length goes below here
			//========================================================

			else if (k == ENTER || k == RETURN) {
				text += "\n";
			}
			else if (k == TAB) { //currently doesn't appear to do anything
				text += "\t";
			}
			else if (ctrlPressed && kc == 86) { //ctrl + v
				Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
				//odd: the Object param of getContents is not currently used
				Transferable contents = clipboard.getContents(null);
				boolean hasTransferableText = (contents != null) && contents.isDataFlavorSupported(DataFlavor.stringFlavor);
				try {
					String clipboardStr = (String)contents.getTransferData(DataFlavor.stringFlavor);
					text += clipboardStr;
				}
				catch (UnsupportedFlavorException ex){
					println(ex);
					ex.printStackTrace();
				}
				catch (IOException ex){/*do nothing*/}
				return;
			}
			else if (k >= ' ') text += str(k);
		}
	}

	private void updateCursor() {
		if (!focused) showCursor = false;
		else {
			if (blinkSW.elapsed() > 500) {
				showCursor = !showCursor;
				blinkSW.clear();
			}
		}
	}

	@Override
	public boolean mouseIsOver() {
		if (mouseX > left && mouseX < (left + width) && mouseY > top && mouseY < (top + useHeight)) {
			return true;
		}
		return false;
	}
}

class Button extends Control{
	String text;
	boolean pressed = false;
	int textSize = 20;
	color c_bgPressed = color(150);
	
	public Button(String text, int left, int top, int width, int height) {
		super();

		this.text = text;
		this.left = left;
		this.top = top;
		this.width = width;
		this.height = height;

		c_bgEnabled = 200;
		c_textDisabled = 150;
	}

	@Override
	public void display() {
		int borderWeight = focused ? 2 : 1;

		//draw rectangle
		stroke(focused ? c_borderFocused : c_borderUnfocused); //rectangle border
		strokeWeight(borderWeight);
 		fill(enabled ? (pressed ? c_bgPressed : c_bgEnabled) : c_bgDisabled); //rectangle color
		rect(left, top, width, height);

		//draw the text on our own
		textSize(textSize);
		fill(enabled ? c_textEnabled : c_textDisabled);
		drawTextCentered(text, textSize, left, top, width, height);
	}

	@Override
	public void mousePressed() {
		super.mousePressed();
		if (mouseIsOver()) {
			pressed = true;
		}
	}

	@Override
	public void mouseReleased() {
		super.mouseReleased();
		//we only register a mouse click if the mouse was on the button while pressing and releasing
		if (mouseIsOver() && pressed) mouseClicked();

		if (pressed) pressed = false;
	}

	private void mouseClicked() {
		println("clicked");
	}
};

public class Stopwatch { 

	private long start;
	private boolean running = true;

	public Stopwatch() {
		start = System.currentTimeMillis();
		running = true;
	}

	public void clear() {
		start = System.currentTimeMillis();
	}
	
	public void stop() {
		running = false;
	}

	public void start() {
		running = true;
		clear();
	}

	//Returns the elapsed CPU time (in seconds) since the stopwatch was created.
	public long elapsed() {
		return running ? System.currentTimeMillis() - start : 0;
	}
};

//draws text centered in the given box
public void drawTextCentered(String str, int size, int l, int t, int w, int h) {
	textSize(size);
	textAlign(CENTER, TOP);
	text(str, l + (w / 2), t - textHeight()/2 + h/2);
}