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

 #include "xil_io.h"
 #include <stdio.h>
 #include "platform.h"
 #include "xil_printf.h"
 //USER_SANG
 volatile unsigned int* reference = (unsigned int*) XPAR_GPIO_3_BASEADDR;
 //#define USER_SANG 40020000
 u32 audio_pipeline_note_mapping_case(u32 audio_bin){
     u32 note;
     switch(audio_bin){
     //maps to C3
 //	case 19:
 //		note =28;
 //		break;
 //	case 20:
 //		note =28;
 //		break;
 //	case 21:
 //		note =28;
 //		break;
 //	//maps to C sharp
 //	case 22:
 //		note =29;
 //		break;
 //	case 23:
 //		note =29;
 //		break;
 //	case 24:
 //		note =29;
 //		break;
 //	//maps to D3
 //	case 25:
 //		note =30;
 //		break;
 //	case 26:
 //		note =30;
 //		break;
 //	case 27:
 //		note =30;
 //		break;
 //	//maps to D sharp
 //	case 28:
 //		note =31;
 //		break;
 //	case 29:
 //		note =31;
 //		break;
 //	case 30:
 //		note =31;
 //		break;
 //	//maps to E3
 //	case 31:
 //		note =32;
 //		break;
 //	case 32:
 //		note =32;
 //		break;
 //	case 33:
 //		note =32;
 //		break;
     //F3
     case 34:
         note =33;
         break;
     case 35:
         note =33;
         break;
     case 36:
         note =33;
         break;
     //F3 sharp
     case 37:
         note =34;
         break;
     case 38:
         note =34;
         break;
     case 39:
         note =34;
         break;
     case 40:
         note =34;
         break;
     //G3
     case 41:
         note =35;
         break;
     case 42:
         note =35;
         break;
     case 43:
         note =35;
         break;
     case 44:
         note =35;
         break;
     case 45:
         note =35;
         break;
     //G3 sharp
     case 46:
         note =36;
         break;
     case 47:
         note =36;
         break;
     case 48:
         note =36;
         break;
     case 49:
         note =36;
         break;
     //A3
     case 50:
         note =37;
         break;
     case 51:
         note =37;
         break;
     case 52:
         note =37;
         break;
     case 53:
         note =37;
         break;
     //A3 sharp
     case 54:
         note =38;
         break;
     case 55:
         note =38;
         break;
     case 56:
         note =38;
         break;
     case 57:
         note =38;
         break;
     case 58:
         note =38;
         break;
     //B3
     case 59:
         note =39;
         break;
     case 60:
         note =39;
         break;
     case 61:
         note =39;
         break;
     default:
         print("User not singing in the specified range.");
         note =0;
         break;
     }
     return note;
 }
 
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
         print("User not singing in the specified range.");
         note =0;
     }
     return note;
 }
 
 int main()
 {
     init_platform();
     xil_printf("Hello\n");
     //u32 detected;
     while(1){
         //detected=Xil_In32(USER_SANG);
         xil_printf("The detected sound is: %d\n", *reference);
         xil_printf("The converted note number: %d\n",audio_pipeline_note_mapping_ifEl(*reference));
     }
 
     cleanup_platform();
     return 0;
 }