//----------------------------------------------------------------------------------
//-- Company: Digilent RO
//-- Engineer: Mircea Dabacan
//-- 
//-- Create Date: 12/04/2014 07:52:33 PM
//-- Design Name: Audio Spectral Demo 
//-- Module Name: TopNexys4Spectral - Behavioral
//-- Project Name: TopNexys4Spectral 
//-- Target Devices: Nexys 4, Nexys 4 DDR
//-- Tool Versions: Vivado 14.2
//-- Description: The project:
//--    gets PDM data from the built-in microphone,
//--    digitally filters data for decimation and resolution (16 bit, 48KSPS),
//--    reverberates the audio data and outputs it to the built-in Audio Out,
//--    stores a frame of 1024 samples and shows it on a VGA display (640x480, 60Hz),
//--    computes FFT of the stored data (512 bins x 46.875 Hz = 0...24KHz),
//--    shows the first 80 FFT bins on the VGA display (80 bins x 46.875 Hz = 0...3.75KHz),
//--    displays the first 30 FFT bins on an LED string (30 bins x 46.875 Hz = 0...1.4KHz), 
//-- 
//-- Dependencies: 
//--    HW:
//--       -- Nexys 4 or Nexys 4 DDR board (Digilent)
//--       -- WS2812 LED Strip 
//--              - GND(white) to JC pin5
//--              - Vcc(red) to JC pin6
//--              - data(green) to JC pin4 
//--       -- VGA monitor (to the VGA connector of the NExys 4 or Nexys 4 DDR board) 
//--       -- audio headspeakers (to the audio out connector)
//--
//-- Revision:
//-- Revision 0.01 - File Created
//-- Additional Comments:
//-- 
//----------------------------------------------------------------------------------


module prescaller #(
    parameter cstDivPresc = 10000000  // Adjust this value as needed
)(
    input wire ck100MHz,              // 100MHz clock input
    output reg flgStartAcquisition     // Output pulse
);

    reg [$clog2(cstDivPresc)-1:0] cntPresc;  // Counter to divide the clock

    always @(posedge ck100MHz) begin
        if (cntPresc == cstDivPresc - 1) begin
            cntPresc <= 0;
            flgStartAcquisition <= 1;
        end else begin
            cntPresc <= cntPresc + 1;
            flgStartAcquisition <= 0;
        end
    end

endmodule
