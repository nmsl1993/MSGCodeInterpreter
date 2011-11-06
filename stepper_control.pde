//================
// Stepper Control
//================


void init_steppers() {

  // turn them off to start
  //=======================
//  disable_steppers();

  // init our points
  //================
  current_units.x = 0.0;
  current_units.y = 0.0;
  current_units.z = 0.0;
  target_units.x = 0.0;
  target_units.y = 0.0;
  target_units.z = 0.0;
  current_steps.x = 0.0;
  current_steps.y = 0.0;
  current_steps.z = 0.0;

  ratio = 0;
  
  inches = true;
  
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object 
  
  //initialise steppers
  
  motor1.setSpeed(20);
  motor2.setSpeed(20);
  
  
  //initialise servo (z axis)
    
           myservo.write(0); 

    //calculate initial deltas
  calculate_deltas();
} 


// do the move
void dda_move()
{
if ((delta_steps.x==0) && (delta_steps.y ==0)) // if there is no move
    {
      //do nothing
    }
    
    
else if ((delta_steps.x) !=0 && (delta_steps.y ==0)) //if only x is moving
    {
      do
        {
             if (current_steps.x < target_steps.x)    //is x running backwards or forwards? 
                    {
                      forwardstep1();
                    }      
              else   
                    {
                     backwardstep1();
                    }
             counter++;
          }while (counter<delta_steps.x);
    }      
    
    
    
else if ((delta_steps.y) !=0 && (delta_steps.x ==0)) //if only y is moving

    {

      do 
        {
             if (current_steps.y < target_steps.y)    //is y running backwards or forwards? 
                    {
                      forwardstep2();
                    }      
              else   
                    {
                     backwardstep2();
                    }
             counter++;
          }while (counter<delta_steps.x);
    }      



  
else //both axis moving
  {
//  work out which is the dominant axis and the ratio
if (abs(delta_steps.x) >abs(delta_steps.y))
  {
     ratio=delta_steps.y/delta_steps.x;
  }
  else
  {
     ratio=delta_steps.x/delta_steps.y;
  }   

//    B's line algorithm

float error = 0;

if (delta_steps.x > delta_steps.y)    //x dominant axis?
{
    do 
    {
             if (current_steps.x < target_steps.x)    //is x running backwards or forwards? 
                    {
                      forwardstep1();
                    }      
              else   
                    {
                     backwardstep1();
                    }
                    
         error = error + ratio;
         if (error >= 0.5) 
         {
               if (current_steps.y < target_steps.y) //is y running backwards or forwards?
                    {
                     forwardstep2(); 
                    }      
            else   
                    {
                     backwardstep2();
                    }
                    
             error = error - 1.0;
         }
     counter++;    
    }while (counter<delta_steps.x);
}

else              //y is the dominant axis
{
      do {
          if (current_steps.y < target_steps.y) //is y running backwards or forwards?
                    {
                     forwardstep2(); 
                    }      
            else   
                    {
                     backwardstep2();
                    }
         error = error + ratio;
         if (error >= 0.5) 
           {
             if (current_steps.x < target_steps.x) //is x running backwards or forwards?
                    {
                      forwardstep1();
                    }      
              else   
                    {
                     backwardstep1();
                    }
                    
             error = error - 1.0;
         }
     counter++;
    }while (counter<delta_steps.y);
  }
}
  //end of move reset stepper position
 
  current_units.x = target_units.x;
  current_units.y = target_units.y;
  current_units.z = target_units.z;
  counter = 0;
}


    //convert mm/inches to steps
long to_steps(float steps_per_unit, float units) {
  return steps_per_unit * units;
}


    
void set_target(float x, float y, float z) {
  target_units.x = x;
  target_units.y = y;
  target_units.z = z;

  calculate_deltas();
}


    
void set_position(float x, float y, float z) {
  current_units.x = x;
  current_units.y = y;
  current_units.z = z;

  calculate_deltas();
}
    
    
    //calculate steps and speed required to make a move 
void calculate_deltas() {

  current_steps.x = to_steps(x_units, current_units.x);
  current_steps.y = to_steps(y_units, current_units.y);
  current_steps.z = to_steps(z_units, current_units.z);

  target_steps.x = to_steps(x_units, target_units.x);
  target_steps.y = to_steps(y_units, target_units.y);
  target_steps.z = to_steps(z_units, target_units.z);

  delta_steps.x = abs(target_steps.x - current_steps.x);
  delta_steps.y = abs(target_steps.y - current_steps.y);
  delta_steps.z = abs(target_steps.z - current_steps.z);


      //set pen up or down from z axis
  
  if (target_steps.z < 0)
    {
          myservo.write(180);         
    }
   else 
   {
         myservo.write(0); 
   }
  
      //  pause if pen moving - give a little time for pen placement
  if (delta_steps.z != 0)
    delay (1000);
}



long getMaxSpeed() {

    return max_speed;
}


    //switch off steppers
void disable_steppers() {

    motor1.release();
    motor2.release();
  steppers = false;
}


    //startup steppers
void enable_steppers() {
  // enable all steppers
  //====================

  steppers = true;
}

