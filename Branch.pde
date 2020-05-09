class Branch
{
  int branchIndex;       //Numer gałęzi w ramach całego drzewa
  int branchGeneration;  //Pokolenie gałęzi
  int parentBranch;      //Numer gałęzi i...
  int parentSegment;     //...numer jej segmentu, z których niniejsza gałąź wyrasta

  int growingSegment = 0; //To jest index tego segmentu, który teraz może urosnąć, a NIE indeks ostatniego segmentu! (gałąź może nie mieć segmentów)

  boolean reachedMaxLength = false; //Jeśli osiągnie maksymalną długość, nie może dalej urosnąć

  ArrayList<Segment> segments; //Tu są przechowywane wszystkie segmenty
  ArrayList<Integer> children; //Tablica zawierająca indeksy gałęzi-dzieci. Indeks tablicy odpowiada
  //segmentowi, z którego podstawy wyrasta gałąź-dziecko.  

  float branchLength = 0;

  Branch(int branchIndexTemp, int branchGenerationTemp, int parentBranchTemp, int parentSegmentTemp)
  {    
    branchIndex = branchIndexTemp;
    branchGeneration = branchGenerationTemp;
    parentBranch = parentBranchTemp;
    parentSegment = parentSegmentTemp;
    segments = new ArrayList(0);
    children = new ArrayList(0);

    boolean newSegmentHasLeave = false; 
    float newSegmentHasLeaveRand = 0;
  }



  void makeChildren()
  {    
    // pierwszy warunek zmieniony! z liczby segmentów na liczbę pikseli!!!
    if (branchLength > tree.mod.firstChildOffset[branchGeneration] && branchGeneration <= tree.maxGenerations && growingSegment % 4 == 0) //random(0, 1) < tree.mod.childrenProbability[branchGeneration]) 
    {
      // jeśli spełnione są powyższe warunki, powstanie nowa gałąź, która otrzyma nowy numer, który w tej chwili będzie równy sumie wszystkich gałęzi liczonej od zera
      currentBranch++;
      tree.branches.add(new Branch(currentBranch, branchGeneration + 1, branchIndex, growingSegment));
      children.set(growingSegment, currentBranch);
      segments.get(growingSegment).childIndex = currentBranch; // Obiekty "segment" zawierają dane o swoim dziecku
      //      println(" :: child was born from branch no: " + branchIndex + " generation: " + (branchGeneration + 1) + " from segment: " + growingSegment + ". It's number: " + currentBranch);
    }
  }

  void printBranchData()
  {
    if (growingSegment == 0)
      println("  |_ :: branch no " + branchIndex + " is at seed stadium");
    else
    {
      println("  |_ :: branch no: " + branchIndex + " has length: " + branchLength);
      for (int i=0; i < growingSegment; i++)
      {         
        segments.get(i).printSegmentData();
      }
    }
  }

  void calculateDiameters() //fixme
  {    
    float baseDiameter = 0;
    float lengthToSegment = 0;    

    if (branchGeneration > 0)
    {
      // fixme Poniżej 1 ma być zastąpione modyfikatorem
      baseDiameter = min(tree.mod.maxChildDiameter[branchGeneration] * tree.branches.get(parentBranch).segments.get(parentSegment).segmentDiameter, 
      branchLength / tree.mod.slim[branchGeneration]);
    }
    else baseDiameter = branchLength / tree.mod.slim[0];

    for (int i=0; i <= growingSegment; i++)
    { 
      if (i>0)     
        lengthToSegment += segments.get(i-1).segmentLength;
      segments.get(i).segmentDiameter = baseDiameter * (branchLength - lengthToSegment) / branchLength; //fixme - wywalić mnożnik, zastąpić modem
      //      println("   ----  Segment diameter is: " + segments.get(i).segmentDiameter);
    }
  }

  void drawBranch()
  {
    for (int i=0; i<growingSegment; i++)
      segments.get(i).drawSegment();
  }
}