class Generator
{
  ArrayList<File[]> listOfLists;
  File[] pdDirectory, recordingsDirectory, recordingsWithoutMarkersDirectory;
  File folder, recordingsFolder, recordingsWithoutMarkersFolder;
  String subdirectory;
  int totalSubdirectories = 0; // z tylu źródeł dotychczas wygenerowano gałęzie

  Generator()
  {
  }

  void generateFromFolders()
  {     
    // Directory path here
    String path = "D:\\___Programowanie\\Processing 3\\Drzewo_PD"; 

    File folder = new File(path);
    listOfLists = new ArrayList(0);

    pdDirectory = folder.listFiles(); // tworzy listę - tablicę obiektów File - podfolderów z plikami wave (0, 1, 2...)

    println(" :: now generating a new tree from .wav files inside a PD folder");

    int k = 0;
    for (int i = 0; i < pdDirectory.length; i++) // Teraz dla każdego z tych podfolderów:
    {
      subdirectory = pdDirectory[i].getName(); // wyciąga nazwę z obiektu File

      //jeśli ten podfolder ma odpowiednią nazwę:
      if (pdDirectory[i].isDirectory() && subdirectory.equals("Puste katalogi") == false && subdirectory.equals("k") == false 
        && subdirectory.equals("Record") == false && subdirectory.equals("recordings") == false && subdirectory.equals("recordingsWithoutMarkers") == false 
        && checkIfGenerated(subdirectory) == false)
      {
        println("|_ subdirectory: " + subdirectory);
        int folderName = Integer.parseInt(subdirectory);
        listOfLists.add(new File(path + "\\" + subdirectory).listFiles()); //utwórz listę plików .wav. listOfLists to tablica tablic plików wave.
        // zawiera tylko listy plików .wave z podfolderów numerycznych
        k++; // licznik liczący ilość podfolderów. Liczy od jedynki!

        for (int j = 0; j < listOfLists.get(k-1).length; j++) // teraz przeszukaj kolejne listy list, czyli sporządź listę plików
        {
          println(" |_ " + listOfLists.get(k-1)[j].getName());

          String[] nameWithoutExtension = listOfLists.get(k-1)[j].getName().split("\\.");
          int fileName = Integer.parseInt(nameWithoutExtension[0]);
          //          println("    Folder: " + folderName + " File: " + fileName);

          tree.branchGrowth(folderName, fileName, 2000);
        }
        tree.folders.add(folderName);
      }
    }
    //    if (listOfLists.size() > 0)
    //      totalSubdirectories = listOfLists.size();
    //    println(totalSubdirectories);
  }

  boolean checkIfGenerated(String subdirectory)
  {
    boolean check = false;
    int name = Integer.parseInt(subdirectory);

    for (int i=0; i < tree.folders.size(); i++)
    {
      if (name == tree.folders.get(i))
      {
        check = true;        
        println("Folder no " + name + " has generated some segments");
        break;
      }
    }
    return check;
  }

  boolean checkIfDivided(String fileName)
  {
    boolean check = false;
    String[] divided = {
    };

    try
    {
      divided = loadStrings("MetaData/divided.dat");
    }
    catch(Exception e)
    {
      println("No information about divided files");
    }

    for (int i=0; i<divided.length; i++)
    {
      if (divided[i].equals(fileName))
      {
        check = true;
        //        println("File no " + fileName + " has already been divided");
        break;
      }
    }

    return check;
  }

  void confirmDivision(String fileName)
  {
    boolean check = false;
    String[] divided = {
    };

    try
    {
      divided = loadStrings("MetaData/divided.dat");
    }
    catch(Exception e)
    {
      println("No information about divided files");
    }

    String[] newDivided = append(divided, fileName);
    saveStrings("MetaData/divided.dat", newDivided);
  }

