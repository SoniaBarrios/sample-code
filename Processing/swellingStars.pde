Circle[] circles;
int bg = unhex("333333");        //hex background color

void setup() {
  //window setup
  size(800,600);
  background(bg);
  
  //all the circles stored in an array
  circles = new Circle[200];
  
  for(int i=0;i<circles.length;i++) {
    //create and display initial circles
    circles[i] = new Circle((width/2)+(width/2)*(random(2)-1),(height/2)+(height/2)*(random(2)-1),random(1)*10);
    circles[i].setRate(random(100)*0.0001);
  }
}

void draw () {
  background(bg);    //set background color
  for(int i=0;i<circles.length;i++) {
    circles[i].display();
  }
}

class Circle {
  float x,y;
  float csize, angle;
  int dir=0;
  float rate = 0.02;
  
  LFO lfo = new LFO(rate);

  Circle(float posx, float posy, float rad) {
    x=posx;
    y=posy;
    csize=rad*2;
  }
  
  void setRate(float rate) {
    lfo.rate = rate;
  }
  
  void display() {
    ellipse(x,y,csize*lfo.osc(),csize*lfo.osc());
  }
}

class LFO {
  float rate;
  private float angle;
  
  LFO (float speed) {
    rate = speed;
  }
  
  float osc() {
    angle+=rate;
    return sin(angle);
  }
}

