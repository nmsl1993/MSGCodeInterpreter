boolean ProcessComment (char instruction[], int size) {

  // the / character means delete block... used for comments and stuff
  //==================================================================
  if (instruction[0] == '/') {
    if (DebugLevel > 1) {
      Serial.println("/ comment");
    }
  }
  return true;
}
