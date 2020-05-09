class OscRec
{
  OscP5 oscP5Rec;
  NetAddress pureDataIPRec;

  OscRec()
  {
    oscP5Rec = new OscP5(this, 5007); // fixme zmień na 7777
    pureDataIPRec = new NetAddress("127.0.0.1", 5004);
  }

  void oscEvent(OscMessage recorded) 
  {
    if (recorded.checkAddrPattern("/rec")==true)
    {
      int soundSource = recorded.get(0).intValue(); // Numer źródła dźwięku
      int soundNumber = recorded.get(1).intValue(); // Numer pliku - niepowtarzalny w ramach jednego źródła dźwięku    
      int soundLength = recorded.get(2).intValue(); // Długość dźwięku w milisekundach

      println("    [ M ] PD-Rec -> Message Received: " + recorded.addrPattern() + " " + soundSource + " " + soundNumber + " " + soundLength);

      if (isRun)
      {
        if (platform == "pc")    
        {
          tree.stepGrowth(soundSource, soundNumber, soundLength);
        }

        if (platform == "mac")
        {

          String target = pdLocalFolder + soundSource + "/" + soundNumber + ".wav";
          String source = pdRemoteFolder + soundSource + "/" + soundNumber + ".wav";
          String[] command = {
            "cp", source, target
          };  

          try 
          {
            Process copyProcess = exec(command);
            tree.stepGrowth(soundSource, soundNumber, soundLength);
            try 
            {
              int copyResult = copyProcess.waitFor();
              if (copyResult != 0)
                println("ERROR: copy failed 1");
            } 
            catch (Exception e) {
              println("ERROR: copy failed 2");
            }
          } 
          catch (Exception e) {
            println("ERROR: copy failed 3");
          }
        }
      }
    }

    if (recorded.checkAddrPattern("/look") == true) // PD nadaje sygnał o rozpoczęciu nagrania. Momentalnie kamera kieruje się na punkt w którym urośnie następny segment
    {
//      println("    [ M ] PD-Rec -> Message Received: LOOK at next");
      tree.searchForNextGrowingBranch();
    }
  }
}

// ==============================================================

class OscPlay
{
  OscP5 oscP5Play;
  NetAddress pureDataIPPlay;

  int messageNumber = 0;

  OscPlay()
  {
    oscP5Play = new OscP5(this, 5008);
    pureDataIPPlay = new NetAddress("127.0.0.1", 8888);
  }

  void updateSound(int nameTemp, int atBranchTemp, int atSegmentTemp)
  {
    OscMessage updateSound = new OscMessage("/play"); // fixme teraz jest tylko jeden komunikat (nie ma load). Zapdejtuj to w PD

    updateSound.add(nameTemp);        // identyfikator wiewiórki 0-3
    updateSound.add(messageNumber);   // numer komunikatu - dzięki temu co się dzieje?
    updateSound.add(tree.branches.get(atBranchTemp).segments.get(atSegmentTemp).getSoundSource());
    updateSound.add(tree.branches.get(atBranchTemp).segments.get(atSegmentTemp).getSoundNumber());    
    updateSound.add(tree.branches.get(atBranchTemp).segments.get(atSegmentTemp).getAzimuth());
    updateSound.add(tree.branches.get(atBranchTemp).segments.get(atSegmentTemp).getDistance());
    updateSound.add(tree.branches.get(atBranchTemp).segments.get(atSegmentTemp).getDiameter());

    oscP5Play.send(updateSound, pureDataIPPlay);

    messageNumber++;
    if (messageNumber > 1023) messageNumber = 0; // fixme może niepotrzebne?
  }

  //void updateCamAzimuth()
  //{
  //  OscMessage updateCamAzimuth = new OscMessage("/camera");
  //  float x = 0, z = 0;
  //  float[] position = cam.getPosition();
  //  x = position[0] - (width/2);
  //  z = position[2];
  //  float azimuth = 0;    
  //  if (x == 0 && z < 0) azimuth = 0;
  //  else if (x == 0 && z >= 0) azimuth = 180;
  //  else azimuth = degrees(atan2(z, x)) + 90;

  //  updateCamAzimuth.add(azimuth-180); // -90 do 270 stopnim, ale to nie duży problem

  //  oscP5Play.send(updateCamAzimuth, pureDataIPPlay);
  //}


  //  void oscEvent(OscMessage fromPd) // komunikaty służące do kontrolowania processingiem z pacza PD-Play
  //  {
  //    if (fromPd.checkAddrPattern("/controlFromPd")==true)
  //    {
  //      int value = fromPd.get(0).intValue();
  //      switch(value)
  //      {
  //      case 0: 
  //        println("    [ M ] PD-Play -> Processing: Requested loading sounds");
  //        tree.alf.updateSquirrel(); 
  //        tree.bill.updateSquirrel();
  //        tree.chip.updateSquirrel();
  //        tree.dale.updateSquirrel();
  //        break;
  //      case 1: 
  //        autoTraverse = true; 
  //        println("    [ M ] PD-Play -> Processing: Autotraverse started BY PD!!"); 
  //        break;
  //      case 2: 
  //        autoTraverse = false; 
  //        println("    [ M ] PD-Play -> Processing: Autotraverse stopped BY PD!!"); 
  //        break;
  //      case 3: 
  //        isRun = true; 
  //        println("    [ M ] PD-Play -> Processing: Installation started BY PD!!"); 
  //        break;
  //      case 4: 
  //        isRun = false; 
  //        println("    [ M ] PD-Play -> Processing: Installation stopped BY PD!!"); 
  //        break;
  //      case 5:
  //      }
  //    }
  //    else if (fromPd.checkAddrPattern("/diagnosticsFromPDPlay")==true)
  //    {
  //
  //      int granulesUsed = fromPd.get(0).intValue();
  //      int cpuUsed = fromPd.get(1).intValue();
  //      int left = fromPd.get(2).intValue();
  //      int right = fromPd.get(3).intValue();
  //      int rearLeft = fromPd.get(4).intValue();
  //      int rearRight = fromPd.get(5).intValue();
  //      println("    [ M ] PD-Play -> Processing: diagnostics: " + granulesUsed + " grans used, left level: " + left + " dB, right level: " + right);
  //      log.sendDiagnosticMail(granulesUsed, cpuUsed, left, right, rearLeft, rearRight);
  //    }
  //  }
}