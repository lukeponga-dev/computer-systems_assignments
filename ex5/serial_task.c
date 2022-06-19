/**
*  serial_task.c
*
* Author - Luke Ponga
*/

#include "wramp.h"
int counter = 0; //  global variable for counter (system uptime, how many timer interrupts)

//PRINT to serial port 2 method
void printChar(int c){
	
	//TDR bit polling using library -  
	while(!(WrampSp2 -> Stat & 0x2));
	
	// transmit char to serial port 2
	WrampSp2 -> Tx= c;
}

/**
 * set the format to “\rmm:ss”
 */
void display_1(int counter)
{
        int minutes = counter / 100 / 60;
        int seconds = counter / 100 % 60;		    
        printChar('\r');
        printChar(minutes / 10 + '0');
        printChar(minutes % 10 + '0');
        printChar(':');
	printChar(seconds / 10 + '0');
	printChar(seconds % 10 + '0');
	printChar(' ');
	printChar(' ');
}
/**
//RECEIVE from serial port 2
void receiveChar(){
	//RDR bit polling using library  - WrampSp2 -> Stat & 1
	//Note: If no new character is received, return ''
	while(WrampSp2 -> Stat & 1)
	{
	        WrampSp2 -> Rx = counter;
        }
}
*/

void serial_main(){
	
	int pressed = 0; // keeps track of the last pressed value by user
	
	// Infinte loop
	while(1)
	{
		// Check if received character is 1, 2, 3 or q
		if(WrampSp2 ->Rx == '1' || WrampSp2 ->Rx == '2' || WrampSp2 ->Rx == '3' || WrampSp2 ->Rx == 'q')
		{
			while(1)
			{
			          // exits program 
		     		 if (WrampSp2->Rx == 'q')
                		{
					printChar('\r');
					printChar('g');
					printChar('o');
					printChar('o');
					printChar('d');
					printChar('b');
					printChar('y');
					printChar('e');
		           		return;
                   		}
			 	if (WrampSp2->Rx == '1' || pressed == '1')
			 	{
		            		pressed = '1';
		           	 	display_1(counter);
		        	}
		        	if (WrampSp2->Rx == '2' || pressed == '2')
		        	{
                	                // set the format to “\rssss.ss”
                                          // i.e. secounds printed to two decumal places
		            		pressed = '2';
                                 	printChar('\r');
                                 	printChar(counter / 100000 % 10 + '0');
                                 	printChar(counter / 10000 % 10 + '0');
                                 	printChar(counter / 1000 % 10 + '0');
                                  	printChar(counter / 100 % 10 + '0');
                                  	printChar('.');
                                  	printChar(counter / 10 % 10 + '0'); 	
                                  	printChar(counter  % 10 + '0');
		        	}               	
		        	if (WrampSp2->Rx == '3' || pressed == '3')
		        	{
		            		pressed = '3';
		            		printChar('\r');
	 				printChar(counter / 100000 % 10 + '0');
	 				printChar(counter / 10000 % 10 + '0');
	 				printChar(counter / 1000 % 10 + '0');
	  				printChar(counter / 100 % 10 + '0');
	  	  			printChar(counter / 10 % 10 + '0'); 	
	  	  			printChar(counter  % 10 + '0');
	  	  			printChar(' ');
	  			}
  			}
		}
	// if not buttons pressed print format as display 1 
	display_1(counter);
	}
}

