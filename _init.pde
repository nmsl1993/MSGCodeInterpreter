// constant for mm conversions
//============================
#define MM_PER_INCH 25.4

//=====================================
// define the parameters of our machine
//=====================================
#define X_STEPS_PER_INCH 100
#define Y_STEPS_PER_INCH 100
#define Z_STEPS_PER_INCH 100

//==================================
//our maximum feedrates units/minute
//==================================
#define FAST_XY_FEEDRATE_INCH 300.0
#define FAST_Z_FEEDRATE_INCH  300.0

//=======================
// Units in curve section
//=======================
#define CURVE_SECTION_MM 0.5

//=========================================
// Set to one if sensor outputs inverting 
// (ie: 1 means open, 0 means closed)
// RepRap opto endstops are *not* inverting
//=========================================
#define SENSORS_INVERTING 0

//============================
// pin 0 used for serial comms
// pin 1 used for serial comms
//============================
#define SERIAL_RX_PIN 0
#define SERIAL_TX_PIN 1
