/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"

volatile unsigned int* microblazesim 		= (unsigned int*) XPAR_AXI_GPIO_MICROBLAZESIM_BASEADDR;
volatile unsigned int* peripherals_pr2mb 	= (unsigned int*) XPAR_AXI_GPIO_PERIPHERALS_BASEADDR;
volatile unsigned int* peripherals_mb2pr 	= (unsigned int*) (XPAR_AXI_GPIO_PERIPHERALS_BASEADDR + 0x8);

int main()
{
    init_platform();

    print("Hello World\n\r");

// Encode / Decode

    // simulated microblaze (SW) -> Microblaze
	//    	wire [3:0] playen_oct_oct_oct   = SW[15:12];
	//      wire simulated_cmp              = SW[11];
    // 		wire [3:0] microblaze_sung_note = SW[9:6];
    //    	wire [3:0] generated_note0      = SW[5:2];   // 0 C, 11 B
    //    	wire [1:0] simulated_mode_sel   = SW[1:0];
    uint32_t microblazesim_in;
    uint8_t playen_oct_oct_oct, simulated_cmp, microblaze_sung_note, generated_note0, simulated_mode_sel;

    // microblaze <- peripheral
    // 		AXI_GPIO outputs [microblaze <- module]
    //    	    // bit 0
    //    	    wire [3:0] user_controls;   // 16 controls bits available for keyboard software controls
    //    	    wire [6:0] piano_note_id;   // piano note most recently played
    //    	    // bit 11
    uint32_t swctrl_piano_in;
    uint8_t piano_note_id;
    uint8_t user_controls;

    // microblaze -> peripheral
    // 		AXI_GPIO inputs [microblaze -> module]
    //    	    // bit 0
    //    	    wire [1:0] mode_sel;        // 0 Home, 1 Ear Training, 2 Free Play
    //    	    wire [1:0] play_note_num;   // microblaze generates chord, max 3 notes
    //    	    wire [6:0] play_note_id_0;  // microblaze chord note 0
    //    	    wire [6:0] play_note_id_1;  // microblaze chord note 1
    //    	    wire [6:0] play_note_id_2;  // microblaze chord note 2
    //    	    wire [5:0] sung_note_id;    // user sung note
    //    	    wire compare_correct;
    //    	    // bit 31
    uint32_t swctrl_piano_out;
    uint8_t compare_correct, sung_note_id, play_note_id2, play_note_id1, play_note_id0, play_note_num, mode_sel;

    while (1) {

    	// simulation (output)
    	microblazesim_in = *microblazesim;
    	simulated_mode_sel 	 = (microblazesim_in >> 0)  & 0x3;
		generated_note0 	 = (microblazesim_in >> 2)  & 0xF;
		microblaze_sung_note = (microblazesim_in >> 6)  & 0xF;
		simulated_cmp 		 = (microblazesim_in >> 11) & 0x1;
		playen_oct_oct_oct 	 = (microblazesim_in >> 12) & 0xF;
//		xil_printf("pooo[%d] cmp[%d] sung[%d] gen[%d] mode[%d]\n", playen_oct_oct_oct, simulated_cmp, microblaze_sung_note, generated_note0, simulated_mode_sel);


    	swctrl_piano_in = *peripherals_pr2mb;
    	user_controls = (swctrl_piano_in) & 0xF;
    	piano_note_id = (swctrl_piano_in >> 4) & 0x7F;
//    	xil_printf("piano: %d ----- user_controls: %d\n", piano_note_id, user_controls);
//    	xil_printf("input: %x\n", swctrl_piano_in);


    	// peripheral (input)
    	mode_sel 		= simulated_mode_sel;
        play_note_num 	= 1;
    	play_note_id0 	= generated_note0 + 27;
    	play_note_id1 	= 0;
    	play_note_id2 	= 0;
    	sung_note_id 	= microblaze_sung_note + 28;
    	compare_correct = simulated_cmp;

    	swctrl_piano_out = 0;
    	swctrl_piano_out |= ((mode_sel 			& 0x3 ) << 0);
    	swctrl_piano_out |= ((play_note_num		& 0x3 ) << 2);
    	swctrl_piano_out |= ((play_note_id0 	& 0x7F) << 4);
    	swctrl_piano_out |= ((play_note_id1 	& 0x7F) << 11);
    	swctrl_piano_out |= ((play_note_id2 	& 0x7F) << 18);
    	swctrl_piano_out |= ((sung_note_id 		& 0x3F) << 25);
    	swctrl_piano_out |= ((compare_correct	& 0x1 ) << 31);
    	*peripherals_mb2pr = swctrl_piano_out;
		xil_printf("cmp[%d] swctrl_piano_out[%x]\n", simulated_cmp, swctrl_piano_out);

    }

    cleanup_platform();
    return 0;
}
