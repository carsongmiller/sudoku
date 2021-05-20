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
	protected color c_borderFocused = color (255, 0, 0);

	//Selection
	boolean focused = false;
	boolean enabled = true;
}

class TextBox extends Control{
	public int margin = 5;
	public int limit = 1000;

	private boolean ctrlPressed, shiftPressed, altPressed = false;

	//text
	public String text = "";
	public int textSize = 20;
	public int justify = LEFT;

	//blinking cursor
	private Stopwatch blinkSW = new Stopwatch();
	private boolean showCursor = false;
 
	TextBox(int left, int top, int width, int height) {
		super();
 
		this.left = left;
		this.top = top;
		this.width = width;
		this.height = height;
	}
 
	void display() {
		stroke(focused ? c_borderFocused : c_borderUnfocused); //rectangle border
		strokeWeight(2);
 		fill(enabled ? c_bgEnabled : c_bgDisabled); //rectangle color
		rect(left, top, width, height);
 
		fill(enabled ? c_textEnabled : c_textDisabled); //text color
		textSize(textSize);
		textAlign(justify);
		updateCursor();
		text(showCursor ? text + "_" : text, left + margin, top + margin, width - (margin * 2), height - (margin * 2));
	}
 
	void tKeyTyped() {
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
			return;
		}

		if (focused) {
			//if we're focuses, we don't want anything else in the program to use these keystrokes
			char k = key;
			int kc = keyCode;
			key = 0;
			keyCode = 0;
 
			if (k == ESC) {
				focused = false;
				k = 0;
				return;
			} 
	
			if (ctrlPressed && kc == 86) { //ctrl + v
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
	
			final int len = text.length();
	
			if (k == BACKSPACE) text = text.substring(0, max(0, len-1));
			else if (len >= limit) return;
			else if (k == ENTER || k == RETURN) text += "\n";
			else if (k == TAB) text += "\t";
			else if (k >= ' ') text += str(k);
		}
	}
 
 
	void tKeyPressed() {
		if (focused) {
			if (key == ESC) {
				println("esc 3");
				//state=stateNormal;
				//key=0;
			}
	
			if (key != CODED)	return;
	
			final int k = keyCode;
	
			final int len = text.length();
	
			if (k == LEFT) text = text.substring(0, max(0, len-1));
			else if (k == RIGHT & len < limit - 3) text += "  ";
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
 
	boolean checkFocus() {
		return focused = mouseX > left & mouseX < (left + width) & mouseY > top & mouseY < (top + height);
	}
}

class Button {
	String label;
	float x; // top left corner x position
	float y; // top left corner y position
	float w; // width of button
	float h; // height of button
	
	public Button(String labelB, float xpos, float ypos, float widthB, float heightB) {
		label = labelB;
		x = xpos;
		y = ypos;
		w = widthB;
		h = heightB;
	}
	
	public void draw() {
		fill(218);
		stroke(141);
		rect(x, y, w, h, 10);
		textAlign(CENTER, CENTER);
		fill(0);
		text(label, x + (w / 2), y + (h / 2));
	}
	
	public boolean mouseIsOver() {
		if (mouseX > x && mouseX < (x + w) && mouseY > y && mouseY < (y + h)) {
			return true;
		}
		return false;
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