`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Thomas Kappenman
// 
// Create Date: 03/03/2015 09:06:31 PM
// Design Name: 
// Module Name: top
// Project Name: Nexys4DDR Keyboard Demo
// Target Devices: Nexys4DDR
// Tool Versions: 
// Description: This project takes keyboard input from the PS2 port,
//  and outputs the keyboard scan code to the 7 segment display on the board.
//  The scan code is shifted left 2 characters each time a new code is
//  read.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    input CLK100MHZ,
    input PS2_CLK,
    input PS2_DATA,
    input CPU_RESETN,
    output UART_TXD,
    output [6:0] SEG7_SEG,
    output [7:0] SEG7_AN,
    output SEG7_DP
    );
    
    reg CLK50MHZ=0;        
    always @(posedge CLK100MHZ)begin
        CLK50MHZ<=~CLK50MHZ;
    end

    wire [15:0] keycode;
    ps2 kb0(
        .clk(CLK50MHZ),
        .rst_n(CPU_RESETN),
        .ps2_clk(PS2_CLK),
        .ps2_data(PS2_DATA),
        .keycode(keycode)
    );
    
    // New Key Detection
    reg [7:0] prev_key_code = 8'b0;  // Stores last pressed keycode
    reg key_released = 1'b1;         // Flag to track if key was released
    reg new_key_pressed;

    wire [7:0] break_code = keycode[15:8];  // Break code part
    wire [7:0] key_code = keycode[7:0];    // Make code part

    always @(posedge CLK50MHZ) begin
        new_key_pressed <= 1'b0; // Default low (ensures 1-cycle pulse)

        if (break_code == 8'hF0) begin
            // Key release detected
            key_released <= 1'b1;
        end
        else if ((key_code != prev_key_code) || key_released) begin
            // New key detected OR same key but was released before
            new_key_pressed <= 1'b1;
            prev_key_code <= key_code;
            key_released <= 1'b0; // Key is now pressed
        end
    end
    
    // PS/2 Code to ASCII Conversion
    wire [7:0] ascii;
    ps2_to_ascii conv0(
        .keycode(key_code),
        .ascii(ascii)
    );
    
    // 7seg select
    reg [2:0] seg7id = 3'h7;
    always @ (posedge new_key_pressed, negedge CPU_RESETN) begin
        if (!CPU_RESETN) begin
            seg7id <= 3'h7;
        end
        else if (key_code == `kb_KP_4 && seg7id < 'd7) begin
            seg7id <= seg7id + 1'b1;
        end
        else if (key_code == `kb_KP_6 && seg7id > 'd0) begin
            seg7id <= seg7id - 1'b1;
        end
    end

    seg7x8 sevenSegDisp(
        .clk(CLK100MHZ),
        .resetn(CPU_RESETN),
        .en(new_key_pressed),
        .seg7id(seg7id),
        .ascii(ascii),
        .dp(SEG7_DP),
        .seg(SEG7_SEG[6:0]),
        .an(SEG7_AN[7:0])
    );
     
endmodule
