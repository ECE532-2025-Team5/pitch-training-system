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

    wire [7:0] keycode;
    wire [7:0] asciicode;
    wire new_key_pressed;
    keyboard_ps2 kb0(
        .clk(CLK50MHZ),
        .ps2_clk(PS2_CLK),
        .ps2_data(PS2_DATA),
        .resetn(CPU_RESETN),
        .new_key(new_key_pressed),
        .key_code(keycode),
        .key_ascii(asciicode)
    );
    
    // piano keys
    reg [3:0] piano_pressed;
    reg [7:0] piano_played_note;
    reg [7:0] piano_played_accidental;
    always @ (*) begin        
        case(keycode)
            `kb_Z: begin
                piano_pressed <= 4'd1;   // C
                piano_played_note <= `ascii_C;
                piano_played_accidental <= `ascii_SPACE;
                end
            `kb_S: begin
                piano_pressed <= 4'd2;   // C#
                piano_played_note <= `ascii_C;
                piano_played_accidental <= `ascii_SQT;
                end
            `kb_X: begin
                piano_pressed <= 4'd3;   // D
                piano_played_note <= `ascii_D;
                piano_played_accidental <= `ascii_SPACE;
                end
            `kb_D: begin
                piano_pressed <= 4'd4;   // D#
                piano_played_note <= `ascii_D;
                piano_played_accidental <= `ascii_SQT;
                end
            `kb_C: begin
                piano_pressed <= 4'd5;   // E
                piano_played_note <= `ascii_E;
                piano_played_accidental <= `ascii_SPACE;
                end
            `kb_V: begin
                piano_pressed <= 4'd6;   // F
                piano_played_note <= `ascii_F;
                piano_played_accidental <= `ascii_SPACE;
                end
            `kb_G: begin
                piano_pressed <= 4'd7;   // F#
                piano_played_note <= `ascii_F;
                piano_played_accidental <= `ascii_SQT;
                end
            `kb_B: begin
                piano_pressed <= 4'd8;   // G
                piano_played_note <= `ascii_G;
                piano_played_accidental <= `ascii_SPACE;
                end
            `kb_H: begin
                piano_pressed <= 4'd9;   // G#
                piano_played_note <= `ascii_G;
                piano_played_accidental <= `ascii_SQT;
                end
            `kb_N: begin
                piano_pressed <= 4'd10;   // A
                piano_played_note <= `ascii_A;
                piano_played_accidental <= `ascii_SPACE;
                end
            `kb_J: begin
                piano_pressed <= 4'd11;   // A#
                piano_played_note <= `ascii_A;
                piano_played_accidental <= `ascii_SQT;
                end
            `kb_M: begin
                piano_pressed <= 4'd12;   // B
                piano_played_note <= `ascii_B;
                piano_played_accidental <= `ascii_SPACE;
                end
            
            default: begin
                piano_pressed <= 4'd0;
                piano_played_note <= `ascii_SPACE;
                piano_played_accidental <= `ascii_SPACE;
            end
        endcase
    end
    
    // 7seg select
    reg [2:0] seg7id = 3'h7;
    always @ (posedge new_key_pressed, negedge CPU_RESETN) begin
        if (!CPU_RESETN) begin
            seg7id <= 3'h7;
        end
        else if (keycode == `kb_KP_4 && seg7id < 'd7) begin
            seg7id <= seg7id + 1'b1;
        end
        else if (keycode == `kb_KP_6 && seg7id > 'd0) begin
            seg7id <= seg7id - 1'b1;
        end
    end

    seg7x8 sevenSegDisp(
        .clk(CLK100MHZ),
        .resetn(CPU_RESETN),
        .en(new_key_pressed),
//        .seg7id(seg7id),
//        .ascii(asciicode),
        .seg7id(3'd5),
        .ascii(piano_played_note),
        .dp(SEG7_DP),
        .seg(SEG7_SEG[6:0]),
        .an(SEG7_AN[7:0])
    );
     
endmodule
