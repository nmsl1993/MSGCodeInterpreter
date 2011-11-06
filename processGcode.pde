FloatPoint current_units;
FloatPoint target_units;
FloatPoint delta_units;

FloatPoint current_steps;
FloatPoint target_steps;
FloatPoint delta_steps;
FloatPoint abs_speed;

// default to inches for units
//============================
float x_units = X_STEPS_PER_INCH;
float y_units = Y_STEPS_PER_INCH;
float z_units = Z_STEPS_PER_INCH;
float curve_section = CURVE_SECTION_MM / MM_PER_INCH;

// our feedrate variables
///======================
float feedrate;
long feedrate_micros;
float FastFeedRateXY;
float FastFeedRateZ;

boolean ProcessGcode (char instruction[], int size) {
  
  float ParameterValue;
  float angleA, angleB, angle, radius, length, aX, aY, bX, bY;
  long steps, s, one_step;
  long p;
  FloatPoint newPoint;
  FloatPoint fp;


  feedrate = 0.0;
  feedrate_micros = 0;
  
  // find which G code
  //==================
  code = (int)search_string('G', instruction, size);

  // Get co-ordinates if required by the code type given
  // G0 G1 G2 G3 all need co-ordinates
  //====================================================
  switch (code) {
  case 0:  // rapid position
  case 1:  // linear interpolation
  case 2:  // circular interpolation (clockwise)
  case 3:  // circular interpolation (anti-clockwise)
    if(abs_mode) {
      // we do it like this to save time. makes curves better
      // eg. if only x and y are specified, we dont have to waste time looking up z.
      //============================================================================

      if (has_command('X', instruction, size))
        fp.x = search_string('X', instruction, size);
      else
        fp.x = current_units.x;

      if (has_command('Y', instruction, size))
        fp.y = search_string('Y', instruction, size);
      else
        fp.y = current_units.y;

      if (has_command('Z', instruction, size))
        fp.z = search_string('Z', instruction, size);
      else
        fp.z = current_units.z;
    }
    else {
      fp.x = search_string('X', instruction, size) + current_units.x;
      fp.y = search_string('Y', instruction, size) + current_units.y;
      fp.z = search_string('Z', instruction, size) + current_units.z;
    }
    break;
  }
  // now execute command
  //====================
  switch (code) {

// G0 G1 ========================================================================

    // Rapid Positioning
    // Linear Interpolation
    // these are basically the same thing.
    //====================================
  case 0:  // rapid position
  case 1:  // linear interpolation

    // set our target
    //===============
    set_target(fp.x, fp.y, fp.z);

    // do we have a set speed?
    //========================
    switch (code) {
    case 0:
      break;
        
    case 1:
      break;
    }

    // finally execute the move
    //=========================
    dda_move();

    if (DebugLevel > 1) {
      if (has_command('X', instruction, size)) {
        Serial.print("X: ");
        Serial.print(fp.x, 4);
      }
      if (has_command('Y', instruction, size)) {
        Serial.print(" Y: ");
        Serial.print(fp.y, 4);
      }
      if (has_command('Z', instruction, size)) {
        Serial.print(" Z: ");
        Serial.print(fp.z, 4);
      }
      if (has_command('F', instruction, size)) {
        Serial.print(" F: ");
        Serial.print(float(feedrate), 4);
      }
      Serial.println("");
    }

    break;

// G20 ========================================================================

  case 20:  // Inches for Units
    if (DebugLevel > 1)
      Serial.println("units inches");
    UnitsInches();
    if (DebugLevel > 1) {
      DebugUnits();
    };
    break;

// G21 ========================================================================

  case 21:  // mm for Units
    if (DebugLevel > 1)
      Serial.println("units mm");
    UnitsMM();
    if (DebugLevel > 1) {
      DebugUnits();
    };
    break;

// G28 ========================================================================

  case 28:  // go home
    if (DebugLevel > 1) {
      Serial.println("go to end stops");
    };
    set_target(0.0, 0.0, 0.0);
    dda_move();

    break;

// G999 ========================================================================

  case 999: // change in delta corrector value
      if (has_command('D', instruction, size))



// G? ==========================================================================

  default:
    Serial.print("huh? G");
    Serial.println(code, DEC);
  }
  return true;
}   // end of G code processing
    //=========================


void DebugUnits() {
  Serial.print("x units: ");
  Serial.print(x_units, DEC);
  Serial.print(" y units: ");
  Serial.print(y_units, DEC);
  Serial.print(" z units: ");
  Serial.println(z_units, DEC);
}

void UnitsInches() {
  // basic units are defined in steps per inch
  //==========================================
  
  x_units = X_STEPS_PER_INCH;
  y_units = Y_STEPS_PER_INCH;
  z_units = Z_STEPS_PER_INCH;
  FastFeedRateXY = FAST_XY_FEEDRATE_INCH;
  FastFeedRateZ = FAST_Z_FEEDRATE_INCH;

  // this is deliberatly different
  // as we are defining a size not no. of steps
  //===========================================
  curve_section = CURVE_SECTION_MM / MM_PER_INCH;

  if (!inches) {
    current_units.x = current_units.x / MM_PER_INCH;
    current_units.y = current_units.y / MM_PER_INCH;
    current_units.z = current_units.z / MM_PER_INCH;
  }
  inches = true;
  
  calculate_deltas();
}

void UnitsMM() {
  // basic units are defined in steps per inch
  //==========================================
  
  x_units = X_STEPS_PER_INCH / MM_PER_INCH;
  y_units = Y_STEPS_PER_INCH / MM_PER_INCH;
  z_units = Z_STEPS_PER_INCH / MM_PER_INCH;
  FastFeedRateXY = FAST_XY_FEEDRATE_INCH * MM_PER_INCH;
  FastFeedRateZ = FAST_Z_FEEDRATE_INCH * MM_PER_INCH;

  // curve section is defined in mm
  //===============================
  curve_section = CURVE_SECTION_MM;
  
  if (inches) {
    current_units.x = current_units.x * MM_PER_INCH;
    current_units.y = current_units.y * MM_PER_INCH;
    current_units.z = current_units.z * MM_PER_INCH;
  }
  
  inches = false;
  
  calculate_deltas();
}