  void divideRecordings()
  {
    String path = "D:\\___Programowanie\\Processing 3\\Drzewo_PD\\recordings"; 

    File recordingsFolder = new File(path);

    recordingsDirectory = recordingsFolder.listFiles(); // tworzy listę - tablicę obiektów File - podfolderów z plikami wave (0, 1, 2...)

    println(" :: now displaying list of recordings\n|_ recordings");

    for (int i = 0; i < recordingsDirectory.length; i++)
    {
      String name = recordingsDirectory[i].getName(); // wyciąga nazwę z obiektu File
      print("  |_ " + name);
      if (checkIfDivided(name))
        print(" - already divided\n");
      else 
      {
        print(" dividing...");
        divide(name);
        print(" done\n");
      }
    }

    path = "D:\\___Programowanie\\Processing 3\\Drzewo_PD\\recordingsWithoutMarkers"; 

    File recordingsWithoutMarkersFolder = new File(path);

    recordingsWithoutMarkersDirectory = recordingsWithoutMarkersFolder.listFiles(); // tworzy listę - tablicę obiektów File - podfolderów z plikami wave (0, 1, 2...)

    println(" :: now displaying list of recordings without markers\n|_ recordingsWithoutMarkers");

    for (int i = 0; i < recordingsWithoutMarkersDirectory.length; i++)
    {
      String name = recordingsWithoutMarkersDirectory[i].getName(); // wyciąga nazwę z obiektu File
      print("  |_ " + name);
      if (checkIfDivided(name))
        print(" - already divided\n");
      else 
      {
        print(" dividing...");
        divideWithoutMarkers(name);
        print(" done\n");
      }
    }
  }

  void divide(String recordingName)
  {
    byte recording[] = loadBytes("D:\\___Programowanie\\Processing 3\\Drzewo_PD\\recordings\\" + recordingName);
    int[] markers = getMarkerPositions(recording);    
    createAudioFile(recording, markers, recordingName);

    confirmDivision(recordingName);
  }

  void divideWithoutMarkers(String recordingName)
  {
    byte recording[] = loadBytes("D:\\___Programowanie\\Processing 3\\Drzewo_PD\\recordingsWithoutMarkers\\" + recordingName);
    createAudioFileWithoutMarkers(recording, recordingName);
    confirmDivision(recordingName);
  }


  void createAudioFile(byte[] recording, int[] markers, String recordingName)
  {    
    int sampleNumber = 0;
    int waveDataSize = 0;
    byte[] waveData;

    byte[] newFileHeader = createHeader(441000);

    for (int k = 0; k <= 3; k++)
    {
      waveDataSize += int(recording[32764 + k]) * pow(256, k);
    }

    for (int i=0; i<markers.length; i++)
    {
      //      println("Checking marker " + i + " pos " + markers[i]);
      waveData = new byte[882000];
      for (int j = 0; j < 441000; j++) //sprawdzamy kolejne sample stereo (kolejne 4Bajtowe słowa)
      {
        int pos = 32768 + j*4 + markers[i] - 882000; // 882000 to 5 sekund stereo 16 bit
        if (pos <= 0 || pos >= waveDataSize) //fixme
        {
          waveData[(j * 2)] = byte(0);
          waveData[(j * 2) + 1] = byte(0);
        } else
        {
          waveData[(j * 2)] = recording[pos];
          waveData[(j * 2) + 1] = recording[pos+1];
        }
      }
      byte[] newFile = concat(newFileHeader, waveData);
      String[] newFolderName = recordingName.split("\\.");
      println("New folder name: " + newFolderName[0] + " splitted from " + newFolderName[1]);

      String newName = "D:\\___Programowanie\\Processing 3\\Drzewo_PD\\" + newFolderName[0] + "\\" + str(i) + ".wav";
      saveBytes(newName, newFile);
    }
  }

