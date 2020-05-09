class Mod
{
  int maxGenerations;
  float childrenAngles[];
  float growthSpeedFactor[];
  float childrenProbability[];
  float wavinessAngles[];
  float firstChildOffset[];
  float maxChildDiameter[];
  float leaveProbability[]; // fixme - wersja próbna
  float slim[];
  float phylotaxis[];
  float maxHeight;
  float lowerTreetopFactor, upperTreetopFactor;
  float lowerTreetopExp, upperTreetopExp;
  float lowerTreetopPix, upperTreetopPix;
  float maxTreetopDiameter; // maksymalna średnica korony - aktualizowana na bieżąco, by zachować stały kształt
  float heightToDiameter; // stosunek wysokości całego drzewa do średnicy korony

  Mod(int maxGenerationsTemp)
  {
    maxGenerations = maxGenerationsTemp;
    populate();
  }

  void populate()
  {
    maxHeight = 610;

    lowerTreetopFactor = 0.5;
    upperTreetopFactor = 0.5;
    lowerTreetopExp = 2;
    upperTreetopExp = 0.3;
    maxTreetopDiameter = 100;
    heightToDiameter = 2;
    lowerTreetopPix = 0;
    upperTreetopPix = 0;
    


    float[] childrenAnglesTemp = { 
      70, 70, 20, 40, 40, 40, 40, 40, 40, 40, 40
    };

    float[] growthSpeedFactorTemp = {
      1.0, 0.8, 0.6, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.1
    };

    float[] childrenProbabilityTemp = {
      1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1
    };

    float[] wavinessAnglesTemp = {
      2, 10, 20, 20, 20, 20, 20, 20, 20, 20
    };

    float[] firstChildOffsetTemp = {
      60, 30, 30, 20, 10, 10, 10, 10, 6, 6
    };

    float[] maxChildDiameterTemp = {
      0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9
    };

    float[] leaveProbabilityTemp = {
      0.99, 0.8, 0.85, 0.85, 0.5, 0.3, 0.2, 0.01, 0.01, 0.01
    };

    float[] slimTemp = {
      10, 20, 20, 10, 30, 30, 30, 30, 30, 30
    };

    float[] phylotaxisTemp = {
      71, 70, 70, 70, 70, 70, 70, 70, 70, 70
    };

    

    childrenAngles = new float[maxGenerations];    
    childrenAnglesTemp = arrayToRadians(childrenAnglesTemp);
    childrenAngles = childrenAnglesTemp;
    printArray("Children angles    ", childrenAngles);

    growthSpeedFactor = new float[maxGenerations];    
    growthSpeedFactor = growthSpeedFactorTemp;
    printArray("Growth speed factor", growthSpeedFactor);

    childrenProbability = new float[maxGenerations];    
    childrenProbability = childrenProbabilityTemp;
    printArray("Child probability  ", childrenProbability);

    wavinessAngles = new float[maxGenerations];
    wavinessAnglesTemp = arrayToRadians(wavinessAnglesTemp);    
    wavinessAngles = wavinessAnglesTemp;
    printArray("Waviness angles    ", wavinessAnglesTemp);

    firstChildOffset = new float[maxGenerations];
    firstChildOffset = firstChildOffsetTemp;
    printArray("First child offset ", firstChildOffset);

    maxChildDiameter = new float[maxGenerations];
    maxChildDiameter = maxChildDiameterTemp;
    printArray("Max child diameter ", maxChildDiameter);

    leaveProbability = new float[maxGenerations];
    leaveProbability = leaveProbabilityTemp;
    printArray("Leave probability  ", leaveProbability);

    slim = new float[maxGenerations];
    slim = slimTemp;
    printArray("Slim               ", slim);

    phylotaxis = new float[maxGenerations];
    phylotaxisTemp = arrayToRadians(phylotaxisTemp);    
    phylotaxis = phylotaxisTemp;
    printArray("Phylotaxis         ", phylotaxisTemp);

    
  }

  void printArray(String name, float[] arrayName)
  {
    print(name + ":   ");    
    for (float x : arrayName)
      print(nf(x, 0, 2) + " ");
    println();
  }

  void printArray(String name, int[] arrayName)
  {
    print(name + ":   ");    
    for (int x : arrayName)
      print(nf(x, 2) + " ");
    println();
  }

  float[] arrayToRadians(float[] arrayName)
  {
    for (int i=0; i<arrayName.length; i++)
      arrayName[i] = radians(arrayName[i]);
    return arrayName;
  }

  void saveModifiersToFile() //Metoda wywołana raczej raz. Potem edytujemy ten plik i go ładujemy DO processingu
  {
    String[] modifiers = new String[12];
    modifiers[0] = "maxGenerations " + maxGenerations;
    modifiers[1] = arrayToEditableString(childrenAngles, "childrenAngles");
    modifiers[2] = arrayToEditableString(growthSpeedFactor, "growthSpeedFactor");
    modifiers[3] = arrayToEditableString(childrenProbability, "childrenProbability");
    modifiers[4] = arrayToEditableString(wavinessAngles, "wavinessAngles");
    modifiers[5] = arrayToEditableString(firstChildOffset, "firstChildOffset");
    modifiers[6] = arrayToEditableString(maxChildDiameter, "maxChildDiameter");
    modifiers[7] = arrayToEditableString(leaveProbability, "leaveProbability");
    modifiers[8] = arrayToEditableString(slim, "slim");
    modifiers[9] = arrayToEditableString(phylotaxis, "phylotaxis");
    modifiers[10] = "maxHeight " + maxHeight;    

    saveStrings("Mods/mods.dat", modifiers);
  }

  String arrayToEditableString(float[] arrayName, String name)
  {
    String outputString = name;

    for (int i=0; i<arrayName.length; i++)
    {
      outputString += " ";
      if (name == "childrenAngles" || name == "phylotaxis" || name == "wavinessAngles")
        arrayName[i] = round(degrees(arrayName[i]));
      outputString += arrayName[i];
    }
    return outputString;
  }

  String arrayToEditableString(int[] arrayName, String name)
  {
    String outputString = name;

    for (int i=0; i<arrayName.length; i++)
    {
      outputString += " ";
      outputString += arrayName[i];
    }
    return outputString;
  }

  //  void loadModifiersFromFile()
  //  {
  //    try 
  //    {
  //      String[] modifiers = loadStrings("Mods/mods.dat");
  //      maxGenerations = fromStringToRam(modifiers[0]);
  //      childrenAngles = fromStringToRam(modifiers[1]);
  //      growthSpeedFactor = fromStringToRam(modifiers[2]);
  //      childrenProbability = fromStringToRam(modifiers[3]);
  //      wavinessAngles = fromStringToRam(modifiers[4]);
  //      firstChildOffset = fromStringToRam(modifiers[5]);
  //      maxChildDiameter = fromStringToRam(modifiers[6]);
  //      leaveProbability = fromStringToRam(modifiers[7]);
  //      slim = fromStringToRam(modifiers[8]);
  //      phylotaxis = fromStringToRam(modifiers[9]);
  //      pruning = fromStringToRam(modifiers[10]);
  //      maxHeight = fromStringToRam(modifiers[11]);
  //    }
  //    catch(Exception e)
  //    {
  //    }
  //  }

  //  float[] fromStringToRam(String modifiers)
  //  {
  //    String[] stringArray = split(modifiers, " ");
  //    float[] outputArray = new float[stringArray.length - 1];
  //
  //    for (int i=1; i<stringArray.length; i++)
  //      outputArray[i-1] = float(stringArray);
  //    return outputArray;
  //  }
  //
  //  int[] fromStringToRam(String modifiers)
  //  {
  //    String[] stringArray = split(modifiers, " ");
  //    int[] outputArray = new int[stringArray.length - 1];
  //
  //    for (int i=1; i<stringArray.length; i++)
  //      outputArray[i-1] = int(stringArray);
  //    return outputArray;
  //  }
  //
  //  int fromStringToRam(String modifiers)
  //  {
  //    String[] stringArray = split(modifiers, " ");
  //    return stringArray[1];
  //  }
}