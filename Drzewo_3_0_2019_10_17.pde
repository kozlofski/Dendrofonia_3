import oscP5.*;
import netP5.*;


Tree tree;
Keys keys;
Memory memory;
Timer timer;
OscRec oscRec;
OscPlay oscPlay;
Generator generator;

int currentSegment;  //Aktualnie najwyższy numer segmentu (innymi słowy, ten segment ostatnio wyrósł lub tyle jest segementów + 1)
int currentBranch;   //Aktualnie najwyższy numer gałęzi (innymi słowy, ta gałąź ostatnio wyrosła lub tyle jest gałęzi + 1)
int growingBranch;   //Numer gałęzi, na końcu której może urosnąć segment. Po jego urośnięciu wartość ta rośnie o 1, tak, by następny segment
//urósł na innej gałęzi
//aż do osiągnięcia wartości currentBranch, czyli ilości wszystkich gałęzi (0 = jedna gałąź - pień), potem znowu od zera.

boolean isRun = false;
boolean cameraCentering = true;
boolean hud = true;
String pdRemoteFolder = "", pdLocalFolder = "", platform = "pc", lastSaved = "";
String[] modifiers;

float stokeWievModifier;

float weight; // do obliczania grubości kreski, oraz czy potrzebne jest wygładzanie

float camRotation = 0; // z tego korzysta funkcja robienia mgły

int selectSquirrel = 0;


int frameCounter;
int totalPixels;

color leaveColors[];

float windPhase, windSpeed, timeSinceLastFrame = 0; //zmienne do animacji wiatru

void setup()
{
  //size(1920, 1080, P3D);
  size(1000, 1000, P3D);
  //  size(1280, 800, P3D); // fullscreen
  totalPixels = 720 * 576;
  tree = new Tree(4, 1.3);
  keys = new Keys(); 
  memory = new Memory();
  timer = new Timer();
  oscRec = new OscRec();
  oscPlay = new OscPlay();
  generator = new Generator();
  frameRate(25);
  frameCounter = 0;
  strokeCap(ROUND);
  sphereDetail(6);
  //  colorMode(HSB);
  colorMode(RGB);
  //  smooth();
  leaveColors = new color[5];
  leaveColors[0] = #F809FF;
  leaveColors[1] = #19FF09;
  leaveColors[2] = #09BEFF;
  leaveColors[3] = #FF9D09;
  leaveColors[4] = #FFFF09;
}

void draw()
{
  
  translate(0, -330, 500);
  background(0);

  pushMatrix();

  translate(width*0.5, 0, 0);
  rotateY(4*PI*mouseX/width);
  translate(width*-0.5, 0, 0);
  stokeWievModifier = 1; // (float)cam.getDistance();

  //  background(150, 203, 255); // błękitne niebo
  //  background(255); // białe tło
  //background(100);  
  //wind();
  windSpeed = (mouseY - height * 0.5) * 0.02; // prędkość wiatru teraz sterowana myszą góra-dół.
  windPhase(windSpeed);
  //pushMatrix();
  //translate(width/2, height, -100);
  //rotateZ(radians(-90));  
  tree.drawTree();
  //popMatrix();
  //tree.alf.drawSquirrel();
  //tree.bill.drawSquirrel();
  //tree.chip.drawSquirrel();
  //tree.dale.drawSquirrel();
  popMatrix();
  pushMatrix();
  translate(width/2, height/2, 0);  
  fog();
  popMatrix();



  //  if (frameCounter % 20 == 0) oscPlay.updateCamAzimuth(); 

  frameCounter++;

  timer.check();
  //saveFrame("frames/####.tif");
}

void fog()
{  
  pushMatrix();
  rectMode(CENTER);
  noStroke();
  //fill(255, 255, 255, 10);
  fill(0, 0, 0, 20);
  translate(0, 0, -100);
  for (int z=0; z<20; z++)
  {
    rect(0, 50, 2*width, 2*height);    
    translate(0, 0, 10);
  }
  popMatrix();
}

void keyPressed()
{
  keys.keys(key);
}


float wind(float delta) //może powinna być wywoływana z każdego liścia?
{
  delta *= 0.1; // wyskalowane tak, by pełny okres powtarzał się co 100 pixeli
  return sin(windPhase + delta);// + random(-0.2, 0.2);
}


// poniżej funkcja, która dla danej ramki oblicza fazę wiatru.
void windPhase(float windSpeed)
{
  timeSinceLastFrame = millis() - timeSinceLastFrame;
  windPhase = windPhase + timeSinceLastFrame * 0.0063 * windSpeed; 
  timeSinceLastFrame = millis();
  // powyższe działanie oznacza, że faza wyskalowana jest w "prędkość wiatru"  2 * PI / s
  // 0.0063 to 2 * PI * 0.001. 0.001 wynika z przeskalowania milisekund na sekundy.
  // Częstotliwość wahania liści nie może być zależna od framerate'u, w związku z tym
  // przesuwanie fazy co kolejną klatkę obrazu jest proporcjonalne do czasu, jaki ta klatka trwa.
}