  void createAudioFileWithoutMarkers(byte[] recording, String recordingName) //dzieli plik automatycznie na 10 sekundowe pliki
  {    
    int sampleNumber = 0;
    int waveDataSize = 0;
    byte[] waveData;
    int i=0;
    int dataChunk = 0;

    byte[] newFileHeader = createHeader(441000);

    for (int n = 0; n < recording.length; n++)
    {
      if (char(recording[n]) == 'd')
      {
        dataChunk = i + 4;
        println("Data chunk starts at " + dataChunk);
        break;
      }
    }

    for (int k = 0; k <= 3; k++)
    {
      waveDataSize += int(recording[dataChunk + k]) * pow(256, k);
    }
    println("Wave data size: " + waveDataSize);

    for (int byteNumber = 882000; byteNumber < waveDataSize - 882000; byteNumber += 1764000)
    {
      print("Byte number: " + byteNumber);
      waveData = new byte[882000];
      for (int j = 0; j < 441000; j++) //sprawdzamy kolejne sample stereo (kolejne 4Bajtowe słowa)
      {
        int pos = j*4 + byteNumber; // 882000 to 5 sekund stereo 16 bit
        if (pos <= 0 || pos >= recording.length - 44)
        {
          waveData[(j * 2)] = byte(0);
          waveData[(j * 2) + 1] = byte(0);
        } else
        {
          waveData[(j * 2)] = recording[pos];
          waveData[(j * 2) + 1] = recording[pos+1];
        }
      }
      i++;
      byte[] newFile = concat(newFileHeader, waveData);
      String[] newFolderName = recordingName.split("\\.");
      println("New folder name: " + newFolderName[0] + " splitted from " + newFolderName[1]);
      String newName = "D:\\___Programowanie\\Processing 3\\Drzewo_PD\\" + newFolderName[0] + "\\" + str(i) + ".wav";
      saveBytes(newName, newFile);
      println("Made file: " + newFolderName[0] + "\\" + str(i) + ".wav");
    }
  }


  int[] getMarkerPositions(byte[] recording)
  {
    int j = 32764;
    int waveDataSize = 0;
    int totalMarkers = 0;
    int[] markers;

    for (int k = 0; k <= 3; k++)
    {
      waveDataSize += int(recording[j+k]) * pow(256, k);
    }
    j = 32768 + waveDataSize + 8;

    try {
      for (int k = 0; k <= 3; k++)
      {
        totalMarkers += int(recording[j+k]) * pow(256, k);
      }
      //    println("Total markers = " + totalMarkers + "\n");
    }
    catch(Exception e)
    {
    }

    markers = new int[totalMarkers];

    j += 4;

    int temp = 0;
    for (int m = 0; m < totalMarkers; m++)
    {
      for (int k = 0; k <= 3; k++)
      {
        temp += int(recording[j + (m * 24) + k]) * pow(256, k);
      }
      //      print("Marker index: " + (m) + " name: " + temp);
      temp = 0;

      for (int k = 0; k <= 3; k++)
      {
        temp += int(recording[j + 4 + (m * 24) + k]) * pow(256, k);
      }
      int bytePosition = temp * 4;
      String startTime = nf((float(temp) / 44100), 3, 3);
      //      print(" sample nr: " + temp + ", byte nr: " + bytePosition + ", start time: " + startTime + " [s]");
      temp = 0;

      markers[m] = bytePosition;

      println();
    }

    return markers;
  }

