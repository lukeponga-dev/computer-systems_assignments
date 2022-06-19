/**
 * parallel_task.c
 * This file is part of Parallel I/O Task
 *
 * Author - Luke Ponga
 ******************************************/
 
#include "wramp.h"

  /** 
     * writes the number to the SSD as hexadecimal
     * by shifting  the bits  logical right
     *
     * @param i the number to be written 
    */
void writeHexSSD(int i) 
{ 
	WrampParallel -> LowerRightSSD = i;
	i >>= 4; 
	WrampParallel -> LowerLeftSSD = i;
	i >>= 4;		
	WrampParallel -> UpperRightSSD = i;
	i >>= 4;
	WrampParallel -> UpperLeftSSD = i;
}

/**
 * writes the number to the SSD as decimal 
 * by calculating the remainder and dividing the bits by 10
 *
 * @param i the number to be written
**/
void writeDecSSD(int i){
	    int rem = 0 ;
	    rem = i % 10;	// current value of switches modulo 10
	    
            WrampParallel->LowerRightSSD = rem;
            i /= 10;

            rem = i % 10;
            WrampParallel->LowerLeftSSD = rem;
            i /= 10;
        
            rem = i % 10;
            WrampParallel->UpperRightSSD = rem;
             i /= 10;

            rem = i % 10;
            WrampParallel->UpperLeftSSD = rem;
}

/**
 * programs main entry
*/
void parallel_main() {

	// declare variables
	int switches = 0; 
	int buttonValue = 0;
	int pressed = 0;
	
	// Infinite loop
	while(1) 
	{ 
		// read the values from the  from parallel button register
		buttonValue = WrampParallel -> Buttons;
		
		// read the current switch value from parallel switch register
		switches = WrampParallel -> Switches;

		if (buttonValue == 1 || pressed == 1)// IF rightmost button pushed (value of 1, button 0)
		{
			pressed = 0;
			//  write switches to ssd in hexadecimal
			writeHexSSD(switches); 	
		}
		 else if (buttonValue == 2 || pressed ==2)  // else if  middle button is pushed (value of 2, button 1)
		 {
		 	pressed = 2;
			// write switches to ssd in decimal
			writeDecSSD(switches);	
		} 
		else if (buttonValue == 4 ) 	// else if leftmost button pushed (value of 4, button 2) 
		{
			return; // exit 
		}
		else 
	 		// no buttons pressed, write switches as hexadecimal to ssd
			writeHexSSD(switches);
	}
}

