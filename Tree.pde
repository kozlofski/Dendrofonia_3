class Tree
{
  ArrayList<Branch> branches;
  Mod mod;
  Squirrel alf, bill, chip, dale;
  ArrayList<Integer> folders; // tablica przechowująca listę folderów z których wygenerowano drzewo

  PMatrix3D baseMatrix, rootMatrix, currentMatrix, currentMatrixForSearch;

  int maxGenerations;
  int megaTurboGrowthJump = 2000;

  float displayScale;

  color leaveColors[];

  // Poniżej zmienne wykorzystywane w funkcji branchGrowth()
  boolean newSegmentHasLeave; //Zmienne służące do decydowania, czy z nowego segmentu będzie...
  float newSegmentHasLeaveRand; //... rósł liść.
  int leaveColorTemp;      // losowany kolor liścia

  boolean treeFull = false, wholeTreeChecked = false;
  int checkCounter = 0;


  Tree(int maxGenerationsTemp, float displayScaleTemp)
  {
    displayScale = displayScaleTemp;
    maxGenerations = maxGenerationsTemp;
    branches = new ArrayList(0);
    folders = new ArrayList(0); 

    mod = new Mod(maxGenerations);
    alf = new Squirrel("Alf", 0);
    bill = new Squirrel("Bill", 1);
    chip = new Squirrel("Chip", 2);
    dale = new Squirrel("Dale", 3);

    baseMatrix = new PMatrix3D();
    rootMatrix = new PMatrix3D(); 
    currentMatrix = new PMatrix3D();
    currentMatrixForSearch = new PMatrix3D(); //matryks do wyszukiwania następnej gałęzi

    setInitialState();
  }

  void stepGrowth(int soundSource, int soundNumber, int soundLength)
  {
    branchGrowth(soundSource, soundNumber, soundLength); //fixme na potrzeby prezentacji
    printTree();
    redraw();
  }

  void fastGrowth() // po naciśnięciu 'q' - segment po segmencie
  {
    println("\n     NEW STEP - by Fast Growth");
    int soundSource = -1;
    int soundNumber = 0;
    int soundLength = 2000;    

    branchGrowth(soundSource, soundNumber, soundLength);

    printTree();
    //    println(" :: current fps: " + frameRate);
  }

  void turboGrowth() // po naciśnięciu 'Q' - każda z istniejących gałęzi przyrasta o jeden segment
  {
    println("\n     NEW STEP - by Turbo Growth");
    int soundSource = -1;
    int soundNumber = 0;
    int soundLength = 2000;

    for (int i=0; i<=currentBranch; i++)
      branchGrowth(soundSource, soundNumber, soundLength);

    printTree();
    println(" :: current fps: " + frameRate);
  }

  void megaTurboGrowth() // po naciśnięciu 'w' rośnie 2000 kolejnych segmentów (tzn. wartość megaTurboGrowthJump)
  {
    println("\n     NEW STEP - by Mega Turbo Growth");
    int soundSource = -1;
    int soundNumber = 0;
    int soundLength = 2000;
    int i=0;
    do
    {      
      branchGrowth(soundSource, soundNumber, soundLength);
      i++;
      if (i>currentBranch) i=0;
    }
    while (currentSegment < megaTurboGrowthJump && treeFull == false);

    megaTurboGrowthJump += 2000;
    printTree();
    redraw();
    println(" :: current fps: " + frameRate);
  }

  void ultraTurboGrowth()
  {
    println("\n     NEW STEP - by Ultra Turbo Growth");
    int soundSource = -1;
    int soundNumber = 0;
    int soundLength = 3000;    

    do
    {         
      branchGrowth(soundSource, soundNumber, soundLength);
    }
    while (currentSegment < 10000  && treeFull == false);

    printTree();
    //    cam.lookAt(width/2, height - branches.get(0).branchLength/2, 0);

    println(" :: current fps: " + frameRate);
  }


  void branchGrowth(int soundSourceTemp, int soundNumberTemp, int soundLengthTemp)
  {
    try
    {
      boolean hasGrown = false;
      checkCounter = 0;

      do
      {
        if (growingBranch > currentBranch) growingBranch = 0;

        if (branches.get(growingBranch).reachedMaxLength == false)
        {      
          if (branches.get(growingBranch).growingSegment > 0) //miejsce w którym jesteśmy to gałąź, która ma już jakąś długość, ale nie osiągnęła maksimum
          {
            // wtedy przemieszczamy się na koniec tej gałęzi
            currentMatrix = branches.get(growingBranch).segments.get(branches.get(growingBranch).growingSegment-1).getMatrix();
            currentMatrix.translate(branches.get(growingBranch).segments.get(branches.get(growingBranch).growingSegment-1).segmentLength, 0, 0);
          }

          // jeśli bieżąca gałąź nie ma segmentów (growingSegment == 0), ale nie jest to pień
          else if (branches.get(growingBranch).branchIndex > 0)
          {
            // pobieramy matrix z początku segmentu rodzica
            currentMatrix = branches.get(branches.get(growingBranch).parentBranch).segments.get(branches.get(growingBranch).parentSegment).getMatrix();
            // i obracamy segment (który zaraz wyrośnie) o kąt
            currentMatrix.rotateZ(tree.mod.childrenAngles[branches.get(growingBranch).branchGeneration]);
          }

          // sytuacja początkowa - gałąź zerowa (pień) nie ma segmentów (growingSegment == 0)
          else if (branches.get(growingBranch).branchIndex == 0 && branches.get(growingBranch).growingSegment == 0) 
          {
            currentMatrix = rootMatrix; // tu jest błąd, ale nie wiem jaki.
          } else println("NIEZNANY PRZYPADEK!!");

          // Teraz nadawane są nowemu segmentowi parametry: pofalowanie gałęzi i filotaksja
          currentMatrix.rotateZ(random(-tree.mod.wavinessAngles[branches.get(growingBranch).branchGeneration], tree.mod.wavinessAngles[branches.get(growingBranch).branchGeneration]));
          currentMatrix.rotateX(tree.mod.phylotaxis[branches.get(growingBranch).branchGeneration]);
          //        currentMatrix.rotateX(PI * 0.5); // dzięki tej rotacji równoważona jest randomowa falistość gałęzi i mniej jest prawdopodobne, że skręci kompletnie w jedną stronę

          // Losujemy, czy z nasady tego segmentu urośnie liść
          newSegmentHasLeaveRand = random(0, 1);
          if (newSegmentHasLeaveRand < tree.mod.leaveProbability[branches.get(growingBranch).branchGeneration])
          {
            newSegmentHasLeave = true;
            leaveColorTemp = int(random(0, 4.9));
          } else 
          {
            newSegmentHasLeave = false;
            leaveColorTemp = 0;
          }

          // TU JEST TWORZONY NOWY SEGMENT!!!
          branches.get(growingBranch).segments.add(new Segment(branches.get(growingBranch).branchIndex, branches.get(growingBranch).branchGeneration, branches.get(growingBranch).growingSegment, currentSegment, millis(), soundSourceTemp, soundNumberTemp, soundLengthTemp, currentMatrix, newSegmentHasLeave, leaveColorTemp));

          branches.get(growingBranch).branchLength += branches.get(growingBranch).segments.get(branches.get(growingBranch).growingSegment).segmentLength;

          //          if (branches.get(growingBranch).branchGeneration == 0) 
          //            println(" chkCntr: " + checkCounter + " --- after growth brnch 0 has " + branches.get(growingBranch).segments.size() + " segments. Tree has " + currentBranch + " branches and " + currentSegment + " segments");

          branches.get(growingBranch).calculateDiameters();

          // Poniżej tworzony nowy element tablicy Children, na razie równy zero...
          branches.get(growingBranch).children.add(0);
          // ... ale poniżej, jeśli warunki zostaną spełnione, tam może pojawić się gałąź-dziecko i zero zostanie zmienione na indeks nowej gałęzi.
          branches.get(growingBranch).makeChildren();  

          //        if (branches.get(growingBranch).children.get(branches.get(growingBranch).children.size()-1) != 0)
          //        // filotaksja nadawana jest tylko tym segmentom, z których rosną gałęzie dzieci, po to, by KOLEJNE gałęzie tworzyły kąty filotaksji
          //        branches.get(growingBranch).segments.get(branches.get(growingBranch).segments.size()-1).matrix.rotateX(tree.mod.phylotaxis[branches.get(growingBranch).branchGeneration]);
          ////          currentMatrix.rotateX(tree.mod.phylotaxis[branches.get(growingBranch).branchGeneration]);


          if (branches.get(growingBranch).segments.size() > 1) checkLength();


          if (branches.get(growingBranch).reachedMaxLength == false) branches.get(growingBranch).growingSegment++;

          // Poniżej rośnie suma wszystkich segmentów (GLOBALNA)
          currentSegment++;

          if (isRun == true && currentSegment % 50 == 0) autoSaveTree();

          hasGrown = true;
        }
        // Jeśli trafiłeś na gałąź za długą, szukaj do skutku takiej, która może urosnąć
        else checkCounter++;

        growingBranch++;      

        if (checkCounter > currentBranch) 
        {
          wholeTreeChecked = true;
          println("Tree full!!");
          treeFull = true;
        }
      }
      while (hasGrown == false && wholeTreeChecked == false);
    }
    catch(Exception e)
    {
      wholeTreeChecked = true;
      //      println("EXCEPTION!!!!!!!!!!! Check counter = " + checkCounter);
    }
  }

  void printTree() // delete
  {        
    println("|_ :: Tree - total branches: " + currentBranch + ", total segments: " + currentSegment);
    //    for (int i=0; i <= currentBranch; i++)
    //      branches.get(i).printBranchData();
  }

  void drawTree()
  {    
    //    currentMatrix.reset();  // fixme niepotrzebne?
    for (int i=0; i <= currentBranch; i++)
      branches.get(i).drawBranch();
  }

  void deleteTree()
  {
    setInitialState();
  }

  void regenerateTree()
  {
    setInitialState();
    ultraTurboGrowth();
  }

  void setInitialState()
  {
    currentSegment = 0;
    currentBranch = 0;
    growingBranch = 0;
    branches.clear();
    folders.clear();
    branches.add(new Branch(0, 0, -1, -1));    
    rootMatrix.reset();
    rootMatrix.translate(width/2, height, 0);
    rootMatrix.rotateZ(radians(-90));
    currentMatrix.set(rootMatrix);
    treeFull = false;
    wholeTreeChecked = false;

    megaTurboGrowthJump = 2000;
    println("Initial state set.");
  }

  void setInitialStateAfterOpen()
  {
    rootMatrix.reset();
    rootMatrix.translate(width*0.5, height*0.75, 0);
    rootMatrix.scale(displayScale, displayScale, displayScale);
    rootMatrix.rotateZ(radians(-90));
    currentMatrix.set(rootMatrix);

    megaTurboGrowthJump = 2000;
  }

  void printRootAndCurrentMatrix()
  {
    println("Current matrix: " + currentMatrix.m03 + " " + currentMatrix.m13 + " " + currentMatrix.m23);
    println("Root    matrix: " + rootMatrix.m03 + " " + rootMatrix.m13 + " " + rootMatrix.m23);
  }

  void autoSaveTree()
  {
    memory.saveTree("auto");
  }

  void searchForNextGrowingBranch() 
    // Wyszukuje punkt w przestrzeni, w którym wyrośnie następna gałąź
  {
    boolean hasGrownForSearch = false;    
    int growingBranchForSearch = growingBranch;

    do
    {
      growingBranchForSearch++;
      if (growingBranchForSearch > currentBranch) growingBranchForSearch = 0;

      if (branches.get(growingBranchForSearch).reachedMaxLength == false)
      {     
        if (branches.get(growingBranchForSearch).growingSegment > 0) //miejsce w którym jesteśmy to gałąź, która ma już jakąś długość, ale nie osiągnęła maksimum
        {
          // wtedy przemieszczamy się na koniec tej gałęzi
          currentMatrixForSearch = branches.get(growingBranchForSearch).segments.get(branches.get(growingBranchForSearch).growingSegment - 1).getMatrix();
          currentMatrixForSearch.translate(branches.get(growingBranchForSearch).segments.get(branches.get(growingBranchForSearch).growingSegment - 1).segmentLength, 0, 0);
        }

        // jeśli bieżąca gałąź nie ma segmentów (growingSegment == 0)
        else if (branches.get(growingBranchForSearch).branchIndex > 0)
        {
          // pobieramy matrix z początku segmentu rodzica
          currentMatrixForSearch = branches.get(branches.get(growingBranchForSearch).parentBranch).segments.get(branches.get(growingBranchForSearch).parentSegment).getMatrix();
        }

        // sytuacja początkowa
        else if (branches.get(growingBranchForSearch).branchIndex == 0 && branches.get(growingBranchForSearch).growingSegment == 0) 
        {
          currentMatrixForSearch = rootMatrix; // tu jest błąd, ale nie wiem jaki.
        } else println("NIEZNANY PRZYPADEK!!");

        hasGrownForSearch = true;
      } else //Jeśli trafiłeś na gałąź za długą, szukaj do skutku takiej, która może urosnąć
      {
        growingBranchForSearch++;
        if (growingBranchForSearch > currentBranch) growingBranchForSearch = 0;
      }
    }
    while (hasGrownForSearch == false); // fixme

    println("Found: " + tree.currentMatrixForSearch.m03 + " " + tree.currentMatrixForSearch.m13 + " " + tree.currentMatrixForSearch.m23);

    //cam.lookAt(tree.currentMatrixForSearch.m03, tree.currentMatrixForSearch.m13, tree.currentMatrixForSearch.m23);
  }

  void checkLength()
  {

    // Poniżej sprawdzane jest, czy gałąź nie zaczyna wychodzić poza obrys korony.
    // Po ostatnim przyroście segment mógł odrobinę wyjść poza obrys.
    // Najpierw ustalane wewnętrzne zmienne dla większej przejrzystości kodu i obliczeń


    float treeHeight = branches.get(0).branchLength;
    float branchY = height - branches.get(growingBranch).segments.get(branches.get(growingBranch).growingSegment - 1).matrix.m13; // współrzędna Y czubka bieżącej (sprawdzanej) gałęzi
    float treetopOffset = mod.firstChildOffset[0]; // offset całej korony w pikselach
    // envelopeApex to współrzędna Y (wysokość), w której korona ma swoją największą średnicę
    float envelopeApex = (treeHeight - treetopOffset) * mod.lowerTreetopFactor + treetopOffset;
    float maxLength = 0;



    if (branches.get(growingBranch).branchGeneration == 0) 
    {
      // wyniki w pikselach
      mod.lowerTreetopPix = mod.lowerTreetopFactor * (treeHeight - treetopOffset);
      mod.upperTreetopPix = mod.upperTreetopFactor * (treeHeight - treetopOffset);
      mod.maxTreetopDiameter = treeHeight / mod.heightToDiameter;
    }

    //    println("Lower and upper treetoppix: " + mod.lowerTreetopPix + " " + mod.upperTreetopPix);
    //    println("Max t.top diam: " + mod.maxTreetopDiameter);



    if (branches.get(growingBranch).branchGeneration > 0)
    {
      float distanceFromAxis = 0;     

      distanceFromAxis = sqrt(sq(width/2 - branches.get(growingBranch).segments.get(branches.get(growingBranch).growingSegment-1).matrix.m03) + sq(branches.get(growingBranch).segments.get(branches.get(growingBranch).growingSegment-1).matrix.m23));


      try
      {
        //      mod.maxTreetopDiameter = branches.get(0).segments.get(branches.get(growingBranch).growingSegment-1).matrix.m13 / mod.heightToDiameter;
        mod.maxTreetopDiameter = branches.get(0).branchLength / mod.heightToDiameter;
      }
      catch(Exception e)
      {
        println("Mam cie skurwysynu");
      }



      // poniżej ustalana jest granica korony; są dwie funkcje, jedna dla lower, druga dla upper treetop
      if (branchY <= envelopeApex && branchY >= treetopOffset)
        maxLength = pow(((branchY - treetopOffset) / mod.lowerTreetopPix), mod.lowerTreetopExp) * mod.maxTreetopDiameter;
      if (branchY > envelopeApex && branchY <= treeHeight)
        maxLength = pow(((treeHeight - branchY) / mod.upperTreetopPix), mod.upperTreetopExp) * mod.maxTreetopDiameter;
      else maxLength = 10; // ?
      //      println("MAX LNGHTH: " + maxLength);

      if (distanceFromAxis >= maxLength || distanceFromAxis >= branches.get(branches.get(growingBranch).parentBranch).branchLength)
      {
        branches.get(growingBranch).reachedMaxLength = true;
        //        println("Branch number : " + growingBranch + " has reached maximum length!");
      } else branches.get(growingBranch).reachedMaxLength = false;
    }




    if (branches.get(growingBranch).branchGeneration == 0)
      if (branches.get(growingBranch).branchLength > mod.maxHeight)
      {
        branches.get(growingBranch).reachedMaxLength = true;
        //        println("Osiągnięto maksymalną wysokość drzewa: " + branches.get(growingBranch).reachedMaxLength);
      }
  }
}