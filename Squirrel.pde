class Squirrel
{
  int atBranch, atSegment;
  int jump = 1;
  int walkingStyle = 0; //0 - gdy napotkasz korzeń całego drzewa, albo czubek, po prostu nie idź dalej.
  //1 - gdy napotkasz czubek, zeskocz na korzeń całego drzewa; gdy napotkasz korzeń, skocz na losowy czubek
  //2 - gdy napotkasz czubek, zeskocz na podstawę losowej gałęzi; gdy napotkasz podstawę gałęzi...
  //... skocz na losowy czubek, nigdy nie wchodź na gałąź pokolenia zero. gdy tam się znajdziesz...
  //... od razu skocz na losowy czubek
  //3 - chodź po losowych segmentach gałęzi pokolenia zero (po pniu czyli w sensie że)

  boolean moveResult = false;

  String name;
  int nameInt;


  Squirrel(String nameTemp, int walkingStyleTemp)
  {
    name = nameTemp;
    walkingStyle = walkingStyleTemp;
    if (name == "Alf") nameInt = 0;
    if (name == "Bill") nameInt = 1;
    if (name == "Chip") nameInt = 2;
    if (name == "Dale") nameInt = 3;
  }

  void doSomething(char keyTemp) //funkcja służąca do sterowania manualnego, z klawiatury
  {
    switch(keyTemp)
    {
    case 'u':
      goUp();
      break;
    case 'j':
      goDown();
      break;
    case 'i':
      goChild();
      break;
    case 'y':
      jump *= 2;
      println(name + "'s jump changed to " + jump);
      break;
    case 'h':
      if (jump > 1)
        jump *= 0.5;
      println(name + "'s jump changed to " + jump);
      break;
    case 'm':
      walkingStyle++;
      if (walkingStyle == 3) walkingStyle = 0;
      println(name + "'s walking style changed to " + walkingStyle);
      break;
    }
    if (moveResult == true)
    {
      tree.branches.get(atBranch).segments.get(atSegment).printSegmentData();
      if (tree.branches.get(atBranch).segments.get(atSegment).soundSource != -1) 
        oscPlay.updateSound(nameInt, atBranch, atSegment); // komunikat OSC wysyłany tylko, gdy segment powstał z dźwięku
    }
    moveResult = false;
  }

  void autoTraverse(int style, float jumpRandomization, float direction) //funkcja automatycznego łażenia, wywoływana przez timer
  {
    // jump randomization to maksymalna wartość skoku, podana w ułamku (0.0 - 1.0) długości gałęzi
    // direction - im bliższa 1, tym większa tendencja do pójścia w górę 
    walkingStyle = style;
    jump = int(tree.branches.get(atBranch).segments.size() * random(jumpRandomization));


    float decision = random(1);      
    if (decision < direction)
      goUp();
    else
      goDown();

    decision = random(1);
    if (walkingStyle != 3 && decision < 0.7);
    goChild();
    
    if (moveResult == true)
    {
      tree.branches.get(atBranch).segments.get(atSegment).printSegmentData();
      if (tree.branches.get(atBranch).segments.get(atSegment).soundSource != -1) 
        oscPlay.updateSound(nameInt, atBranch, atSegment); // komunikat OSC wysyłany tylko, gdy segment powstał z dźwięku
    }
    moveResult = false;
  }




  void goUp()
  {
    if (walkingStyle == 3 && atBranch != 0)
    {
      atBranch = 0;
      atSegment = int(random(tree.branches.get(0).segments.size()));
    }
    else if (atSegment < tree.branches.get(atBranch).growingSegment - 1) //to ostatni na który można wejść. Growing segment jeszcze nie istnieje!!
    { 
      atSegment += jump;
      if (atSegment >= tree.branches.get(atBranch).growingSegment) atSegment = tree.branches.get(atBranch).growingSegment - 1; // fixme - czy nie powinien wracać na apex? skok może być duży...
      println(name + " is at branch " + atBranch + " at segment " + atSegment + ". Jump is " + jump);
      moveResult = true;
    }
    else 
    {      
      switch(walkingStyle)
      {
      case 0: // pozostań w miejscu
        println(name + " has reached apex");
        break; 
      case 1: 
        atSegment = 0;
        atBranch = 0;
        moveResult = true;
        break;
      case 2:
        atSegment = 0;
        atBranch = int(random(1, currentBranch));
        moveResult = true;
        break;
      case 3:
        atBranch = 0;
        atSegment = 0;
        moveResult = true;
        break;
      }
    }
  }

  void goDown()
  {
    if (walkingStyle == 3 && atBranch != 0)
    {
      atBranch = 0;
      atSegment = int(random(tree.branches.get(0).segments.size()));
    }
    else if (atSegment > 0) //przed wykonaniem kroku nie jesteśmy u nasady gałęzi
    {
      atSegment -= jump;
      if (atSegment < 0) atSegment = 0;
      println(name + " is at branch " + atBranch + " at segment " + atSegment + ". Jump is " + jump);
      moveResult = true;
    }
    else
    {      
      switch(walkingStyle)
      {
      case 0: // idź swobodnie, dowolnie nisko aż do korzenia      
        if (atBranch != 0) // jeśli tak, to zejdź na gałąź - rodzica
        {
          atSegment = tree.branches.get(atBranch).parentSegment;
          atBranch = tree.branches.get(atBranch).parentBranch;
          moveResult = true;
        }
        else
        {
          println(name + " has reached root");
          moveResult = false;
        }
        break; 
      case 1:
        if (atBranch != 0) // jeśli tak, to zejdź na gałąź - rodzica
        {
          atSegment = tree.branches.get(atBranch).parentSegment;
          atBranch = tree.branches.get(atBranch).parentBranch;
          moveResult = true;
        }
        else
        {
          atBranch = int(random(0, currentBranch));
          atSegment = tree.branches.get(atBranch).growingSegment - 1;
          moveResult = true;
        }
        break;
      case 2:
        atBranch = int(random(1, currentBranch));
        atSegment = tree.branches.get(atBranch).growingSegment - 1;
        moveResult = true;
        break;
      case 3:
        atBranch = 0;
        atSegment = tree.branches.get(atBranch).growingSegment - 1;
      }
    }
  }

  void goChild()
  {
    if (tree.branches.get(atBranch).children.get(atSegment) > 0)
    {
      atBranch = tree.branches.get(atBranch).children.get(atSegment);
      atSegment = 0;
      println(name + " is now at child branch " + atBranch + " at segment " + atSegment);
      moveResult = true;
    }
    else println(name + " hasn't found any child branch here");
  }

  void drawSquirrel()
  {
    if (hud == true && currentSegment > 0)// && int(millis()/ (500 + nameInt * 30) % 2) == 0) 
    {
      pushMatrix();
      applyMatrix(tree.branches.get(atBranch).segments.get(atSegment).matrix);
      rotateY(radians(90));
      colorMode(HSB);
      stroke(nameInt * 40, 255, 255);
      noFill();
      strokeWeight(1);
      ellipseMode(CENTER);
      float squirrelRadius = (millis() % 3000) * 0.03;
      ellipse(0, 0, squirrelRadius, squirrelRadius);
      squirrelRadius = ((millis() + 1000) % 3000) * 0.03;
      ellipse(0, 0, squirrelRadius, squirrelRadius);
      squirrelRadius = ((millis() + 2000) % 3000) * 0.03;
      ellipse(0, 0, squirrelRadius, squirrelRadius);
      colorMode(RGB);
      popMatrix();
    }
  }

  void updateSquirrel()
  {
    oscPlay.updateSound(int(name), atBranch, atSegment);
  }

  //  void goTo()
  //  {
  //    int searchedBranchIndex = 0;
  //    int searchedNodeIndex = 0;
  //    int shortestDistance = 3000;
  //    int distanceTemp = 0;
  //    mouseXTemp = mouseXTemp - width / 2;
  //    mouseYTemp = mouseYTemp - height;
  //    mouseYTemp *= -1;
  //
  //    println("   ... Let's find a segment closest to mouse coords: x: " + mouseXTemp + " y: " + mouseYTemp); 
  //
  //    find(mouseXTemp, mouseYTemp, 0); 
  //    traversed = false; 
  //    foundClosestNode = true; 
  //    traversingBranch = searchedBranchIndex;
  //    traversingSegment = searchedNodeIndex;   
  //    traversingSound = 0;
  //    direction = 5;
  //    mustDrawTraverse = true;
  //
  //    println("Closest is segment " + searchedNodeIndex + " of branch " + searchedBranchIndex + ", " + shortestDistance + " pixels away from cursor");
  //
  //    setSounds();
  //    
  //  }
}