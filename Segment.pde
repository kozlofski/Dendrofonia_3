class Segment
{
  int branchIndex;        //Numer gałęzi (w ramach całego drzewa), w której ten segment się znajduje
  int branchGeneration;   //Pokolenie tejże gałęzi
  int segmentIndex;       //Numer segmentu w ramach bieżącej gałęzi
  int segmentNumber;      //Numer segmentu w ramach całego drzewa


  float segmentBirth;     //Narodziny segmentuw milisekundach od uruchomienia programu

  int soundSource = -1;   //Numer źródła dźwięku, z którego pochodzi plik numer...
  int soundNumber = 0;    //... który trwa...
  int soundLength = 0;    //...milisekund.


  PMatrix3D matrix;       //Matryca zawierająca wszystkie przekształcenia względem punktu korzenia.
  //Rysowanie segmentu polega na narysowaniu linii o długości [segmentLength] pikseli
  //a wszelkie kąty oraz pozycja początku tej linii zawarta jest w tej matrycy.

  boolean hasLeave;
  int leaveColor;

  float segmentLength;    //Długość segmentu w pikselach, obliczana na podstawie modyfikatorów i długości dźwięku

  float segmentDiameter;  //Grubość segmentu w pikselach; metoda jej obliczania jest w nadrzędnej klasie, Branch.
  int childIndex = 0;     //Jeśli u podstawy tego segmentu wyrasta jakaś gałąź, ta zmienna przechowuje jej [branchIndex],
  //jeśli nie wyrasta, ta wartość równa jest 0.

  Segment(int branchIndexTemp, int branchGenerationTemp, int segmentIndexTemp, int segmentNumberTemp, 
  float segmentBirthTemp, int soundSourceTemp, int soundNumberTemp, int soundLengthTemp, PMatrix3D matrixTemp, boolean hasLeaveTemp, int leaveColorTemp)
  {
    branchIndex = branchIndexTemp;
    branchGeneration = branchGenerationTemp;
    segmentIndex = segmentIndexTemp;
    segmentNumber = segmentNumberTemp;
    segmentBirth = segmentBirthTemp;
    soundSource = soundSourceTemp;
    soundNumber = soundNumberTemp;
    //    soundLength = soundLengthTemp;
    soundLength = 2000; // na razie niech wszystkie segmenty mają jednakową długość
    matrix = matrixTemp.get();
    hasLeave = hasLeaveTemp;
    leaveColor = leaveColorTemp;

    segmentLength = soundLengthTemp / 1000;//* tree.mod.growthSpeedFactor[branchGeneration] / 1000;
  }

  void drawSegment()
  { 
    pushMatrix();       
    applyMatrix(matrix); 
    weight = segmentDiameter * stokeWievModifier;
    //if (weight < 1.5) smooth();
    //else noSmooth();
    strokeWeight(weight);
    //stroke(255, 255, 255);
    //stroke(50, 0, 0);//128 - 1.25 * matrix.m23);
    //    stroke(70);

    //line(0, 0, 0, segmentLength, 0, 0);
    //if (weight > 10) // dla wypełnienia szpar w najgrubszych gałęziach rysuje drugą linię, trochę przesuniętą
    //  line(5, 0, 0, segmentLength, 0, 0);

    if (hasLeave == true)
    {
      drawLeave();
    }

    popMatrix();
  }  

  void drawLeave()
  {
    noSmooth();
    color drawColor = #A000FF;
    //drawColor = leaveColors[leaveColor];
    noStroke();
    fill(drawColor, 180);
    pushMatrix();
    rotateZ(0.78); // dzięki temu rysuje liść po skosie względem segmentu
    rotateY(0.1 * windSpeed * wind(matrix.m13+matrix.m03));  
    ellipseMode(CORNER);
    float rand = random(-0.5, 0.5);
    ellipse(-0.5, -0.1, 6 + rand, 1.7 + rand);
    popMatrix();
  }

  void printSegmentData()
  {
    print("    |_ :: segment no: " + segmentNumber + " from branch no: " + branchIndex + ", length: " + segmentLength + ", born @ " + segmentBirth + "[ms], ");
    println("diameter: " + segmentDiameter + ", it's child is branch no: " + childIndex + " (0 - no child). ");
    println("          X: " + matrix.m03 + ". Y: " + matrix.m13 + ". Z: " + matrix.m23 + ". Azimuth: " + getAzimuth() + ". Distance: " + getDistance());
    if (soundSource == -1) println("          x))) No sounds here");
    else println("          o))) Sound source: " + nf(soundSource, 2) + ", number: " + nf(soundNumber, 5) + ", length: " + nf(soundLength, 5) + "[ms]");
  }

  PMatrix3D getMatrix()
  {
    return matrix.get();
  }

  // poniżej zwracane są współrzędne nadające się bezpośrednio do zinterpretowania przez PureData
  float getXcoords()
  {
    return matrix.m03 - (width/2);
  }

  float getYcoords()
  {
    return height - matrix.m13;
  }

  float getZcoords()
  {
    return matrix.m23;
  }

  float getAzimuth()
  {
    float azimuth = 0;    
    if (getXcoords() == 0 && getZcoords() < 0) azimuth = 0;
    else if (getXcoords() == 0 && getZcoords() >= 0) azimuth = 180;
    else azimuth = degrees(atan2(getZcoords(), getXcoords())) + 90;
    return azimuth;
  }

  float getDistance()
  {
    return sqrt(sq(getXcoords()) + sq(getZcoords()));
  }

  float getDiameter()
  {
    return segmentDiameter;
  }

  float getSoundSource()
  {
    return soundSource;
  }

  float getSoundNumber()
  {
    return soundNumber;
  }
}