import java.awt.AWTException;
import java.awt.Rectangle;
import java.awt.Robot;
import java.util.ArrayList;
import java.util.Collections;
import processing.core.PApplet;

//when in doubt, consult the Processsing reference: https://processing.org/reference/

//int margin = 200; //set the margin around the squares

int xmargin = 600;
int ymargin = 300;
final int padding = 50; // padding between buttons and also their width/height
final int buttonSize = 40; // padding between buttons and also their width/height
ArrayList<Integer> trials = new ArrayList<Integer>(); //contains the order of buttons that activate in the test
int trialNum = 0; //the current trial number (indexes into trials array above)
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
int hits = 0; //number of successful clicks
int misses = 0; //number of missed clicks
Robot robot; //initalized in setup 
boolean firstTime = true;
Integer previousTrial = null;
Integer thisTrial = null;
Integer nextTrial = null;


int numRepeats = 1; //sets the number of times each button repeats in the test

void setup()
{
  trialNum = 0; //the current trial number (indexes into trials array above)
  startTime = 0; // time starts when the first click is captured
  finishTime = 0; //records the time of the final click
  hits = 0; //number of successful clicks
  misses = 0; //number of missed clicks
  //size(700, 700); // set the size of the window
  fullScreen();
  //noCursor(); //hides the system cursor if you want
  noStroke(); //turn off all strokes, we're just using fills here (can change this if you want)
  textFont(createFont("Arial", 16)); //sets the font to Arial size 16
  textAlign(CENTER);
  frameRate(60);
  ellipseMode(CENTER); //ellipses are drawn from the center (BUT RECTANGLES ARE NOT!)
  //rectMode(CENTER); //enabling will break the scaffold code, but you might find it easier to work with centered rects

  try {
    robot = new Robot(); //create a "Java Robot" class that can move the system cursor
  } 
  catch (AWTException e) {
    e.printStackTrace();
  }

  //===DON'T MODIFY MY RANDOM ORDERING CODE==
  for (int i = 0; i < 16; i++) //generate list of targets and randomize the order
      // number of buttons in 4x4 grid
    for (int k = 0; k < numRepeats; k++)
      // number of times each button repeats
      trials.add(i);

  Collections.shuffle(trials); // randomize the order of the buttons
  System.out.println("trial order: " + trials);
  
  frame.setLocation(0,0); // put window in top left corner of screen (doesn't always work)
}


void draw()
{
  background(0); //set background to black
  if(firstTime){
    drawInstruction();
  }
  else{
    drawPlay(); 
  }

}
void drawInstruction()
{
    fill(255); //set fill color to white
    text("Follow the red square by hovering over the box and pressing the spacebar!", width / 2, height / 2);
  
}

void drawPlay()
{
  if (trialNum >= trials.size()) //check to see if test is over
  {
    float timeTaken = (finishTime-startTime) / 1000f;
    float penalty = constrain(((95f-((float)hits*100f/(float)(hits+misses)))*.2f),0,100);
    fill(255); //set fill color to white
    //write to screen (not console)
    text("Finished!", width / 2, height / 2); 
    text("Hits: " + hits, width / 2, height / 2 + 20);
    text("Misses: " + misses, width / 2, height / 2 + 40);
    text("Accuracy: " + (float)hits*100f/(float)(hits+misses) +"%", width / 2, height / 2 + 60);
    text("Total time taken: " + timeTaken + " sec", width / 2, height / 2 + 80);
    text("Average time for each button: " + nf((timeTaken)/(float)(hits+misses),0,3) + " sec", width / 2, height / 2 + 100);
    text("Average time for each button + penalty: " + nf(((timeTaken)/(float)(hits+misses) + penalty),0,3) + " sec", width / 2, height / 2 + 140);
    return; //return, nothing else to do now test is over
  }

  fill(255); //set fill color to white
  text((trialNum + 1) + " of " + trials.size(), 40, 20); //display what trial the user is on
  
  /*
  for (int i = 0; i < 16; i++) {
    Rectangle bounds = getButtonLocation(trials.get(i));
    
    //check to see if mouse cursor is inside a button
    if ((mouseX > bounds.x && mouseX < bounds.x + bounds.width) && (mouseY > bounds.y && mouseY < bounds.y + bounds.height)) 
    {
      drawBorder(i); 
    } 
  }
  */
  
  for (int i = 0; i < 16; i++)// for all button
    drawButton(i); //draw button

  //fill(255, 0, 0, 200); // set fill color to translucent red
  //ellipse(mouseX, mouseY, 20, 20); //draw user cursor as a circle with a diameter of 20
  
  drawLine();
}

