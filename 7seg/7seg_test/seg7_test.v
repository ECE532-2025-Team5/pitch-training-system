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
    input BTNC,
    input [15:0] SW,
    output [15:0] LED,
    output [6:0] SEG7_SEG,
    output [7:0] SEG7_AN,
    output SEG7_DP
    );
    
    assign LED[15:0] = SW[15:0];
    wire resetn = SW[15];
    wire [2:0] seg7id = SW[13:11];
    wire [7:0] ascii = SW[7:0];
    
    reg [63:0] seg7_reg;
    
    always @ (posedge CLK100MHZ) begin
        if (!resetn) begin
            seg7_reg <= 64'h0;
        end
        else if (BTNC) begin
            seg7_reg[8*seg7id +: 8] <= ascii;
        end
    end

    seg7x8 sevenSegDisp(
        .clk(CLK100MHZ),
        .resetn(resetn),
//        .en(BTNC),
//        .seg7id(SW[13:11]),
//        .ascii(SW[7:0]),
        .asciix8(seg7_reg),
        .dp(SEG7_DP),
        .seg(SEG7_SEG[6:0]),
        .an(SEG7_AN[7:0])
    );
     
endmodule
