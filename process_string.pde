
// init our string processing
//===========================
void init_process_string()
{
  // init our command
  //=================
  for (byte i=0; i<COMMAND_SIZE; i++)
    aWord[i] = 0;
    serial_count = 0;
}

// Read the string and execute instructions
//=========================================
void process_string(char instruction[], int size)
{
  boolean result;
  
  if (DebugLevel > 1) {
    Serial.println(instruction);
  }

  result = true;
  
  if (has_command('/', instruction, size))
    result = ProcessComment(instruction, size);
  else if (has_command('G', instruction, size))
    result = ProcessGcode(instruction, size);
  else if (has_command('M', instruction, size)) 
    result = ProcessMcode(instruction, size);

  if (result) {
    // tell our host we're done
    // ========================
    Serial.println("A");
//    Serial.println(line, DEC);
  }
}

// look for the number that appears after the char key and return it
//==================================================================
double search_string(char key, char instruction[], int string_size)
{
  int k;
  char temp[10];
  int i;
  
  for (i=0; i<10; i++)
    temp[i] = 0;

  for (i=0; i<string_size; i++) {
    if (instruction[i] == key) {
      i++;
      k = 0;
      // skip leading spaces
      //====================
      while (i < string_size && k < 10 && instruction[i] == ' ')
        i++;
      
      while (i < string_size && k < 10) {
        if (instruction[i] == 0 || instruction[i] == ' ')
          break;

        temp[k] = instruction[i];
        i++;
        k++;
      }
      return strtod(temp, NULL);
    }
  }
  return 0;
}

// see if required command exists
//===============================
bool has_command(char key, char instruction[], int string_size)
{
  int i;
  
  for (i=0; i<string_size; i++){
    if (instruction[i] == key)
      return true;
  }
  return false;
}