void mousePressed() // test to see if hit was in target!
{
  
  if(firstTime){
     firstTime = false;
     return;
  }
  
  if (trialNum >= trials.size()){ //if task is over, just return
    setup();
    return;
  }

  if (trialNum == 0) //check if first click, if so, start timer
  {  println("starting timer");
    startTime = millis();
  }
  
  if (trialNum == trials.size() - 1) //check if final click
  {
    finishTime = millis();
    //write to terminal some output. Useful for debugging too.
    println("we're done!");
  }

  Rectangle bounds = getButtonLocation(trials.get(trialNum));

 //check to see if mouse cursor is inside button 
  if ((mouseX > bounds.x && mouseX < bounds.x + bounds.width) && (mouseY > bounds.y && mouseY < bounds.y + bounds.height)) // test to see if hit was within bounds
  {
    System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success
    hits++; 
  } 
  else
  {
    System.out.println("MISSED! " + trialNum + " " + (millis() - startTime)); // fail
    misses++;
  }

  trialNum++; //Increment trial number

  //in this example code, we move the mouse back to the middle
  //robot.mouseMove(width/2, (height)/2); //on click, move cursor to roughly center of window!
}  

//probably shouldn't have to edit this method
Rectangle getButtonLocation(int i) //for a given button ID, what is its location and size
{
   int x = (i % 4) * (padding + buttonSize) + xmargin;
   int y = (i / 4) * (padding + buttonSize) + ymargin;
   return new Rectangle(x, y, buttonSize, buttonSize);
}

//you can edit this method to change how buttons appear
void drawButton(int i)
{
  
  Rectangle bounds = getButtonLocation(i);
  //Rectangle predicted_bounds = getButtonLocation(i);
  if(trialNum<(trials.size() - 1)) {
    if (trials.get(trialNum) == i) { // see if current button is the target 
      fill(255, 0, 0); // if so, fill red
      thisTrial = i;
    }
    else if (trials.get(trialNum + 1) == i) { // see if the button is the next button 
      //fill(40);
      //rect(bounds.x-10, bounds.y-10, bounds.width+20, bounds.height+20); //draw button
      fill(75);
      nextTrial = i;
    }
    else {
      fill(75); // if not, fill gray
    }
      
    if (trialNum >= 1) {
      if (trials.get(trialNum - 1) == i) { // see if the button is the last button 
        previousTrial = i;
      }
    }
  }
  else {
    if (trials.get(trialNum) == i) {// see if current button is the target
      fill(255, 0, 0); // if so, fill red
    }
    else {
      fill(75); // if not, fill gray
    }
  }
      
  rect(bounds.x, bounds.y, bounds.width, bounds.height); //draw button
  //rect(predicted_bounds.x, predicted_bounds.y, predicted_bounds.width, predicted_bounds.height); //draw button
  
}

void drawLine() {
  Rectangle thisBounds = getButtonLocation(thisTrial);
  Rectangle nextBounds = getButtonLocation(nextTrial);
  Rectangle previousBounds = null;
  if (previousTrial != null) {
    previousBounds= getButtonLocation(previousTrial);
  }
  
  stroke(153,75);
  
  // Current to next
  line(thisBounds.x + 20, thisBounds.y + 20, nextBounds.x + 20, nextBounds.y + 20);
  
  /*
  // Previous to current
  
  if (previousBounds != null) {
    line(previousBounds.x + 20, previousBounds.y + 20, thisBounds.x + 20, thisBounds.y + 20);
  }
  
  // Mouse to current
  line(mouseX, mouseY, thisBounds.x + 20, thisBounds.y + 20);
  */
  
  stroke(0);
}

/*
void drawBorder(int i) {
  
  Rectangle bounds = getButtonLocation(trials.get(i));

    fill(255, 255, 0); // if so, fill yellow
    rect(bounds.x - 5, bounds.y - 5, bounds.width + 10, bounds.height + 10); //draw border
  
}
*/

void mouseMoved()
{
   //can do stuff everytime the mouse is moved (i.e., not clicked)
   //https://processing.org/reference/mouseMoved_.html
   
}

void mouseDragged()
{
  //can do stuff everytime the mouse is dragged
  //https://processing.org/reference/mouseDragged_.html
}

void keyPressed() 
{
  //can use the keyboard if you wish
  //https://processing.org/reference/keyTyped_.html
  //https://processing.org/reference/keyCode.html
  
  if(firstTime){
     firstTime = false;
     return;
  }
  
  if (trialNum >= trials.size()) //if task is over, just return
    return;

  if (trialNum == 0) //check if first click, if so, start timer
    startTime = millis();

  if (trialNum == trials.size() - 1) //check if final click
  {
    finishTime = millis();
    //write to terminal some output. Useful for debugging too.
    println("we're done!");
  }

  Rectangle bounds = getButtonLocation(trials.get(trialNum));

 //check to see if mouse cursor is inside button, increased bounds   
  if ((mouseX > bounds.x-25  && mouseX < bounds.x + bounds.width + 25) && (mouseY > bounds.y - 25 && mouseY < bounds.y + bounds.height + 25)) // test to see if hit was within bounds
  {
    System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success
    hits++; 
  } 
  else
  {
    System.out.println("MISSED! " + trialNum + " " + (millis() - startTime)); // fail
    misses++;
  }

  trialNum++; //Increment trial number

  //in this example code, we move the mouse back to the middle
  //robot.mouseMove(((width)/2), ((height)/2)); //on click, move cursor to roughly center of window!
}