class Memory
{



  Memory()
  {
  }


  void saveTree(String mode)
  {
    String outputString;    
    String path;
    StringBuilder stream = new StringBuilder();    
    byte[] treeBinary;

    // Zmienne globalne:

    stream.append(currentSegment);
    stream.append(",");
    stream.append(currentBranch);
    stream.append(",");
    stream.append(growingBranch);
    stream.append("=");

    // Drzewo:

    for (int i=0; i<=currentBranch; i++) //Przechodzi liniowo przez wszystkie gałęzie
    {
      stream.append(tree.branches.get(i).branchIndex); //Zapamiętywanie zmiennych gałęzi
      stream.append(","); //Przecinek rozdziela kolejne wartości

      stream.append(tree.branches.get(i).branchGeneration);
      stream.append(",");

      stream.append(tree.branches.get(i).parentBranch);
      stream.append(",");

      stream.append(tree.branches.get(i).parentSegment);
      stream.append(",");

      stream.append(tree.branches.get(i).growingSegment);
      stream.append(",");

      stream.append(tree.branches.get(i).reachedMaxLength);
      stream.append(",");

      //      stream.append(tree.branches.get(i).hasGrown); // usunięta
      //      stream.append(",");

      stream.append(tree.branches.get(i).branchLength); // zamiast 7, teraz ta zmienna ma indeks 6

      stream.append(";"); //Delimiter różnych typów danych
      // Tablica dzieci

      for (int j=0; j<tree.branches.get(i).children.size(); j++) 
      {
        stream.append(tree.branches.get(i).children.get(j));
        if (j<tree.branches.get(i).children.size()-1) stream.append(",");
      }

      stream.append(";"); //Delimiter różnych typów danych  

      for (int j=0; j<tree.branches.get(i).segments.size(); j++)
      {
        stream.append(tree.branches.get(i).segments.get(j).branchIndex);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).branchGeneration);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).segmentIndex);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).segmentNumber);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).segmentBirth);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).soundSource);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).soundNumber);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).soundLength);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).matrix.m00);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).matrix.m01);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).matrix.m02);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).matrix.m03);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).matrix.m10);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).matrix.m11);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).matrix.m12);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).matrix.m13);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).matrix.m20);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).matrix.m21);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).matrix.m22);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).matrix.m23);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).matrix.m30);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).matrix.m31);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).matrix.m32);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).matrix.m33);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).hasLeave);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).leaveColor);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).segmentLength);
        stream.append(",");

        stream.append(tree.branches.get(i).segments.get(j).segmentDiameter);
        stream.append(",");       

        stream.append(tree.branches.get(i).segments.get(j).childIndex);        

        if (j < tree.branches.get(i).segments.size() - 1) stream.append(":"); //Dwukropek oddziela od siebie podbloki kolejnych segmentów
      }

      if (i < currentBranch) stream.append("_"); //Podkreślnik oddziela od siebie kolejne gałęzie
    }

    stream.append("="); //Delimiter różnych typów danych  

    // Tablica nazw folderów z krótkimi plikami dźwiękowymi, które utworzyły bieżące drzewo

    for (int j=0; j<tree.folders.size(); j++) 
    {
      stream.append(tree.folders.get(j));
      if (j<tree.folders.size()-1) stream.append(",");
    }


    outputString = stream.toString();
    treeBinary = outputString.getBytes();

    if (mode == "auto") 
    {
      path = "AutoSave/Auto_" + nf(year(), 4) + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "/tree_" + nf(hour(), 2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2) + ".sav";
    }
    else path = "Save/tree_" + nf(hour(), 2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2) + ".sav";
    lastSaved = path;
    saveLastSavedPath();

    saveBytes(path, treeBinary);
  }

  // ____________________________________________________

  void selectFile()  //tu zmiana nazwy
  {
//    String loadPath = selectInput("fileSelected"); //Działa w wersji 1.5.1; w 2.0 potrzebny jeszcze jeden argument, String
//    if (loadPath == null) 
//    {
//      println("Window was closed or the user hit cancel.");
//    }
//    else 
//      openTree(loadPath);
  }


  // ____________________________________________________

  void openTree(String path)
  {
    println(" :: Now loading save file from: " + path + " ...");
    byte[] treeBinary = loadBytes(path);
    String treeString = new String(treeBinary);      
    tree.branches.clear();
    tree.setInitialStateAfterOpen();
    // Oddziela blok zmiennych globalnych, lub inaczej header, od dancyh drzewa    
    String[] treeData = split(treeString, '=');

    String[] global = split(treeData[0], ',');
    currentSegment = int(global[0]);
    currentBranch = int(global[1]);
    growingBranch = int(global[2]); 

    //wydziela kolejne stringi kolejnych gałęzi    

    String[] branches = split(treeData[1], '_');  

    for (int i = 0; i < branches.length; i++) // fixme
    {
      //wydziela stringi: zmienne, tablica dzieci, tablica segmentów, segmenty
      String[] branchBlocks = split(branches[i], ';');  

      //oddziela od siebie wszystkie zmienne gałęzi
      String[] variables = split(branchBlocks[0], ',');       

      //oddziela od siebie elementy tablicy "dzieci"
      String[] children = split(branchBlocks[1], ',');   

      //wydziela kolejne stringi kolejnych segmentów...
      String[] segments = split(branchBlocks[2], ':');


      tree.branches.add(new Branch(int(variables[0]), int(variables[1]), int(variables[2]), int(variables[3])));
      tree.branches.get(i).growingSegment = int(variables[4]);
      tree.branches.get(i).reachedMaxLength = boolean(variables[5]);
      //      tree.branches.get(i).hasGrown = boolean(variables[6]); // usunięta zmienna
      tree.branches.get(i).branchLength = float(variables[6]); // teraz ma numer 6, wcześniej 7!!

      if (int(variables[4]) != 0)
      {
        for (int j=0; j < children.length; j++)
          tree.branches.get(i).children.add(int(children[j]));

        //... a z tych segmentów wydziela zmienne segmentów:
        for (int j=0; j < segments.length; j++) // fixme
        {
          String[] var = split(segments[j], ',');
          PMatrix3D matrix = new PMatrix3D(float(var[8]), float(var[9]), float(var[10]), float(var[11]), 
          float(var[12]), float(var[13]), float(var[14]), float(var[15]), 
          float(var[16]), float(var[17]), float(var[18]), float(var[19]), 
          float(var[20]), float(var[21]), float(var[22]), float(var[23]));

          //                                            branch ind.  generation   seg ind.     seg. num     seg birth      snd source   snd num      snd length   matrix  has leave?        leave color
          tree.branches.get(i).segments.add(new Segment(int(var[0]), int(var[1]), int(var[2]), int(var[3]), float(var[4]), int(var[5]), int(var[6]), int(var[7]), matrix, boolean(var[24]), int(var[25])));

          tree.branches.get(i).segments.get(j).segmentLength = float(var[26]);
          tree.branches.get(i).segments.get(j).segmentDiameter = float(var[27]);
          tree.branches.get(i).segments.get(j).childIndex = int(var[28]);
        }
      }

      //wydziela kolejne komórki tablicy folders  

      String[] folders = split(treeData[1], ','); 

      for (int j=0; j < folders.length; j++)
        tree.folders.add(int(folders[j]));
    }
    println(" :: Done");
  }


  // ____________________________________________________

