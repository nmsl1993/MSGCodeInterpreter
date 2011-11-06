// Arduino G-code Interpreter
// v1.0 by Mike Ellery - initial software (mellery@gmail.com)
// v1.1 by Zach Hoeken - cleaned up and did lots of tweaks (hoeken@gmail.com)
// v1.2 by Chris Meighan - cleanup / G2&G3 support (cmeighan@gmail.com)
// v1.3 by Zach Hoeken - added thermocouple support and multi-sample temp readings. (hoeken@gmail.com)

// v1.3a mmcp - removed extruder functionality
//            - changed variable array called word (!) to array called aWord
//            - added checksum to serial comms

// v1.4  mmcp - extended M114 to report limit switches as well as co-ordinates
//============================================================================

#define FIRMWARE_VERSION "v1.4"

#include <math.h>
#include <wiring.h>
#include <Servo.h> 
#include <HardwareSerial.h>
#include <AFMotor.h>



//Steppers=====================================================================
Servo myservo;  // create servo object to control a servo 
                // a maximum of eight servo objects can be created 

float ratio;
int max_speed = 200;
int counter = 0;

//Steppers========================================================================



// two stepper motors one on each port
AF_Stepper motor1(200, 1);
AF_Stepper motor2(200, 2);


// you can change these to SINGLE DOUBLE or INTERLEAVE or MICROSTEP!
// wrappers for the first motor!
void forwardstep1() {  
  motor1.step(1, FORWARD, SINGLE);
}
void backwardstep1() {  
  motor1.step(1, BACKWARD, SINGLE);
}
// wrappers for the second motor!
void forwardstep2() {  
  motor2.step(1, FORWARD, SINGLE);
}
void backwardstep2() {  
  motor2.step(1, BACKWARD, SINGLE);
  
}



// our point structure to make things nice
//========================================
struct LongPoint {
  long x;
  long y;
  long z;
};

struct FloatPoint {
  float x;
  float y;
  float z;
};

// our command string
//===================
#define COMMAND_SIZE 128
char aWord[COMMAND_SIZE];

long serial_count;
long no_data = 0;

// used to decode commands
//========================
char c;
long code;
long line;
long LastLine = 0;

// coordinate mode
//================
boolean abs_mode = true;

// measurement mode
//=================
boolean inches = true;

// steppers state
//===============
boolean steppers = false;

// debug level
// 0 = no debug
// 1 = short
// 2 = verbose
//=============
int DebugLevel = 1;

void setup()
{
  // open comms port
  //================
  Serial.begin(19200);
  Serial.println("A");

  // initialise subsystems
  //======================
  init_process_string();
  init_steppers();
}

void loop()
{
  // read in characters if we got them
  //==================================
  if (Serial.available() > 0) {
    // read next character
    //====================
    c = Serial.read();
    no_data = 0;

    // newline is end of command
    //==========================
    if (c != ':') {
      aWord[serial_count] = c;
      serial_count++;
    }
  }
  else {
    // start counting no-data clicks to timeout steppers
    //==================================================
    no_data++;
    delayMicroseconds(25);
  }

  // if we got a command, do it
  //===========================
  if (serial_count && (c == ':')) {
    //Serial.println("command");
  
    // extract line number if present
    //===============================
    if (has_command('N', aWord, serial_count)) {
      line = (long)search_string('N', aWord, serial_count);
    }
    else {
      line = -1;
    }
        // now process our command!
        //=========================
        process_string(aWord, serial_count-1);

        // update line number
        //===================
        LastLine = line;

    // and clear the command buffer
    //=============================
    init_process_string();
    no_data = 0;
    c = ' ';
  }

  // if no data turn off steppers
  //=============================
  if (no_data > 10000)
    disable_steppers();
}
