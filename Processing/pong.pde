import oscP5.*;
import netP5.*;

//initialize global osc object
OscP5 osc_obj;
NetAddress local;

//Paddle globals
int paddle1X, paddle1Y, paddle2X, paddle2Y;
int paddleWidth = 10;
int paddleHeight = 50;
int paddleSpeed = 10;

//ball globals
int ballX, ballY;            //coordinates of the pong ball
float ball_speed = 1;         //direction and speed of the pong ball
int speedX = (int)ball_speed;
int speedY = (int)ball_speed;
int ballSize = 10;           //pixel width/height of the pong ball
int init_ballX, init_ballY;  //initial
int last_point = 0;          //0 for right player, 1 for left player

void setup() {
  size(400, 400);    //set window size
  background(0);    //set background colour to black
  
  //Setup OSC message receiving on port 8000
  osc_obj = new OscP5(this, 8000);  //create an osc object to listen on port 8000
  
  //setup OSC message sending on port 9000
  local = new NetAddress("127.0.0.1",9000);

  //set initial paddle position
  paddle1X = 0;
  paddle1Y = height/2;
  paddle2X = width-paddleWidth-1;
  paddle2Y = height/2;
  
  //set initial ball position
  ballX = width/2+5;
  ballY = height/2+5;

  //set frames per second
  frameRate(30);

  //do not start draw function automatically
  noLoop();
}

void draw () {
  background(0);  //reset background to black on each iteration of draw
  drawInterface();     //draw dotted line down center of screen
  paddlePosition();    //make the paddles follow the ball
  drawPaddles();       //redraw paddles every frame

  //draw pong ball
  fill(255);
  ellipse(ballX, ballY, ballSize, ballSize);

  ballSpeed(ball_speed);    //set ball speed every frame
  ellipseBounce();      //reverse direction when ball hits surface
  
  //send quadrant-based position of ball out via OSC
  OscMessage quadrant = new OscMessage("/1/quadrant");
  quadrant.add(gridLayout(ballX, ballY));
  osc_obj.send(quadrant,local);
}

//receive messages from the iPad
void oscEvent(OscMessage inMessage) {
  
  //store incoming message pattern as a string
  String inAddrPattern = inMessage.addrPattern();
  
  //create osc messages to send
  OscMessage toggle = new OscMessage("/1/pongtoggle");
  OscMessage speed = new OscMessage("/1/ballspeed");
  OscMessage filt_fader = new OscMessage("/1/filterfader");
  
  //is the incoming message from the toggle button?
  //is the message to turn pong on or off?
  if (inAddrPattern.equals("/1/pongtoggle") && inMessage.get(0).floatValue()==1.0) {
    //send toggle command on
    toggle.add(1);
    osc_obj.send(toggle,local);
    
    //start draw function only after button has been pressed
    loop();
    
  } else if(inAddrPattern.equals("/1/pongtoggle") && inMessage.get(0).floatValue()==0.0){
    //send toggle command off
    toggle.add(0);
    osc_obj.send(toggle,local);
    
    //pause game - stop draw function
    noLoop();
  } else if(inAddrPattern.equals("/1/filterfader")) {
    filt_fader.add(inMessage.get(0).floatValue());
    osc_obj.send(filt_fader,local);
  } else //change speed of ball according to fader on iPad
  if (inAddrPattern.equals("/1/ballspeed")) {
    ball_speed = inMessage.get(0).floatValue();
    
    //send speed message out
    speed.add(inMessage.get(0).floatValue());
    osc_obj.send(speed,local);
  }
}

//determine what quadrant the ball is in 
//position is described in terms of a 16 block grid layout, labeled l->r, top->btm
int gridLayout(int px, int py) {
  int quadrant=0;
  
  //determine what column the ball is in
  int column = calcMatrix(px, height);
  
  //calculate cell based on the column + row number-1 * 4
  quadrant = column + (calcMatrix(py, width)-1)*4;
  
  return quadrant;
}