//  void setPaths()
//  {
//    //0 - remote path
//    //1 - local path
//    String[] metaData;
//    String[] toSave = new String[2];
//
//    try
//    {
//      metaData = loadStrings("MetaData/paths.dat");  
//
//      String remotePath = selectFolder("Select path of the remote audio folder");
//      String localPath = selectFolder("Select path of the local audio folder");
//
//
//      if (remotePath != null)  
//      {          
//        toSave[0] = remotePath;
//        println(toSave[0]);
//      }  
//      else if (metaData == null) toSave[0] = "not set";
//      else toSave[0] = metaData[0];
//
//      if (localPath != null)
//      {
//        toSave[1] = localPath;
//        println(toSave[1]);
//      }
//      else if (metaData == null) toSave[1] = "not set";
//      else toSave[1] = metaData[1];
//
//      if (remotePath != null || localPath != null)
//      {
//        println("Saving meta data");
//        saveStrings("MetaData/paths.dat", toSave);
//      }
//    }
//    catch(Exception e)
//    {
//    }
//  }

  void saveLastSavedPath()
  {  
    String[] strings = {
      lastSaved
    };

    try
    {
      saveStrings("MetaData/lastSaved.dat", strings);
    }
    catch(Exception e)
    {
    }
  }

  void openLastSaved()
  {
    String[] lastSaved = {
    };
    String path;
    try
    {
      lastSaved = loadStrings("MetaData/lastSaved.dat");
      path = lastSaved[0];
      openTree(path);
    }
    catch(Exception e)
    {
      println("No information about last saved file");
    }
  }

  void saveTreeFrame()
  {
    String pathAndName;
    pathAndName = "SavedFrames/frame_" + year() + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "_" + nf(hour(), 2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2) + ".tiff";
    saveFrame(pathAndName);
  }
}