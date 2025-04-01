#include "xil_io.h"
#include "xparameters.h"
#include <time.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <unistd.h>

// Define the base addresses of AXI slaves
//-------------------Actual Addresses for each Module------------
//#define AUDIO_BASE_ADDR  0x44a00000
//#define PERI_BASE_ADDR  0x44a10000
//#define VGA_SLAVE_ADDR   0x44a20000

//-------------------Simulating through GPIO ports------------
#define PUSH_BUTTON_BASE_ADDR  0x44a00000
#define LED_BASE_ADDR  0x40010000
#define RGB_LED_ADDR   0x40010008
#define SWITCHES_ADDR   0x40000008
#define PERI_ADDR      0x40030000
#define REFERENCE_NOTE      0x40020000

#define HOME_SCREEN      0x0
#define SPACE      0x20


unsigned int get_random_U32_number(u32 *state) {
    u32 Number = *state;
    Number ^= Number << 13;
    Number ^= Number >> 17;
    Number ^= Number << 5;
    *state = Number;
    return Number;
}
volatile unsigned int* reference = (unsigned int*) XPAR_MODE_BASEADDR;
volatile unsigned int* User_Sang = (unsigned int*) XPAR_GPIO_3_BASEADDR;

u32 audio_pipeline_note_mapping_ifEl(u32 audio_bin){
	u32 note;
	if (audio_bin>=34 && audio_bin<=36){
		note=33;
	}
	else if (audio_bin>=37 && audio_bin <=40){
		note=34;
	}
	else if(audio_bin>=41 && audio_bin<=45){
		note =35;
	}
	else if(audio_bin>=46 && audio_bin<=49){
		note=36;
	}
	else if(audio_bin>=50 && audio_bin<=53){
		note=37;
	}
	else if(audio_bin>=54 && audio_bin<=58){
		note=38;
	}
	else if(audio_bin>=59 && audio_bin<=63){
		note=39;
	}
	else if(audio_bin>=64 && audio_bin<=69){
		note=40;
	}
	else if(audio_bin>=70 && audio_bin<=74){
		note=41;
	}
	else if(audio_bin>=75 && audio_bin<=80){
		note=42;
	}
	else if(audio_bin>=81 && audio_bin<=87){
		note=43;
	}
	else if(audio_bin>=88 && audio_bin<=94){
		note=44;
	}
	else{
        //print("User not singing in the specified range.");
        note =0;
	}
	return note;
}

int main() {
    u32 mode,result;
    u32 chord;
    int counter=0;
    int numNotes;
    u32 state_var;  // Declare a valid variable to hold the state
    u32 *state = &state_var;  // Initialize pointer to the address of state_var
    u32 initial_input;
    init_platform();
    xil_printf("Hello\n");
    //srand(time(NULL));
    while(1){
    	result = *reference;
    	initial_input = Xil_In32(SWITCHES_ADDR)&0x3;
    	if (counter==0){
        	*state = result;
        	counter++;
    	}
    	xil_printf("I just entered while loop\n.");
    	mode = result & 0xF;
    	if (mode == 1)
    	{
    		//currently in homescreen
            //led[15]: Homescreen
    		xil_printf("Im in mode 1\n.");
    		Xil_Out32(RGB_LED_ADDR, 0x1);
    	}
        //switch[15] on
    	else if (mode == 2)
    	{
    		xil_printf("Im in mode 2\n.");
    		numNotes = get_random_U32_number(state)%3 +1;
            //how many notes are randomly generated shown through led[1:0]
    		u32 *randNoteArray = malloc(numNotes * sizeof(u32));
    		u32 *UserInputs = malloc(numNotes * sizeof(u32));
    		int matches=0;
    		u32 AllMatch;

            //generate random notes
            //(0-11) +33
            for (int i=0;i<numNotes;i++){
    			randNoteArray[i]=get_random_U32_number(state)%12+33;
    			if (i!=0){
    				for(int j=0;j<i;j++){
    					while (randNoteArray[i] == randNoteArray[j]){
    						randNoteArray[i]=get_random_U32_number(state)%12+33;
    					}
    				}
    			}
    		}
    		//randNoteArray[0]=3;
            if (numNotes==1){
    			chord = (randNoteArray[0]<<4)|(numNotes<<2)|mode;

    		}
    		else if (numNotes==2){
    			chord = (randNoteArray[0]<<4)|(randNoteArray[1]<<11)|(numNotes<<2)|mode;
    		}
    		else{
    			chord = (randNoteArray[0]<<4)|(randNoteArray[1]<<11)|(randNoteArray[2]<<18)|(numNotes<<2)|mode;
    		}

    		//sub with space ascii keyboard:
    	    if (Xil_In32(SWITCHES_ADDR)&0x4) {
    	    	chord = chord | (0<<31);
    	    	Xil_Out32(LED_BASE_ADDR, chord);  // Set LED[15]
    	    }

    		//concatenate the chord for outputting the chord to the audio port
            if (numNotes == 1) {
                // Wait for user input change
                do {
                    UserInputs[0] = Xil_In32(SWITCHES_ADDR) & 0x3;
                } while (UserInputs[0] == initial_input); // Ensure input is different

            }

            // If numNotes == 2, we must wait for two separate inputs
            if (numNotes == 2) {
                // Wait for first input
                do {
                    UserInputs[0] = Xil_In32(SWITCHES_ADDR) & 0x3;
                } while (UserInputs[0] == initial_input);

                // Wait for second input
                do {
                    UserInputs[1] = Xil_In32(SWITCHES_ADDR) & 0x3;
                } while (UserInputs[1] == UserInputs[0]); // Ensure different inputs
            }

            // If numNotes == 3, we must wait for three separate inputs
            if (numNotes == 3) {
                // Wait for first input
                do {
                    UserInputs[0] = Xil_In32(SWITCHES_ADDR) & 0x3;
                } while (UserInputs[0] == initial_input);

                // Wait for second input
                do {
                    UserInputs[1] = Xil_In32(SWITCHES_ADDR) & 0x3;
                } while (UserInputs[1] == UserInputs[0]); // Ensure different inputs

                // Wait for third input
                do {
                    UserInputs[2] = Xil_In32(SWITCHES_ADDR) & 0x3;
                } while (UserInputs[2] == UserInputs[0] || UserInputs[2] == UserInputs[1]);
            }

    		for (int x = 0; x < numNotes; x++) {
    		    for (int y = 0; y < numNotes; y++) {
    		        if (UserInputs[x] == randNoteArray[y]) {
    		            matches++;
    		            break;
    		        }
    		    }
    		}
////
    		AllMatch = (matches==numNotes)?1:0;  // True if all match

    		chord = chord|(AllMatch<<31);

    		//change with Peripheral address mapping
    		Xil_Out32(LED_BASE_ADDR, chord);
		}
		else if(mode == 3){
			xil_printf("Im in mode 3\n.");

			u32 UserSang_note = audio_pipeline_note_mapping_ifEl(*User_Sang);
			if(*reference==UserSang_note){
				xil_printf("Pitch Matched.\n User Sang: %d\n",UserSang_note);
					//Match_freePlay=1;
			}
			else{
					//Match_freePlay =0;
				xil_printf("Pitch Note Matched.\n User Sang: %d\n",UserSang_note);
			}

			//package = (UserSang_note<<25)|(Match_freePlay<<31)|mode;
			//sub with peri address
			//Xil_Out32(LED_BASE_ADDR, package);
			//sleep(50);
		}

    }
    return 0;
}
