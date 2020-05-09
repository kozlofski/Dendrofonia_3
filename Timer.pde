class Timer
{
  float autoSavePrevious, autoSaveInterval = 60000;
  float alfPrevious = 0, alfInterval = 12000;
  float billPrevious, billInterval = 12205;
  float chipPrevious, chipInterval = 12307;
  float dalePrevious, daleInterval = 12408;

  Timer()
  {
  }

  void check()
  {
    if (isRun == true && millis() >= autoSavePrevious + autoSaveInterval)
    {
      memory.saveTree("auto");
      autoSavePrevious = millis();
    }
    
    if (isRun == true && millis() >= alfPrevious + alfInterval) //Alf chodzi po całym drzewie, głównie do manualnego przechodzenia
    {
      tree.alf.autoTraverse(1, 0.2, 0.8);
      alfPrevious = millis();
    }
    
    if (isRun == true && millis() >= billPrevious + billInterval) //Bill chodzi po całym drzewie
    {
      tree.bill.autoTraverse(1, 0.2, 0.6);
      billPrevious = millis();
    }
    
    if (isRun == true && millis() >= chipPrevious + chipInterval) //Chip chodzi tylko po koronie, omijając pień
    {
      tree.chip.autoTraverse(2, 0.2, 0.1);
      chipPrevious = millis();
    }
    
    if (isRun == true && millis() >= dalePrevious + daleInterval) //Dale chodzi tylko po pniu
    {
      tree.dale.autoTraverse(3, 0.2, 0.6);
      dalePrevious = millis();
    }
    
  }
}