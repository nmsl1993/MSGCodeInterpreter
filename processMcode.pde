boolean ProcessMcode(char instruction[], int size) {

  float ParameterValue;

  // find which M code
  //==================
  code = search_string('M', instruction, size);
  switch (code) {

//========================================================================

    case -1:  // no code found
      return true;
      break;

// M0 ========================================================================

    case 0: // program stop
      if (DebugLevel > 1)
        Serial.println("program stop");
      
      // finished with engines
      //======================
      //      StopSpindle();
      disable_steppers();
      return true;
      break;

// M2 ========================================================================

    case 2:  //program end
      if (DebugLevel > 1)
        Serial.println("program end");

      // finished with engines
      //======================
     // StopSpindle();
      disable_steppers();
      return true;
      break;

// M3 ========================================================================

    case 3:  // turn spindle clockwise
      if (DebugLevel > 1)
        Serial.println("turn spindle clockwise");

      // gentlemen, start your engines
      //==============================
   //   StartSpindle(true);
      return true;
      break;

// M4 ========================================================================

    case 4:  // turn spindle anti-clockwise
      if (DebugLevel > 1)
        Serial.println("turn spindle anti-clockwise");

      // gentlemen, start your engines
      //==============================
   //   StartSpindle(false);
      return true;
      break;

// M5 ========================================================================

    case 5:  // stop spindle
      if (DebugLevel > 1)
        Serial.println("stop spindle");

      // stop the spindle
      //=================
  //    StopSpindle();
      return true;
      break;

// M110 ========================================================================

    case 110:  // set line number
      // since this arrives with an "N" line number, there's nothing to do!
      //===================================================================
      if (DebugLevel > 1) {
        Serial.print("set line number: ");
        Serial.println(line, DEC);
      }
      return true;
      break;

// M111 ========================================================================

    case 111:  // set debug level
      ParameterValue = search_string('P', instruction, size);
      DebugLevel = ParameterValue;
      if (DebugLevel > 1) {
        Serial.print("debug level ");
        Serial.println(DebugLevel, DEC);
      }
      return true;
      break;
 }
}   // end of M code processing
    //=========================