  byte[] createHeader(int soundDataLength)
  {
    byte[] newFileHeader = new byte[44];
    int modulo = 0, number = 0;

    newFileHeader[0] = byte('R');
    newFileHeader[1] = byte('I');
    newFileHeader[2] = byte('F');
    newFileHeader[3] = byte('F');    

    // File size (441036 Bytes)
    modulo = 0;
    number = soundDataLength + 36;

    for (int i=7; i>=4; i--)
    {      
      modulo = int(number / pow(2, (i-4)*8 ));
      newFileHeader[i] = byte(modulo);
      number -= modulo * int(pow(2, (i-4)*8 ));
    }
    print("Size: ");
    for (int i=7; i>=4; i--)
    {
      print(hex(newFileHeader[i]));
    }

    newFileHeader[8] = byte('W');
    newFileHeader[9] = byte('A');
    newFileHeader[10] = byte('V');
    newFileHeader[11] = byte('E');

    // ============ SUBCHUNK 1 =============

    newFileHeader[12] = byte('f');
    newFileHeader[13] = byte('m');
    newFileHeader[14] = byte('t');
    newFileHeader[15] = byte(' ');

    // Subchunk 2 size (16 Bytes)
    modulo = 0;
    number = 16;
    for (int i=19; i>=16; i--)
    {
      modulo = int(number / pow(2, (i-16)*8 ));
      newFileHeader[i] = byte(modulo);
      number -= modulo * int(pow(2, (i-16)*8 ));
    }
    print("\nNew subchunk1 size: ");
    for (int i=19; i>=16; i--)
    {
      print(hex(newFileHeader[i]));
    }

    // Audioformat (1)    
    modulo = 0;
    number = 1;
    for (int i=21; i>=20; i--)
    {
      modulo = int(number / pow(2, (i-20)*8 ));
      newFileHeader[i] = byte(modulo);
      number -= modulo * int(pow(2, (i-20)*8 ));
    }
    print("\nNew audio format: ");
    for (int i=21; i>=20; i--)
    {
      print(hex(newFileHeader[i]));
    }

    // Channels (mono = 1)
    modulo = 0;
    number = 1;
    for (int i=23; i>=22; i--)
    {
      modulo = int(number / pow(2, (i-22)*8 ));
      newFileHeader[i] = byte(modulo);
      number -= modulo * int(pow(2, (i-22)*8 ));
    }
    print("\nNew chan num: ");
    for (int i=23; i>=22; i--)
    {
      print(hex(newFileHeader[i]));
    }

    // Sample rate (44100)
    modulo = 0;
    number = 44100;
    for (int i=27; i>=24; i--)
    {
      modulo = int(number / pow(2, (i-24)*8 ));
      newFileHeader[i] = byte(modulo);
      number -= modulo * int(pow(2, (i-24)*8 ));
    }
    print("\nNew sampleRate: ");
    for (int i=27; i>=24; i--)
    {
      print(hex(newFileHeader[i]));
    }

    // Byte rate (88200 - mono @16bit)
    modulo = 0;
    number = 88200;
    for (int i=31; i>=28; i--)
    {
      modulo = int(number / pow(2, (i-28)*8 ));
      newFileHeader[i] = byte(modulo);
      number -= modulo * int(pow(2, (i-28)*8 ));
    }
    print("\nNew byteRate: ");
    for (int i=31; i>=28; i--)
    {
      print(hex(newFileHeader[i]));
    }

    // Block align (2 Bytes per sample)
    modulo = 0;
    number = 2;
    for (int i=33; i>=32; i--)
    {
      modulo = int(number / pow(2, (i-32)*8 ));
      newFileHeader[i] = byte(modulo);
      number -= modulo * int(pow(2, (i-32)*8 ));
    }
    print("\nNew block align: ");
    for (int i=33; i>=32; i--)
    {
      print(hex(newFileHeader[i]));
    }

    // Bits per sample (16)
    modulo = 0;
    number = 16;
    for (int i=35; i>=34; i--)
    {
      modulo = int(number / pow(2, (i-34)*8 ));
      newFileHeader[i] = byte(modulo);
      number -= modulo * int(pow(2, (i-34)*8 ));
    }
    print("\nNew bits per sample: ");
    for (int i=35; i>=34; i--)
    {
      print(hex(newFileHeader[i]));
    }

    newFileHeader[36] = byte('d');
    newFileHeader[37] = byte('a');
    newFileHeader[38] = byte('t');
    newFileHeader[39] = byte('a');

    // Data subchunk size (882000, 441000 sampli, każdy po 2 Bajty)
    modulo = 0;
    number = 2 * soundDataLength; 
    for (int i=43; i>=40; i--)
    {
      modulo = int(number / pow(2, (i-40)*8 ));
      newFileHeader[i] = byte(modulo);
      number -= modulo * int(pow(2, (i-40)*8 ));
    }
    print("\nNew subchunk2 size: ");
    for (int i=43; i>=40; i--)
    {
      print(hex(newFileHeader[i]));
    }

    return newFileHeader;
  }
}