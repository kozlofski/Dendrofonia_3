class Keys
{
  Keys()
  {
  }

  void keys(char keyTemp)
  {
    switch(keyTemp)
    {
    case 'q':
      if (isRun == false)
        tree.fastGrowth();
      else println(" :: turn installation off first to grow tree manually.");
      break;
    case 'Q':
      if (isRun == false)
        tree.turboGrowth();
      else println(" :: turn installation off first to grow tree manually.");
      break;
    case 'w':
      if (isRun == false)
        tree.megaTurboGrowth();
      else println(" :: turn installation off first to grow tree manually.");
      break;
    case 'W':
      if (isRun == false)
        tree.ultraTurboGrowth();
      else println(" :: turn installation off first to grow tree manually.");
      break;      
    case 'X':
      println(" :: deleting tree.");
      tree.deleteTree();      
      redraw();
      break;
    case 'R': // fixme pod R będzie polecenie Reconstruct - na podstawie pliku *.rec
      println(" :: regenerating random tree.");
      tree.regenerateTree();
      redraw();
      break;
    //case 'C': //ustaw tryb pracy kamery
    //  cameraMode++;      
    //  if (cameraMode == 5) cameraMode = 0;
    //  println(" :: camera mode: " + cameraMode);
    //  switch(cameraMode)
    //  {
    //  case 0: 
    //    cam.setYawRotationMode(); 
    //    break;
    //  case 1: 
    //    cam.setFreeRotationMode(); 
    //    break;
    //  case 2: 
    //    cam.setPitchRotationMode(); // like a somersault
    //    break;
    //  case 3:
    //    cam.setRollRotationMode();  // like a radio knob
    //    break;
    //  case 4:
    //    cam.setSuppressRollRotationMode();  // Permit pitch/yaw only
    //    break;
      //}
      //break;
    //case 'c': // centrowanie kamery na następny rosnący segment
    //  if (cameraCentering)
    //  {
    //    cameraCentering = false;
    //    println(" :: camera centering OFF");
    //  }
    //  else
    //  {
    //    cameraCentering = true;
    //    println(" :: camera centering ON");
    //  }
      //break;
    case 'u':
    case 'j':
    case 'i':
    case 'y':
    case 'h':
    case 'm':
      switch(selectSquirrel)
      {
      case 0:
        tree.alf.doSomething(keyTemp);
        break;
      case 1:
        tree.bill.doSomething(keyTemp);
        break;
      case 2:
        tree.chip.doSomething(keyTemp);
        break;
      case 3:
        tree.dale.doSomething(keyTemp);
        break;
      }
      break;
    case '0':
    case '1':
    case '2':
    case '3':
      selectSquirrel = int(keyTemp - 48);
      println(" :: squirrel selected: " + selectSquirrel);
      break;
    case 'S':
      memory.saveTree("manual");
      break;      
    case 'O':
      memory.selectFile();
      tree.drawTree();
      break;    
//    case 'P':
//      memory.setPaths();
//      break;
    case 'L':
      memory.openLastSaved();
      break;
    case '$':
      tree.mod.saveModifiersToFile();
      break;
    case ' ':
      if (isRun) 
      {
        isRun = false; 
        println(" :: instalation stopped");
      }
      else 
      {
        isRun = true; 
        println(" :: instalation started. Listening to incoming rec messages");
      }
    case 'F':
      memory.saveTreeFrame();
      break;
      //    case 'f':
      //      tree.dale.goTo();
      //      break;
    case 'l': // l jak lama
      tree.searchForNextGrowingBranch();
      break;
    case 'H': // rysuj HUD
      if (hud == false)
      {
        hud = true;
        println(" :: HUD on");
      }
      else
      {
        hud = false;
        println(" :: HUD off");
      }
      break;
    case 'g': // wygeneruj nowe drzewo z plików wave kasując poprzednie
      tree.setInitialState();
      generator.generateFromFolders();
      break;
    case 'A': // od ADD dodaj nowo utworzone foldery. Poniższa funkcja wie, czy z danego folderu utworzono segmenty
      generator.generateFromFolders();
      break;
    case 'D':
      generator.divideRecordings();
      break;
    case 'G': // połączenie 'D' i 'A'
      generator.divideRecordings();
      generator.generateFromFolders();
      break;
    }
  }
}