//calculate what row or column the ball is in
//position is the x or y position of the ball
//dimension is the height or width of the window
int calcMatrix (float position, float dimension) {
  
  //avoid overflow
  if (position == dimension) {
    position--;
  }
  
  return floor(position/dimension*4) + 1;
}

//draw dotted line down center of screen
void drawInterface() {
  int top = 0;
  int dash_length = 10;
  stroke(255);
  
  //draw a dotted line
  for (int i=0; i<=(height/10); i++) {
    line(width/2, top, width/2, top+dash_length);
    top = top + 2*dash_length;
  }
}

//draw the paddles
void drawPaddles() {
  //draw paddle 1 (left player)
  rect(paddle1X, paddle1Y, paddleWidth, paddleHeight);

  //draw paddle 2 (right player)
  fill(255, 0, 255);
  rect(paddle2X, paddle2Y, paddleWidth, paddleHeight);
}

//make paddles follow ball
void paddlePosition() {
  int paddle_pos = ballY-paddleHeight/2;
  
  //make sure paddles don't go out of the screen
  if (ballY<=0+paddleHeight/2){ //top of screen
    paddle_pos = 0;
  } else if (ballY>=height-paddleHeight/2){ //bottom of screen
    paddle_pos = height-paddleHeight;
  }
  
  //set paddle position
  paddle1Y = paddle_pos;
  paddle2Y = paddle_pos;
}

//switch direction when ball hits either paddle, or a top/bottom wall
void ellipseBounce() {
  if (ballY>paddle2Y && ballY<paddle2Y+paddleHeight && ballX>width-2*paddleWidth) {        //paddle 2 (right player)
    //x coordinates
    if (ballX>(width-ballSize/2-paddleWidth-2)) {
      speedX = speedX*(-1);
    } 
    else if (ballX<(0+ballSize/2+paddleWidth+2)) {
      speedX = speedX*(-1);
    }
  } 
  else if (ballY>paddle1Y && ballY<paddle1Y+paddleHeight && ballX<0+paddleWidth+0.5*paddleWidth) {  //paddle 1 (left player)
    //x coordinates
    if (ballX<(0+ballSize/2+paddleWidth+2)) {
      speedX = speedX*(-1);
    } 
    else if (ballX>(0-ballSize/2-paddleWidth-2)) {
      speedX = speedX*(-1);
    }
  } 
  else if (ballX>width) { //reset ball to middle if paddle is not contacted
    last_point = update_points(1);
  } 
  else if (ballX<0) { //reset ball to middle if paddle is not contacted
    last_point = update_points(0);
  }

  //y coordinates
  if (ballY>(height-ballSize/2)) {
    speedY = speedY*(-1);
  } 
  else if (ballY<0+ballSize/2) {
    speedY = speedY*(-1);
  }
}

//iterate the position of the ball on every cycle of draw - determined by frames per second
//increasing the frames per second will increase the rate in which the ball appears to travel
//alternatively, multiply the direction variable by a constant
//speed values are between 1 and 4
void ballSpeed(float speed) {
  
  OscMessage ballPos = new OscMessage("/1/ballpos");
  float f_width = width;
  float midiBallPos;
  
  //prevent ballspeed dial from pausing game
  if (speed==0) {
    speed=0.1;
  }
  ballX = ballX + speedX*ceil(speed*5);
  ballY = ballY + speedY*ceil(speed*5);
  
  //send the ball position to Max
  midiBallPos = ballX/f_width*127.0;
  ballPos.add(int(midiBallPos));
  osc_obj.send(ballPos,local);
}

//keep track of who scored
int update_points(int score) {
  //reset ball position
  ballX = init_ballX;
  ballY = init_ballY;
  
  if (score==1) {
    speedX = abs(speedX)*(-1);
    speedY = abs(speedY)*(-1);
    return 1;
  } 
  else {
    speedX = abs(speedX);
    speedY = abs(speedY);
    return 0;
  }
}

